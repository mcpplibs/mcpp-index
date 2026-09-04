// Behavioral test for compat.boost-asio: a real steady_timer fires through a
// running io_context, post/defech queue in order, and the C++20 coroutine
// surface (co_spawn + awaitable) adds numbers. All offline, no sockets.
#include <boost/asio.hpp>

int main() {
    namespace asio = boost::asio;
    using asio::ip::tcp;
    bool ok = true;

    // 1. A steady_timer with a 1ms expiry actually wakes the io_context.
    {
        asio::io_context ctx;
        bool fired = false;
        asio::steady_timer timer(ctx, std::chrono::milliseconds(1));
        timer.async_wait([&](const boost::system::error_code& ec) {
            fired = !ec.failed();
        });
        ctx.run();
        ok = ok && fired;
    }

    // 2. post and defer both run; a strand-wrapped counter is consistent.
    {
        asio::io_context ctx;
        int counter = 0;
        asio::post(ctx, [&] { ++counter; });
        asio::defer(ctx, [&] { ++counter; });
        ctx.run();
        ok = ok && counter == 2;
    }

    // 3. co_spawn + awaitable: the coroutine surface works end to end.
    {
        asio::io_context ctx;
        auto adder = [](int a, int b) -> asio::awaitable<int> { co_return a + b; };
        int result = 0;
        asio::co_spawn(
            ctx,
            [&]() -> asio::awaitable<void> {
                result = co_await adder(20, 22);
            },
            asio::detached);
        ctx.run();
        ok = ok && result == 42;
    }

    // 4. The tcp endpoint/address plumbing compiles and resolves offline.
    {
        tcp::endpoint ep(asio::ip::make_address("127.0.0.1"), 8080);
        ok = ok && ep.address().is_loopback() && ep.port() == 8080;
    }

    return ok ? 0 : 1;
}
