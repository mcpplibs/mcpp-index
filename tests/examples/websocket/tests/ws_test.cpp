// ws_test.cpp — self-contained WebSocket client test for compat.websocket.
//
// IXWebSocket is a pure client here (the descriptor builds the client TUs
// only), so this test brings its OWN minimal RFC 6455 echo server, built on
// raw sockets, and drives the ix::WebSocket client against 127.0.0.1:0. That
// exercises the real wire behaviors the client must implement — the HTTP
// upgrade handshake (the client validates Sec-WebSocket-Accept), client-side
// masking, fragmentation (the server replies with a fragmented message and the
// client must reassemble it), ping/pong in both directions, and the closing
// handshake. No network access and no server process are required: everything
// stays inside one process on the loopback interface.
//
// The server is intentionally independent of the library under test: it
// computes Sec-WebSocket-Accept with its own SHA-1 + base64 and implements the
// framing itself, so a client bug in any of those areas fails the assertions
// below rather than being hidden by shared code.

#include <ixwebsocket/IXNetSystem.h>
#include <ixwebsocket/IXWebSocket.h>
#include <ixwebsocket/IXWebSocketMessage.h>

#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstdint>
#include <cstring>
#include <iostream>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

namespace
{

int g_failures = 0;

void check(bool ok, const std::string& what)
{
    if (ok)
    {
        std::cout << "  ok: " << what << "\n";
    }
    else
    {
        std::cout << "  FAIL: " << what << "\n";
        ++g_failures;
    }
}

// ── SHA-1 and base64 (for Sec-WebSocket-Accept) ────────────────────────────
// Compact reference implementations, independent of the library under test.

std::string base64_encode(const std::string& in)
{
    static const char tbl[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    std::string out;
    unsigned val = 0;
    int valb = -6;
    for (unsigned char c : in)
    {
        val = (val << 8) | c;
        valb += 8;
        while (valb >= 0)
        {
            out.push_back(tbl[(val >> valb) & 0x3F]);
            valb -= 6;
        }
    }
    if (valb > -6) out.push_back(tbl[((val << 8) >> (valb + 8)) & 0x3F]);
    while (out.size() % 4) out.push_back('=');
    return out;
}

std::string sha1_binary(const std::string& msg)
{
    uint32_t h0 = 0x67452301, h1 = 0xEFCDAB89, h2 = 0x98BADCFE, h3 = 0x10325476,
             h4 = 0xC3D2E1F0;
    uint64_t bitlen = static_cast<uint64_t>(msg.size()) * 8;
    std::string m = msg;
    m.push_back(static_cast<char>(0x80));
    while (m.size() % 64 != 56) m.push_back('\0');
    for (int i = 7; i >= 0; --i)
        m.push_back(static_cast<char>((bitlen >> (i * 8)) & 0xFF));

    for (size_t i = 0; i < m.size(); i += 64)
    {
        uint32_t w[80];
        for (int j = 0; j < 16; ++j)
            w[j] = (static_cast<uint32_t>(static_cast<unsigned char>(m[i + j * 4])) << 24) |
                   (static_cast<uint32_t>(static_cast<unsigned char>(m[i + j * 4 + 1])) << 16) |
                   (static_cast<uint32_t>(static_cast<unsigned char>(m[i + j * 4 + 2])) << 8) |
                   (static_cast<uint32_t>(static_cast<unsigned char>(m[i + j * 4 + 3])));
        for (int j = 16; j < 80; ++j)
        {
            uint32_t x = w[j - 3] ^ w[j - 8] ^ w[j - 14] ^ w[j - 16];
            w[j] = (x << 1) | (x >> 31);
        }
        uint32_t a = h0, b = h1, c = h2, d = h3, e = h4;
        for (int j = 0; j < 80; ++j)
        {
            uint32_t f, k;
            if (j < 20)
            {
                f = (b & c) | ((~b) & d);
                k = 0x5A827999;
            }
            else if (j < 40)
            {
                f = b ^ c ^ d;
                k = 0x6ED9EBA1;
            }
            else if (j < 60)
            {
                f = (b & c) | (b & d) | (c & d);
                k = 0x8F1BBCDC;
            }
            else
            {
                f = b ^ c ^ d;
                k = 0xCA62C1D6;
            }
            uint32_t tmp = ((a << 5) | (a >> 27)) + f + e + k + w[j];
            e = d;
            d = c;
            c = (b << 30) | (b >> 2);
            b = a;
            a = tmp;
        }
        h0 += a;
        h1 += b;
        h2 += c;
        h3 += d;
        h4 += e;
    }
    std::string out(20, '\0');
    const uint32_t hs[5] = {h0, h1, h2, h3, h4};
    for (int i = 0; i < 5; ++i)
        for (int j = 0; j < 4; ++j)
            out[i * 4 + j] = static_cast<char>((hs[i] >> ((3 - j) * 8)) & 0xFF);
    return out;
}

// ── Platform socket abstraction ────────────────────────────────────────────

#ifdef _WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
using SockType = SOCKET;
constexpr SockType kInvalidSocket = INVALID_SOCKET;
using AddrLenType = int;
#else
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>
using SockType = int;
constexpr SockType kInvalidSocket = -1;
using AddrLenType = socklen_t;
#endif

void init_sockets()
{
#ifdef _WIN32
    WSADATA wsa;
    WSAStartup(MAKEWORD(2, 2), &wsa);
#endif
}

void close_socket(SockType s)
{
#ifdef _WIN32
    closesocket(s);
#else
    ::close(s);
#endif
}

// Safety net: any read that stalls this long makes the server thread return so
// the test fails cleanly instead of hanging the process (and, on CI, a runner).
void set_recv_timeout(SockType s, int ms)
{
#ifdef _WIN32
    DWORD t = static_cast<DWORD>(ms);
    setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, reinterpret_cast<const char*>(&t), sizeof(t));
#else
    timeval tv{};
    tv.tv_sec = ms / 1000;
    tv.tv_usec = (ms % 1000) * 1000;
    setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
#endif
}

// ── Minimal RFC 6455 echo server ───────────────────────────────────────────

class EchoServer
{
public:
    ~EchoServer()
    {
        if (client != kInvalidSocket) close_socket(client);
        if (listener != kInvalidSocket) close_socket(listener);
        if (thread.joinable()) thread.join();
    }

