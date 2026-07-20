// Experimental channel/concurrent_channel/use_promise over the module surface.
import std;
import asio;

int main() {
    asio::io_context io;

    asio::experimental::channel<void(std::error_code, std::string)> ch(io, 1);
    if (!ch.try_send(std::error_code{}, "channel")) return 1;
    std::string channel_value;
    std::error_code channel_error;
    ch.async_receive([&](std::error_code ec, std::string value) {
        channel_error = ec;
        channel_value = std::move(value);
    });

    asio::experimental::concurrent_channel<void(std::error_code, int)> concurrent(io, 1);
    if (!concurrent.try_send(std::error_code{}, 42)) return 2;
    int concurrent_value = 0;
    std::error_code concurrent_error;
    concurrent.async_receive([&](std::error_code ec, int value) {
        concurrent_error = ec;
        concurrent_value = value;
    });

    auto promised = asio::post(io, asio::experimental::use_promise);
    bool promise_completed = false;
    promised([&] { promise_completed = true; });

    io.run();

    return !channel_error && channel_value == "channel"
        && !concurrent_error && concurrent_value == 42
        && promise_completed ? 0 : 3;
}
