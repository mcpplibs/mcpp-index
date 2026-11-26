import std;
import huxerui;
import huxerui.terminal;

namespace ht = huxerui::terminal;

namespace {

void Require(bool condition, std::string_view message) {
    if (!condition) {
        throw std::runtime_error(std::string(message));
    }
}

struct AsyncState {
    std::mutex mutex;
    std::optional<ht::TerminalSession> view_session;
    bool finished = false;
    std::string error;

    void Finish(std::string msg = {}) {
        std::lock_guard lock(mutex);
        finished = true;
        error = std::move(msg);
    }
};

AsyncState* g_state = nullptr;

class MemoryBackend final : public ht::TerminalBackend {
public:
    explicit MemoryBackend(std::vector<std::string> chunks) : chunks_(std::move(chunks)) {}

    huxerui::Task<ht::TerminalResult<ht::TerminalRead>> ReadAsync(std::size_t) override {
        if (index_ >= chunks_.size()) {
            co_return ht::TerminalResult<ht::TerminalRead>::Success(
                ht::TerminalExit{ht::TerminalExitReason::Exited, 7});
        }
        const std::string& text = chunks_[index_++];
        huxerui::Bytes bytes(text.size());
        std::memcpy(bytes.data(), text.data(), text.size());
        co_return ht::TerminalResult<ht::TerminalRead>::Success(std::move(bytes));
    }

    huxerui::Task<ht::TerminalResult<void>> WriteAsync(huxerui::Bytes) override {
        co_return ht::TerminalResult<void>::Success();
    }

    huxerui::Task<ht::TerminalResult<void>> ResizeAsync(ht::TerminalSize size) override {
        seen_sizes.push_back(size);
        co_return ht::TerminalResult<void>::Success();
    }

    huxerui::Task<ht::TerminalResult<void>> CloseAsync() override {
        closed = true;
        co_return ht::TerminalResult<void>::Success();
    }

    std::vector<ht::TerminalSize> seen_sizes;
    bool closed = false;

private:
    std::vector<std::string> chunks_;
    std::size_t index_ = 0;
};

huxerui::Task<void> RunChecks() {
    try {
        // Negative check: invalid command name rejected cleanly.
        auto bad_cmd = ht::CreateCommandSession({
            .prompt = "$ ",
            .commands = {{.name = ""}},
        });
        Require(!bad_cmd.Succeeded(), "empty command name must fail");
        Require(bad_cmd.Error().code == ht::TerminalErrorCode::InvalidConfiguration,
                "expected InvalidConfiguration for empty command name");
        std::cout << "PASS negative: empty command name rejected\n";

        // Positive check: command session creation & close.
        auto cmd_res = ht::CreateCommandSession({
            .prompt = "$ ",
            .commands = {{
                .name = "ping",
                .handler = [](ht::TerminalCommandContext ctx) -> huxerui::Task<int> {
                    (void)co_await ctx.output.WriteAsync("pong\n");
                    co_return 0;
                },
            }},
        });
        Require(cmd_res.Succeeded(), "CreateCommandSession failed");
        auto cmd_session = std::move(cmd_res).Value();
        Require(cmd_session.Snapshot().status == ht::TerminalStatus::Open, "command session expected Open");
        {
            std::lock_guard lock(g_state->mutex);
            g_state->view_session = cmd_session;
        }
        std::cout << "PASS positive: CreateCommandSession Open\n";

        // Positive check: transport session processing ANSI + UTF-8 multibyte text through libvterm.
        auto transport_res = co_await ht::OpenTransportAsync(std::make_unique<MemoryBackend>(std::vector<std::string>{
            "\x1b[32mhello-\xE4\xB8\xAD\xE6\x96\x87\x1b[0m\r\n",
            "line-2\r\n",
        }));
        Require(transport_res.Succeeded(), "OpenTransportAsync failed");
        auto transport = std::move(transport_res).Value();
        const auto wait_end = std::chrono::steady_clock::now() + std::chrono::seconds{5};
        while ((transport.Snapshot().status == ht::TerminalStatus::Open ||
                transport.Snapshot().status == ht::TerminalStatus::Closing) &&
               std::chrono::steady_clock::now() < wait_end) {
            co_await huxerui::Delay(std::chrono::milliseconds{10});
        }
        const auto tsnap = transport.Snapshot();
        Require(tsnap.status == ht::TerminalStatus::Exited,
                "transport expected Exited, got status=" + std::to_string(static_cast<int>(tsnap.status)));
        Require(tsnap.exit.has_value() && tsnap.exit->code == 7, "transport exit code expected 7");
        (void)co_await transport.CloseAsync();
        std::cout << "PASS positive: OpenTransportAsync Exited with code 7\n";

#if defined(__linux__) && !defined(__ANDROID__)
        // Positive check: real POSIX PTY shell (-lutil openpty + waitpid exit code propagation).
        auto shell_res = co_await ht::OpenShellAsync({
            .executable = "/bin/sh",
            .arguments = {"-c", "printf 'PTY_OK\\n'; exit 42"},
        });
        Require(shell_res.Succeeded(), "OpenShellAsync(/bin/sh) failed");
        auto shell = std::move(shell_res).Value();
        for (int i = 0; i < 200 &&
             (shell.Snapshot().status == ht::TerminalStatus::Open ||
              shell.Snapshot().status == ht::TerminalStatus::Closing);
             ++i) {
            co_await huxerui::Delay(std::chrono::milliseconds{10});
        }
        const auto ssnap = shell.Snapshot();
        Require(ssnap.status == ht::TerminalStatus::Exited, "shell expected Exited");
        Require(ssnap.exit.has_value() && ssnap.exit->code == 42, "shell exit code expected 42");
        (void)co_await shell.CloseAsync();
        std::cout << "PASS positive: OpenShellAsync PTY Exited with code 42\n";
#endif

        auto closed = co_await cmd_session.CloseAsync();
        Require(closed.Succeeded(), "cmd_session CloseAsync failed");
        Require(cmd_session.Snapshot().status == ht::TerminalStatus::Closed, "expected Closed status");

        g_state->Finish();
    } catch (const std::exception& ex) {
        g_state->Finish(ex.what());
    } catch (...) {
        g_state->Finish("unknown exception in RunChecks");
    }
}

huxerui::View SmokeRoot() {
    const huxerui::TaskScope tasks = huxerui::UseTaskScope();
    huxerui::Lifecycle([tasks] {
        tasks.Launch([]() -> huxerui::Task<void> { co_await RunChecks(); });
    });
    std::optional<ht::TerminalSession> session;
    {
        std::lock_guard lock(g_state->mutex);
        session = g_state->view_session;
    }
    if (session) {
        return ht::Terminal(*session).With(huxerui::Grow());
    }
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
        AsyncState state;
        g_state = &state;
        {
            const huxerui::Application app{
                SmokeRoot,
                {.application_hooks = {ht::Install}},
            };
            HeadlessPlatform platform;
            platform.Start(app);
            huxerui::UiWindow& window = platform;
            window.SetWindowMetrics({.viewport = {480.0F, 240.0F}});
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
                    state.Finish("timed out waiting for terminal checks");
                    break;
                }
            }
        }
        std::lock_guard lock(state.mutex);
        Require(state.finished && state.error.empty(),
                state.error.empty() ? "terminal checks did not complete" : state.error);
        std::cout << "PASS: all terminal-consumer checks succeeded\n";
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "FAIL: " << ex.what() << '\n';
        return 1;
    }
}
