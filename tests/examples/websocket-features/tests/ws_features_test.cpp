// ws_features_test.cpp — asserts compat.websocket's `server` and `zlib`
// features, enabled through the member's dependency declaration.
//
//   * `server`: an ix::WebSocketServer runs inside the test process on
//     loopback and echoes every message; the client's round-trips go through
//     the REAL server class (the sibling member tests/examples/websocket uses
//     a hand-written raw-socket echo server precisely so the zero-dep client
//     is tested against something independent — here the point is the opposite:
//     prove the compiled-in server works).
//   * `zlib`: the client enables per-message-deflate. A highly-compressible
//     payload must come back as a message whose str is the full payload but
//     whose wireSize is the COMPRESSED frame bytes (the transport delivers
//     str = decompressed content and wireSize = raw wire payload), which is
//     how a compression round-trip is observable without sniffing the socket.
//
// No network access is required; everything stays on 127.0.0.1.

#include <ixwebsocket/IXConnectionState.h>
#include <ixwebsocket/IXNetSystem.h>
#include <ixwebsocket/IXWebSocket.h>
#include <ixwebsocket/IXWebSocketMessage.h>
#include <ixwebsocket/IXWebSocketServer.h>

#include <chrono>
#include <condition_variable>
#include <cstdint>
#include <cstring>
#include <iostream>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

// Raw sockets only for find_free_port() (a fixed test port would collide on
// shared CI runners; port 0 is the race-free way to ask the OS).
#ifdef _WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
using SockType = SOCKET;
constexpr SockType kInvalidSocket = INVALID_SOCKET;
#else
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
using SockType = int;
constexpr SockType kInvalidSocket = -1;
#endif

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

int find_free_port()
{
#ifdef _WIN32
    WSADATA wsa;
    WSAStartup(MAKEWORD(2, 2), &wsa);
#endif
    SockType s = socket(AF_INET, SOCK_STREAM, 0);
    if (s == kInvalidSocket) return -1;
    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    addr.sin_port = 0;
    if (bind(s, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) != 0)
    {
#ifdef _WIN32
        closesocket(s);
#else
        ::close(s);
#endif
        return -1;
    }
#ifdef _WIN32
    int len = sizeof(addr);
#else
    socklen_t len = sizeof(addr);
#endif
    if (getsockname(s, reinterpret_cast<sockaddr*>(&addr), &len) != 0)
    {
#ifdef _WIN32
        closesocket(s);
#else
        ::close(s);
#endif
        return -1;
    }
    int port = ntohs(addr.sin_port);
#ifdef _WIN32
    closesocket(s);
#else
    ::close(s);
#endif
    return port;
}

// ── Client-side message collector ──────────────────────────────────────────

struct RecvMsg
{
    ix::WebSocketMessageType type;
    std::string str;
    bool binary;
    size_t wireSize;
};

class Collector
{
public:
    void add(const ix::WebSocketMessagePtr& msg)
    {
        std::lock_guard<std::mutex> lk(m_);
        msgs_.push_back(RecvMsg{msg->type, msg->str, msg->binary, msg->wireSize});
        cv_.notify_all();
    }

    template <typename Pred>
    bool wait_for(Pred pred, int timeout_ms)
    {
        std::unique_lock<std::mutex> lk(m_);
        return cv_.wait_for(lk, std::chrono::milliseconds(timeout_ms), [&] { return pred(msgs_); });
    }

private:
    std::mutex m_;
    std::condition_variable cv_;
    std::vector<RecvMsg> msgs_;
};

} // namespace

int main()
{
    std::cout << std::unitbuf;

    bool netOk = ix::initNetSystem();
    check(netOk, "ix::initNetSystem()");

    int port = find_free_port();
    check(port > 0, "found a free loopback port");
    if (port <= 0)
    {
        ix::uninitNetSystem();
        return 1;
    }

    // The `server` feature: a real ix::WebSocketServer.
    ix::WebSocketServer server(port, "127.0.0.1");
    server.setOnClientMessageCallback(
        [](std::shared_ptr<ix::ConnectionState> /*state*/,
           ix::WebSocket& ws,
           const ix::WebSocketMessagePtr& msg)
        {
            if (msg->type == ix::WebSocketMessageType::Message)
            {
                if (msg->binary) ws.sendBinary(msg->str);
                else ws.sendText(msg->str);
            }
        });
    check(server.listenAndStart(), "ix::WebSocketServer listenAndStart()");

    Collector collector;
    ix::WebSocket ws;
    ws.setUrl("ws://127.0.0.1:" + std::to_string(port) + "/");
    ws.enablePerMessageDeflate();
    ws.setOnMessageCallback([&](const ix::WebSocketMessagePtr& msg) { collector.add(msg); });
    ws.start();

    check(collector.wait_for(
              [](const std::vector<RecvMsg>& v) {
                  for (const auto& m : v)
                      if (m.type == ix::WebSocketMessageType::Open) return true;
                  return false;
              },
              5000),
          "client opened against ix::WebSocketServer");

    // Text round-trip through the real server.
    ws.sendText("hello, real server!");
    check(collector.wait_for(
              [](const std::vector<RecvMsg>& v) {
                  for (const auto& m : v)
                      if (m.type == ix::WebSocketMessageType::Message &&
                          m.str == "hello, real server!" && !m.binary)
                          return true;
                  return false;
              },
              5000),
          "text message echoed by ix::WebSocketServer");

    // Binary round-trip through the real server.
    std::string bin("\x00\x01\xfe\xff\x80\x01binary", 10);
    ws.sendBinary(bin);
    check(collector.wait_for(
              [&](const std::vector<RecvMsg>& v) {
                  for (const auto& m : v)
                      if (m.type == ix::WebSocketMessageType::Message && m.str == bin && m.binary)
                          return true;
                  return false;
              },
              5000),
          "binary message echoed by ix::WebSocketServer");

    // The `zlib` feature: per-message-deflate must actually compress on the
    // wire. 64 KiB of a repeated byte compresses to a few hundred bytes; the
    // client delivers the FULL decompressed str but reports wireSize = the raw
    // (compressed) frame payload, so the ratio is observable.
    const size_t kBig = 65536;
    ws.sendText(std::string(kBig, 'a'));
    size_t compressedWire = 0;
    bool gotBig = collector.wait_for(
        [&](const std::vector<RecvMsg>& v) {
            for (const auto& m : v)
                if (m.type == ix::WebSocketMessageType::Message && m.str.size() == kBig &&
                    !m.binary)
                {
                    compressedWire = m.wireSize;
                    return true;
                }
            return false;
        },
        5000);
    check(gotBig, "64 KiB compressible message round-tripped");
    if (gotBig)
    {
        check(compressedWire < 1024,
              "per-message-deflate compressed the wire (wireSize=" + std::to_string(compressedWire) +
                  " << 65536)");
    }

    ws.stop();
    server.stop();
    ix::uninitNetSystem();

    if (g_failures == 0)
    {
        std::cout << "ALL WEBSOCKET-FEATURES ASSERTIONS PASSED\n";
        return 0;
    }
    std::cout << g_failures << " ASSERTION(S) FAILED\n";
    return 1;
}
