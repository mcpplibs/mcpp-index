// Coroutine surface: awaitable/co_spawn/use_awaitable/this_coro over the
// module boundary, including a real timer suspension point.
import std;
import asio;

asio::awaitable<int> answer() {
    auto ex = co_await asio::this_coro::executor;
    asio::steady_timer t(ex, std::chrono::milliseconds(1));
    co_await t.async_wait(asio::use_awaitable);
    co_return 42;
}

int main() {
    asio::io_context io;
    int result = 0;
    asio::co_spawn(io, answer(), [&](std::exception_ptr, int v) { result = v; });
    io.run();
    return result == 42 ? 0 : 1;
}
