import std;
import huxerui;
import huxerui.localnetwork;

namespace ln = huxerui::localnetwork;

namespace {

void Require(bool condition, std::string_view message) {
    if (!condition) {
        throw std::runtime_error(std::string(message));
    }
}

template <class T>
T RequireOk(ln::NetworkResult<T> result, std::string_view op) {
    if (!result.Succeeded()) {
        throw std::runtime_error(
            std::string(op) + " failed (code=" + std::to_string(static_cast<int>(result.Error().code)) +
            ", diag=" + std::to_string(result.Error().diagnostic_code) + "): " + result.Error().message);
    }
    return std::move(result).Value();
}

template <class T>
void RequireErr(const ln::NetworkResult<T>& result, ln::NetworkErrorCode expected, std::string_view op) {
    Require(!result.Succeeded(), std::string(op) + " unexpectedly succeeded");
    Require(result.Error().code == expected,
            std::string(op) + " returned unexpected error code: " + result.Error().message);
    Require(!result.Error().message.empty(), std::string(op) + " returned empty error message");
}

struct AsyncRunState {
    std::mutex mutex;
    bool finished = false;
    std::string error;

    void Finish(std::string message = {}) {
        std::lock_guard lock(mutex);
        finished = true;
        error = std::move(message);
    }
};

AsyncRunState* g_state = nullptr;

huxerui::Task<void> RunAsyncChecks() {
    try {
        // Positive mbedTLS-backed DeviceIdentity generation, export, import, and pairing offer/code round-trip.
        ln::DeviceIdentity host_id = RequireOk(co_await ln::DeviceIdentity::GenerateAsync(), "DeviceIdentity::GenerateAsync");
        const ln::PeerId& id = host_id.Id();
        const std::string hex_id = id.ToString();
        Require(hex_id.size() == 64, "expected 64-hex-digit PeerId");
        Require(std::ranges::any_of(id.digest, [](std::uint8_t b) { return b != 0; }),
                "expected non-zero PeerId digest");
        const auto parsed_id = ln::PeerId::Parse(hex_id);
        Require(parsed_id.has_value() && *parsed_id == id, "PeerId::Parse round-trip failed");
        std::cout << "PASS positive: DeviceIdentity::GenerateAsync() id=" << hex_id << '\n';

        huxerui::Bytes exported_key = RequireOk(co_await host_id.ExportPrivateKeyAsync(), "ExportPrivateKeyAsync");
        Require(!exported_key.empty(), "exported private key must not be empty");
        ln::DeviceIdentity restored_id = RequireOk(
            co_await ln::DeviceIdentity::ImportAsync(std::move(exported_key)),
            "DeviceIdentity::ImportAsync");
        Require(restored_id.Id() == id, "restored DeviceIdentity Id mismatch");
        std::cout << "PASS positive: ExportPrivateKeyAsync + ImportAsync preserved PeerId\n";

        ln::PairingOffer offer = RequireOk(
            ln::PairingOffer::Create(host_id, "sync-files"),
            "PairingOffer::Create");
        const std::string offer_code = offer.Code();
        Require(offer_code.starts_with("hln2-"), "expected hln2- scoped pairing code prefix");

        ln::PairingCode decoded = RequireOk(
            ln::PairingCode::Decode(offer_code),
            "PairingCode::Decode");
        Require(decoded.Host() == id, "decoded PairingCode host mismatch");
        Require(decoded.Purpose() == "sync-files", "decoded PairingCode purpose mismatch");
        const auto parsed_code = ln::PairingCode::Parse(offer_code);
        Require(parsed_code.has_value() && parsed_code->Host() == id, "PairingCode::Parse failed");
        std::cout << "PASS positive: PairingOffer::Create + PairingCode::Decode/Parse verified\n";

        // Positive loopback paired TLS 1.3 handshake over real sockets using mbedTLS 3.6.1.
        ln::DeviceIdentity client_id = RequireOk(
            co_await ln::DeviceIdentity::GenerateAsync(),
            "client DeviceIdentity::GenerateAsync");
        ln::TcpListener tcp_listener = RequireOk(
            co_await ln::ListenTcpAsync({"127.0.0.1", 0}),
            "ListenTcpAsync");
        const ln::Endpoint listen_ep = tcp_listener.LocalEndpoint();
        Require(listen_ep.port != 0, "expected non-zero bound TCP port");

        struct HandshakePair {
            std::optional<ln::NetworkResult<ln::PairedConnection>> server_res;
            std::optional<ln::NetworkResult<ln::PairedConnection>> client_res;
            std::string child_error;
            int remaining = 2;
        };
        auto hs = std::make_shared<HandshakePair>();
        const auto scope = huxerui::UseApplicationTaskScope();

        scope.Launch([hs, &tcp_listener, host_id, offer]() -> huxerui::Task<void> {
            try {
                auto server_tcp = co_await tcp_listener.AcceptAsync();
                if (!server_tcp.Succeeded()) {
                    hs->server_res = ln::NetworkResult<ln::PairedConnection>::Failure(server_tcp.Error());
                } else {
                    ln::PairingPolicy policy{
                        .trusted_peers = {},
                        .offer = offer,
                        .approve = [](ln::PeerId, std::chrono::steady_clock::time_point) -> huxerui::Task<bool> {
                            co_return true;
                        },
                        .purpose = "sync-files",
                    };
                    hs->server_res = co_await ln::AcceptPairedAsync(
                        std::move(server_tcp).Value(), host_id, std::move(policy));
                }
            } catch (const std::exception& ex) {
                hs->child_error = ex.what();
            }
            --hs->remaining;
        });
        scope.Launch([hs, listen_ep, client_id, decoded]() -> huxerui::Task<void> {
            try {
                hs->client_res = co_await ln::ConnectPairedAsync(listen_ep, client_id, decoded);
            } catch (const std::exception& ex) {
                hs->child_error = ex.what();
            }
            --hs->remaining;
        });
        while (hs->remaining > 0) {
            co_await huxerui::Delay(std::chrono::milliseconds(5));
        }

        Require(hs->child_error.empty(), "paired handshake child exception: " + hs->child_error);
        Require(hs->server_res.has_value() && hs->client_res.has_value(), "missing handshake result");
        if (!hs->client_res->Succeeded()) {
            std::cerr << "DIAG client_res err code=" << static_cast<int>(hs->client_res->Error().code)
                      << " diag=" << hs->client_res->Error().diagnostic_code
                      << " msg=" << hs->client_res->Error().message << '\n';
        }
        ln::PairedConnection server_conn = RequireOk(std::move(*hs->server_res), "AcceptPairedAsync");
        ln::PairedConnection client_conn = RequireOk(std::move(*hs->client_res), "ConnectPairedAsync");
        Require(server_conn.Peer() == client_id.Id(), "server authenticated unexpected client PeerId");
        Require(client_conn.Peer() == host_id.Id(), "client authenticated unexpected host PeerId");
        Require(server_conn.Purpose() == "sync-files", "server negotiated unexpected pairing purpose");
        Require(client_conn.Purpose() == "sync-files", "client negotiated unexpected pairing purpose");
        server_conn.Close();
        client_conn.Close();
        tcp_listener.Close();
        std::cout << "PASS positive: loopback TLS 1.3 PairedConnection handshake verified\n";

        // Negative mbedTLS / pairing / TLS credential checks.
        const auto bad_import = co_await ln::DeviceIdentity::ImportAsync(
            huxerui::Bytes{std::byte{0xde}, std::byte{0xad}, std::byte{0xbe}, std::byte{0xef}});
        RequireErr(bad_import, ln::NetworkErrorCode::InvalidIdentity, "malformed DeviceIdentity::ImportAsync");
        std::cout << "PASS negative: malformed DeviceIdentity::ImportAsync -> InvalidIdentity\n";

        const auto bad_offer = ln::PairingOffer::Create(host_id, "INVALID PURPOSE!");
        RequireErr(bad_offer, ln::NetworkErrorCode::Protocol, "invalid purpose PairingOffer::Create");
        std::cout << "PASS negative: invalid purpose PairingOffer::Create -> Protocol\n";

        const auto bad_tls_listener = co_await ln::ListenTlsAsync(ln::TlsListenOptions{
            .endpoint = {"127.0.0.1", 0},
            .certificate_pem = "not-a-valid-pem-certificate",
            .private_key_pem = "not-a-valid-pem-key",
        });
        RequireErr(bad_tls_listener, ln::NetworkErrorCode::Authentication, "malformed ListenTlsAsync credentials");
        std::cout << "PASS negative: malformed ListenTlsAsync credentials -> Authentication\n";

        g_state->Finish();
    } catch (const std::exception& ex) {
        g_state->Finish(ex.what());
    } catch (...) {
        g_state->Finish("unknown exception in RunAsyncChecks");
    }
}

huxerui::View SmokeRoot() {
    const huxerui::TaskScope tasks = huxerui::UseTaskScope();
    huxerui::Lifecycle([tasks] {
        tasks.Launch([]() -> huxerui::Task<void> { co_await RunAsyncChecks(); });
    });
    return huxerui::Spacer();
}

class HeadlessPlatform final : public huxerui::UiWindow, public huxerui::Runtime {
public:
    HeadlessPlatform()
        : huxerui::Runtime([this](std::function<void()> cb) {
              {
                  std::lock_guard lock(mutex_);
                  callbacks_.push_back(std::move(cb));
              }
              cv_.notify_all();
          }) {}