    bool start()
    {
        init_sockets();
        listener = socket(AF_INET, SOCK_STREAM, 0);
        if (listener == kInvalidSocket) return false;
        int one = 1;
#ifdef _WIN32
        setsockopt(listener, SOL_SOCKET, SO_REUSEADDR,
                   reinterpret_cast<const char*>(&one), sizeof(one));
#else
        setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));
#endif
        sockaddr_in addr{};
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
        addr.sin_port = 0; // ephemeral
        if (bind(listener, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) != 0) return false;
        AddrLenType alen = sizeof(addr);
        getsockname(listener, reinterpret_cast<sockaddr*>(&addr), &alen);
        port = ntohs(addr.sin_port);
        if (listen(listener, 1) != 0) return false;
        thread = std::thread([this] { run(); });
        return true;
    }

    int port = 0;
    std::atomic<bool> server_saw_masked{false};
    std::atomic<bool> server_saw_pong{false};
    std::atomic<bool> server_saw_close{false};

private:
    SockType listener = kInvalidSocket;
    SockType client = kInvalidSocket;
    std::thread thread;

    // Receive exactly n bytes; false on timeout/error/disconnect.
    bool recv_n(char* buf, size_t n)
    {
        size_t got = 0;
        while (got < n)
        {
            int r = recv(client, buf + got, static_cast<int>(n - got), 0);
            if (r <= 0) return false;
            got += static_cast<size_t>(r);
        }
        return true;
    }

    std::string lower(std::string s)
    {
        for (char& c : s)
            if (c >= 'A' && c <= 'Z') c = static_cast<char>(c + ('a' - 'A'));
        return s;
    }

    bool handshake()
    {
        std::string req;
        char tmp[1024];
        while (req.find("\r\n\r\n") == std::string::npos)
        {
            int r = recv(client, tmp, sizeof(tmp), 0);
            if (r <= 0) return false;
            req.append(tmp, static_cast<size_t>(r));
            if (req.size() > 65536) return false;
        }
        std::string key;
        std::string rest = req;
        for (;;)
        {
            size_t eol = rest.find("\r\n");
            if (eol == std::string::npos) break;
            std::string line = rest.substr(0, eol);
            rest = rest.substr(eol + 2);
            size_t colon = line.find(':');
            if (colon == std::string::npos) continue;
            std::string name = lower(line.substr(0, colon));
            std::string value = line.substr(colon + 1);
            size_t b = value.find_first_not_of(" \t");
            size_t e = value.find_last_not_of(" \t");
            value = (b == std::string::npos) ? std::string() : value.substr(b, e - b + 1);
            if (name == "sec-websocket-key") key = value;
        }
        if (key.empty()) return false;

        const std::string guid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
        std::string accept = base64_encode(sha1_binary(key + guid));

        std::string resp = "HTTP/1.1 101 Switching Protocols\r\n"
                           "Upgrade: websocket\r\n"
                           "Connection: Upgrade\r\n"
                           "Sec-WebSocket-Accept: " + accept + "\r\n"
                           "\r\n";
        size_t off = 0;
        while (off < resp.size())
        {
            int w = send(client, resp.data() + off, static_cast<int>(resp.size() - off), 0);
            if (w <= 0) return false;
            off += static_cast<size_t>(w);
        }
        return true;
    }

    bool send_frame(uint8_t opcode, const std::string& payload, bool fin = true)
    {
        // Server->client frames are NOT masked (RFC 6455 §5.1).
        std::string frame;
        frame.push_back(static_cast<char>((fin ? 0x80 : 0x00) | (opcode & 0x0F)));
        size_t n = payload.size();
        if (n < 126)
        {
            frame.push_back(static_cast<char>(n));
        }
        else if (n <= 0xFFFF)
        {
            frame.push_back(static_cast<char>(126));
            frame.push_back(static_cast<char>((n >> 8) & 0xFF));
            frame.push_back(static_cast<char>(n & 0xFF));
        }
        else
        {
            frame.push_back(static_cast<char>(127));
            for (int i = 7; i >= 0; --i)
                frame.push_back(static_cast<char>((n >> (i * 8)) & 0xFF));
        }
        frame += payload;
        size_t off = 0;
        while (off < frame.size())
        {
            int w = send(client, frame.data() + off, static_cast<int>(frame.size() - off), 0);
            if (w <= 0) return false;
            off += static_cast<size_t>(w);
        }
        return true;
    }

    bool recv_frame(uint8_t& opcode, std::string& payload)
    {
        char hdr[2];
        if (!recv_n(hdr, 2)) return false;
        bool fin = (hdr[0] & 0x80) != 0;
        (void) fin;
        opcode = static_cast<uint8_t>(hdr[0] & 0x0F);
        bool masked = (hdr[1] & 0x80) != 0;
        if (masked) server_saw_masked = true;
        size_t len = static_cast<size_t>(hdr[1] & 0x7F);
        if (len == 126)
        {
            char ext[2];
            if (!recv_n(ext, 2)) return false;
            len = (static_cast<size_t>(static_cast<unsigned char>(ext[0])) << 8) |
                  static_cast<size_t>(static_cast<unsigned char>(ext[1]));
        }
        else if (len == 127)
        {
            char ext[8];
            if (!recv_n(ext, 8)) return false;
            len = 0;
            for (int i = 0; i < 8; ++i)
                len = (len << 8) | static_cast<size_t>(static_cast<unsigned char>(ext[i]));
        }
        char key[4] = {0, 0, 0, 0};
        if (masked && !recv_n(key, 4)) return false;
        payload.resize(len);
        if (len && !recv_n(&payload[0], len)) return false;
        if (masked)
            for (size_t i = 0; i < len; ++i)
                payload[i] = static_cast<char>(payload[i] ^ key[i % 4]);
        return true;
    }

    void run()
    {
        sockaddr_in peer{};
        AddrLenType plen = sizeof(peer);
        client = accept(listener, reinterpret_cast<sockaddr*>(&peer), &plen);
        if (client == kInvalidSocket) return;
        set_recv_timeout(client, 10000);
        if (!handshake()) return;

        for (;;)
        {
            uint8_t opcode = 0;
            std::string payload;
            if (!recv_frame(opcode, payload)) return;

            switch (opcode)
            {
                case 0x9: // ping -> pong
                    if (!send_frame(0xA, payload)) return;
                    break;
                case 0xA: // pong (answer to our ping)
                    server_saw_pong = true;
                    break;
                case 0x8: // close -> echo close code, then shut down
                {
                    server_saw_close = true;
                    std::string close_payload = payload;
                    if (close_payload.size() < 2) close_payload = std::string("\x03\xe8", 2); // 1000
                    if (!send_frame(0x8, close_payload)) return;
                    return;
                }
                case 0x1: // text
                case 0x2: // binary
                {
                    if (payload == "FRAG")
                    {
                        // Reply with a fragmented text message.
                        if (!send_frame(0x1, "fragA-", false)) return;
                        if (!send_frame(0x0, "fragB-", false)) return;
                        if (!send_frame(0x0, "fragC!", true)) return;
                    }
                    else if (payload == "PINGME")
                    {
                        // Ask the client to answer a ping with a pong.
                        if (!send_frame(0x9, "server-ping", true)) return;
                    }
                    else
                    {
                        if (!send_frame(opcode, payload, true)) return;
                    }
                    break;
                }
                default:
                    // continuation frames and anything else: ignore.
                    break;
            }
        }
    }
};

