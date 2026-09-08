// Behavioral test — compat.libcoro actually schedules coroutines.
//
// Every assertion here needs a resumed coroutine to be true, so a package that
// compiled the headers but linked none of the eight core TUs fails: the
// thread_pool, event, mutex and sync_wait entry points all live in those.
//
// Networking is deliberately untouched — see the descriptor. `coro/coro.hpp`
// is NOT included for the same reason; it opens the net/ headers behind
// LIBCORO_FEATURE_NETWORKING, which this build does not define.
//
// No `import std;`: libcoro's headers are textual over the standard library.
#include <coro/event.hpp>
#include <coro/generator.hpp>
#include <coro/mutex.hpp>
#include <coro/sync_wait.hpp>
#include <coro/task.hpp>
#include <coro/thread_pool.hpp>
#include <coro/when_all.hpp>

#include <atomic>
#include <cstdio>
#include <vector>

int main() {
    // A task returning a value, driven to completion synchronously.
    auto add = [](int a, int b) -> coro::task<int> { co_return a + b; };
    if (coro::sync_wait(add(2, 3)) != 5) {
        std::printf("sync_wait(task) did not produce the value\n");
        return 1;
    }

    // A generator is lazy: nothing runs until the range is iterated.
    auto squares = [](int n) -> coro::generator<int> {
        for (int i = 1; i <= n; ++i) co_yield i * i;
    };
    int sum = 0;
    for (int v : squares(4)) sum += v;
    if (sum != 1 + 4 + 9 + 16) {
        std::printf("generator produced %d, expected 30\n", sum);
        return 2;
    }

    // The thread pool really moves work off this thread, and coro::mutex
    // serialises it. Both are compiled TUs, not header inlines — this is the
    // link-time proof for src/thread_pool.cpp and src/mutex.cpp.
    // 0.16.0 makes the constructor private: a pool is created through the
    // make_unique factory, which lives in src/thread_pool.cpp — so this line
    // is also the link-time proof that the TU is compiled in.
    auto pool_ptr = coro::thread_pool::make_unique(coro::thread_pool::options{.thread_count = 4});
    coro::thread_pool& pool = *pool_ptr;
    coro::mutex mutex;
    int guarded = 0;

    std::vector<coro::task<void>> tasks;
    tasks.reserve(200);
    for (int i = 0; i < 200; ++i) {
        tasks.emplace_back([](coro::thread_pool& p, coro::mutex& m, int& counter) -> coro::task<void> {
            co_await p.schedule();
            auto lock = co_await m.scoped_lock();
            ++counter;
            co_return;
        }(pool, mutex, guarded));
    }
    coro::sync_wait(coro::when_all(std::move(tasks)));

    if (guarded != 200) {
        std::printf("200 coroutines incremented the counter to %d — the mutex did not serialise them\n", guarded);
        return 3;
    }

    // coro::event: a coroutine suspends until another thread sets it.
    coro::event started;
    std::atomic<bool> observed{false};
    auto waiter = [&]() -> coro::task<void> {
        co_await started;
        observed = true;
        co_return;
    };
    auto setter = [&]() -> coro::task<void> {
        co_await pool.schedule();
        started.set();
        co_return;
    };
    coro::sync_wait(coro::when_all(waiter(), setter()));
    if (!observed) {
        std::printf("coro::event never released the waiter\n");
        return 4;
    }

    std::printf("compat.libcoro: ok (task, generator, 200 pooled tasks under a coro::mutex, event)\n");
    return 0;
}