    ~HeadlessPlatform() override {
        UiWindow::Retire();
        huxerui::Runtime::Retire();
    }

    void Start(const huxerui::Application& app) {
        InitializeApplication(app);
        InitializeWindow(*this, app.root_factory, app.options.window);
    }

    void OnRuntimeStopped() override {}

    void RequestFrameAt(double) override {
        {
            std::lock_guard lock(mutex_);
            frame_requested_ = true;
        }
        cv_.notify_all();
    }

    double Now() const noexcept override {
        return std::chrono::duration<double>(
                   std::chrono::steady_clock::now().time_since_epoch())
            .count();
    }

    huxerui::FontMetrics Metrics(const huxerui::Font&) override { return {}; }
    huxerui::TextRunMetrics MeasureRun(
        std::string_view, const huxerui::TextStyle&, const huxerui::TextShapingOptions&) override {
        return {};
    }
    huxerui::TextLayoutMetrics MeasureText(
        const huxerui::AttributedText&, const huxerui::TextStyle&, float,
        const huxerui::TextLayoutOptions&) override {
        return {};
    }

    bool RunNext(huxerui::UiWindow& window, std::chrono::steady_clock::time_point deadline) {
        std::function<void()> cb;
        bool build_frame = false;
        {
            std::unique_lock lock(mutex_);
            cv_.wait_until(lock, deadline, [this] {
                return !callbacks_.empty() || frame_requested_;
            });
            if (!callbacks_.empty()) {
                cb = std::move(callbacks_.front());
                callbacks_.pop_front();
            } else if (frame_requested_) {
                frame_requested_ = false;
                build_frame = true;
            } else {
                return false;
            }
        }
        if (cb) {
            cb();
        } else if (build_frame) {
            window.BuildFrame();
        }
        return true;
    }

private:
    std::mutex mutex_;
    std::condition_variable cv_;
    std::deque<std::function<void()>> callbacks_;
    bool frame_requested_ = false;
};

} // namespace

