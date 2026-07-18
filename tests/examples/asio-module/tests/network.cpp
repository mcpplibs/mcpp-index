// TCP (acceptor/socket, async_read/async_write) and UDP (datagram send/receive)
// over the module surface. Mirrors tests/examples/asio/tests/network.cpp.
import std;
import asio;

int main() {
    using namespace std::chrono_literals;

    // --- TCP echo ---
    asio::io_context io;
    asio::ip::tcp::acceptor acceptor(io, {asio::ip::address_v4::loopback(), 0});
    asio::ip::tcp::socket server(io);
    asio::ip::tcp::socket client(io);
    asio::steady_timer deadline(io, 5s);

    const std::string ping = "ping";
    const std::string pong = "pong";
    std::array<char, 4> server_data{};
    std::array<char, 4> client_data{};
    bool accepted = false;
    bool connected = false;
    bool tcp_done = false;
    bool timed_out = false;
    int failure = 0;

    auto fail = [&](int code) {
        if (failure == 0) failure = code;
        std::error_code ignored;
        acceptor.close(ignored);
        server.close(ignored);
        client.close(ignored);
        deadline.cancel();
    };

    deadline.async_wait([&](const std::error_code& ec) {
        if (!ec) {
            timed_out = true;
            fail(90);
        }
    });

    acceptor.async_accept(server, [&](const std::error_code& ec) {
        if (ec) return fail(1);
        accepted = true;
        asio::async_read(server, asio::buffer(server_data),
            [&](const std::error_code& read_ec, std::size_t n) {
                if (read_ec || n != ping.size()
                    || std::string(server_data.data(), n) != ping) return fail(2);
                asio::async_write(server, asio::buffer(pong),
                    [&](const std::error_code& write_ec, std::size_t written) {
                        if (write_ec || written != pong.size()) fail(3);
                    });
            });
    });

    client.async_connect(
        {asio::ip::address_v4::loopback(), acceptor.local_endpoint().port()},
        [&](const std::error_code& ec) {
            if (ec) return fail(4);
            connected = true;
            asio::async_write(client, asio::buffer(ping),
                [&](const std::error_code& write_ec, std::size_t written) {
                    if (write_ec || written != ping.size()) return fail(5);
                    asio::async_read(client, asio::buffer(client_data),
                        [&](const std::error_code& read_ec, std::size_t n) {
                            if (read_ec || n != pong.size()
                                || std::string(client_data.data(), n) != pong) return fail(6);
                            tcp_done = true;
                            deadline.cancel();
                        });
                });
        });

    io.run();
    if (failure || timed_out || !accepted || !connected || !tcp_done) return failure ? failure : 7;

    // --- UDP datagram ---
    asio::io_context udp_io;
    asio::ip::udp::socket receiver(udp_io, {asio::ip::address_v4::loopback(), 0});
    asio::ip::udp::socket sender(udp_io, {asio::ip::address_v4::loopback(), 0});
    const std::string datagram = "asio-udp";
    std::array<char, 8> received{};
    asio::ip::udp::endpoint remote;
    bool receive_done = false;
    bool send_done = false;
    std::error_code udp_failure;

    receiver.async_receive_from(asio::buffer(received), remote,
        [&](const std::error_code& ec, std::size_t n) {
            udp_failure = ec;
            receive_done = !ec && n == datagram.size()
                && std::string(received.data(), n) == datagram;
        });
    sender.async_send_to(asio::buffer(datagram), receiver.local_endpoint(),
        [&](const std::error_code& ec, std::size_t n) {
            if (ec) udp_failure = ec;
            send_done = !ec && n == datagram.size();
        });

    udp_io.run();
    return !udp_failure && receive_done && send_done ? 0 : 8;
}
