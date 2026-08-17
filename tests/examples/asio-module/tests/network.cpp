// TCP (acceptor/socket, async_read/async_write), the free asio::async_connect
// over a sequence of candidate endpoints, and UDP (datagram send/receive) over
// the imported module surface.
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
    if (udp_failure || !receive_done || !send_done) return 8;

    // --- free asio::async_connect over a candidate sequence ---
    //
    // The member socket.async_connect above takes ONE endpoint; the free
    // function takes a range and tries each in turn, which is what a consumer
    // hands a resolver's results_type to. Assert that semantics directly:
    // an unreachable candidate first, the live acceptor second. Kept hermetic
    // (no DNS) so it cannot fail for reasons that have nothing to do with the
    // module surface.
    asio::io_context connect_io;
    asio::ip::tcp::acceptor live(connect_io, {asio::ip::address_v4::loopback(), 0});
    asio::ip::tcp::socket accepted_side(connect_io);
    asio::ip::tcp::socket connecting(connect_io);
    live.async_accept(accepted_side, [](const std::error_code&) {});

    const std::vector<asio::ip::tcp::endpoint> candidates{
        // Port 1 on loopback: nothing listens there, so this candidate is
        // refused and async_connect must move on rather than give up.
        {asio::ip::address_v4::loopback(), 1},
        live.local_endpoint(),
    };

    std::error_code connect_ec{std::make_error_code(std::errc::not_supported)};
    asio::ip::tcp::endpoint chosen;
    bool connect_done = false;

    asio::async_connect(connecting, candidates,
        [&](const std::error_code& ec, const asio::ip::tcp::endpoint& ep) {
            connect_ec = ec;
            chosen = ep;
            connect_done = true;
        });

    connect_io.run();
    if (!connect_done || connect_ec) return 9;
    if (chosen != live.local_endpoint()) return 10;   // it must have skipped port 1
    if (!connecting.is_open()) return 11;

    return 0;
}
