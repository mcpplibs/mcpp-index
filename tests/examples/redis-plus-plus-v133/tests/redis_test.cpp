// redis_test.cpp — offline behavioral test for compat.redis-plus-plus.
//
// No redis-server binary and no network access: this test runs a minimal RESP
// server inside the process (raw loopback sockets, same platform abstraction
// as the websocket member) and drives the sw::redis::Redis sync client against
// it. That exercises the full stack the package must get right:
//   * both static libs actually link (redis++ + hiredis),
//   * hiredis connects and speaks the RESP protocol (PING -> +PONG),
//   * redis++ formats commands (SET -> +OK) and parses replies back to C++.
#include <sw/redis++/redis++.h>

#include <atomic>
#include <chrono>
#include <cstdint>
#include <iostream>
#include <string>
#include <string_view>
#include <thread>

// ── Platform socket abstraction (same as tests/examples/websocket) ─────────

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

// ── Minimal RESP server: answers PING with +PONG, SET with +OK ─────────────

class RespServer
{
public:
    ~RespServer()
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

private:
    void run()
    {
        SockType s = accept(listener, nullptr, nullptr);
        if (s == kInvalidSocket) return;
        client = s;
        set_recv_timeout(client, 5000);

        char buf[1024];
        int served = 0;
        // The client keeps the connection open for the whole test; serve a
        // handful of commands, then stop so the client's next read fails
        // cleanly instead of hanging.
        while (served < 8) {
            const int n = static_cast<int>(recv(client, buf, sizeof(buf) - 1, 0));
            if (n <= 0) break;
            const std::string_view req(buf, static_cast<size_t>(n));
            if (req.find("PING") != std::string_view::npos) {
                static constexpr char kPong[] = "+PONG\r\n";
                send(client, kPong, static_cast<int>(sizeof(kPong) - 1), 0);
                ++served;
            } else if (req.find("SET") != std::string_view::npos) {
                static constexpr char kOk[] = "+OK\r\n";
                send(client, kOk, static_cast<int>(sizeof(kOk) - 1), 0);
                ++served;
            }
        }
    }

    SockType listener = kInvalidSocket;
    SockType client = kInvalidSocket;
    std::thread thread;
};

int main()
{
    RespServer server;
    if (!server.start()) {
        std::cerr << "failed to start RESP server\n";
        return 1;
    }

    sw::redis::ConnectionOptions opts;
    opts.host = "127.0.0.1";
    opts.port = server.port;
    opts.connect_timeout = std::chrono::milliseconds(3000);
    opts.socket_timeout = std::chrono::milliseconds(3000);

    try {
        sw::redis::Redis redis(opts);

        const std::string pong = redis.ping();
        if (pong != "PONG") {
            std::cerr << "unexpected PING reply: '" << pong << "'\n";
            return 2;
        }

        if (!redis.set("mcpp", "redis-plus-plus")) {
            std::cerr << "SET did not return OK\n";
            return 3;
        }

        std::cout << "OK: PING -> " << pong << ", SET -> OK\n";
        return 0;
    } catch (const sw::redis::Error &e) {
        std::cerr << "redis error: " << e.what() << "\n";
        return 4;
    }
}