// ── Client-side message collector ──────────────────────────────────────────

struct RecvMsg
{
    ix::WebSocketMessageType type;
    std::string str;
    bool binary;
};

class Collector
{
public:
    void add(const ix::WebSocketMessagePtr& msg)
    {
        std::lock_guard<std::mutex> lk(m_);
        msgs_.push_back(RecvMsg{msg->type, msg->str, msg->binary});
        cv_.notify_all();
    }

    // Wait up to timeout_ms for a predicate over the collected messages.
    template <typename Pred>
    bool wait_for(Pred pred, int timeout_ms)
    {
        std::unique_lock<std::mutex> lk(m_);
        return cv_.wait_for(lk, std::chrono::milliseconds(timeout_ms), [&] { return pred(msgs_); });
    }

    bool has_type(ix::WebSocketMessageType t) const
    {
        std::lock_guard<std::mutex> lk(m_);
        for (const auto& m : msgs_)
            if (m.type == t) return true;
        return false;
    }

private:
    mutable std::mutex m_;
    std::condition_variable cv_;
    std::vector<RecvMsg> msgs_;
};

} // namespace

int main()
{
    // Unbuffered: `mcpp test` runs this piped, and a hang without visible
    // progress is indistinguishable from a slow pass otherwise.
    std::cout << std::unitbuf;

    EchoServer server;
    if (!server.start())
    {
        std::cout << "FAIL: could not start echo server\n";
        return 1;
    }
    std::cout << "server listening on 127.0.0.1:" << server.port << "\n";

    bool netOk = ix::initNetSystem();
    check(netOk, "ix::initNetSystem()");

    Collector collector;
    ix::WebSocket ws;
    ws.setUrl("ws://127.0.0.1:" + std::to_string(server.port) + "/");
    ws.setOnMessageCallback([&](const ix::WebSocketMessagePtr& msg) { collector.add(msg); });
    ws.start();

    // 1. Handshake: the client must validate our Sec-WebSocket-Accept and open.
    check(collector.wait_for(
              [](const std::vector<RecvMsg>& v) {
                  for (const auto& m : v)
                      if (m.type == ix::WebSocketMessageType::Open) return true;
                  return false;
              },
              5000),
          "client opened after HTTP upgrade handshake");

    // 2. Text echo — by the time the server echoes, it has seen the client's
    //    masked frames (RFC 6455 §5.1 requires client->server masking).
    ws.sendText("hello, ws!");
    check(collector.wait_for(
              [](const std::vector<RecvMsg>& v) {
                  for (const auto& m : v)
                      if (m.type == ix::WebSocketMessageType::Message && m.str == "hello, ws!" &&
                          !m.binary)
                          return true;
                  return false;
              },
              5000),
          "text message echoed back");
    check(server.server_saw_masked.load(), "client frames arrive masked");

    // 3. Binary echo (arbitrary bytes, not valid UTF-8).
    std::string bin("\x00\x01\x02\xfe\xff\x80hello", 9);
    ws.sendBinary(bin);
    check(collector.wait_for(
              [&](const std::vector<RecvMsg>& v) {
                  for (const auto& m : v)
                      if (m.type == ix::WebSocketMessageType::Message && m.str == bin && m.binary)
                          return true;
                  return false;
              },
              5000),
          "binary message echoed back byte-for-byte");

    // 4. Client ping -> server pong -> client surfaces the Pong message.
    ws.ping("ping-payload");
    check(collector.wait_for(
              [](const std::vector<RecvMsg>& v) {
                  for (const auto& m : v)
                      if (m.type == ix::WebSocketMessageType::Pong && m.str == "ping-payload")
                          return true;
                  return false;
              },
              5000),
          "ping/pong round-trip (client-initiated)");

    // 5. Server ping -> client auto-pong (enablePong default is on).
    ws.sendText("PINGME");
    {
        auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(5);
        while (!server.server_saw_pong.load() && std::chrono::steady_clock::now() < deadline)
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }
    check(server.server_saw_pong.load(), "client auto-answered a server ping with a pong");

    // 6. Fragmentation: server replies with a fragmented text message, the
    //    client must reassemble it into one Message (Fragment frames precede it).
    ws.sendText("FRAG");
    check(collector.wait_for(
              [&](const std::vector<RecvMsg>& v) {
                  bool sawFragment = false;
                  for (const auto& m : v)
                  {
                      if (m.type == ix::WebSocketMessageType::Fragment) sawFragment = true;
                      if (m.type == ix::WebSocketMessageType::Message && m.str == "fragA-fragB-fragC!")
                          return true;
                  }
                  (void) sawFragment;
                  return false;
              },
              5000),
          "fragmented server message reassembled by the client");
    check(collector.has_type(ix::WebSocketMessageType::Fragment),
          "fragment frames surfaced before the reassembled message");

    // 7. Close handshake: stop() initiates the close (via its internal
    //    close()), waits for the server's close reply and for the client thread
    //    to exit, and sets `_stop` so the run loop cannot fall into the
    //    automatic reconnection that a CLOSED state would otherwise trigger
    //    (IXWebSocket enables automatic reconnection by default). The Close
    //    message is delivered to the collector before stop() returns.
    ws.stop();
    check(collector.has_type(ix::WebSocketMessageType::Close),
          "closing handshake completed (client saw Close)");
    check(server.server_saw_close.load(), "server received the client's close frame");

    ix::uninitNetSystem();

    if (g_failures == 0)
    {
        std::cout << "ALL WEBSOCKET ASSERTIONS PASSED\n";
        return 0;
    }
    std::cout << g_failures << " ASSERTION(S) FAILED\n";
    return 1;
}