int main() {
    try {
        // 1. Synchronous capability & parsing checks.
        const ln::Capabilities caps = ln::GetCapabilities();
        Require(caps.tcp_dial == ln::CapabilityStatus::Available, "expected tcp_dial Available");
        Require(caps.tcp_listen == ln::CapabilityStatus::Available, "expected tcp_listen Available");
        Require(caps.tls_dial == ln::CapabilityStatus::Available, "expected tls_dial Available");
        Require(caps.tls_listen == ln::CapabilityStatus::Available, "expected tls_listen Available");
        Require(caps.paired_tls_dial == ln::CapabilityStatus::Available, "expected paired_tls_dial Available");
        Require(caps.paired_tls_listen == ln::CapabilityStatus::Available, "expected paired_tls_listen Available");
        Require(caps.web_bridge_host == ln::CapabilityStatus::Unsupported, "expected web_bridge_host Unsupported");
        Require(ln::IsTcpSupported(), "expected IsTcpSupported() == true");
        Require(ln::IsTlsClientSupported(), "expected IsTlsClientSupported() == true");
        Require(ln::IsPairingSupported(), "expected IsPairingSupported() == true");
#if defined(__APPLE__) || defined(_WIN32)
        Require(ln::IsDiscoverySupported(), "expected IsDiscoverySupported() == true on macOS/Windows");
#else
        Require(!ln::IsDiscoverySupported(), "expected IsDiscoverySupported() == false without Avahi");
#endif
        std::cout << "PASS positive: GetCapabilities() & support predicates verified\n";

        // Synchronous negative checks.
        Require(!ln::PeerId::Parse("not-valid-hex").has_value(), "expected nullopt for invalid PeerId hex");
        Require(!ln::PeerId::Parse(std::string(63, 'a')).has_value(), "expected nullopt for short PeerId");
        Require(!ln::PairingCode::Parse("invalid-pairing-code").has_value(), "expected nullopt for malformed PairingCode");
        RequireErr(ln::PairingCode::Decode("not-a-code"),
                   ln::NetworkErrorCode::PairingRejected,
                   "malformed PairingCode::Decode");
        RequireErr(ln::PairingCode::Decode("hln99-" + std::string(96, '0')),
                   ln::NetworkErrorCode::IncompatibleVersion,
                   "unsupported version PairingCode::Decode");
        std::cout << "PASS negative: malformed PeerId and PairingCode checks verified\n";

        // 2. Async mbedTLS-backed pairing & TLS checks.
        AsyncRunState state;
        g_state = &state;
        {
            const huxerui::Application app{SmokeRoot};
            HeadlessPlatform platform;
            platform.Start(app);
            huxerui::UiWindow& window = platform;
            window.SetWindowMetrics({.viewport = {320.0F, 240.0F}});
            window.BuildFrame();

            const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds{15};
            while (true) {
                {
                    std::lock_guard lock(state.mutex);
                    if (state.finished) {
                        break;
                    }
                }
                if (!platform.RunNext(window, deadline)) {
                    state.Finish("timed out waiting for async checks");
                    break;
                }
            }
        }

        std::lock_guard lock(state.mutex);
        Require(state.finished && state.error.empty(),
                state.error.empty() ? "async checks did not complete" : state.error);

        std::cout << "PASS: all localnetwork-consumer checks succeeded\n";
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "FAIL: " << ex.what() << '\n';
        return 1;
    }
}
