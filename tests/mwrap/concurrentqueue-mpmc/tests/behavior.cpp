import std;
import mcpplibs.mwrap.concurrentqueue;

namespace macros = mcpplibs::mwrap::concurrentqueue::macros;

int main() {
    static_assert(macros::MOODYCAMEL_EXCEPTIONS_ENABLED);
    constexpr int producers = 4, consumers = 4, per_producer = 10000, total = producers * per_producer;
    // Producers enqueue in bulk through their tokens; consumers wait with a
    // timeout and stop once everything is taken.
    moodycamel::BlockingConcurrentQueue<std::pair<int, int>> queue;
    std::vector<std::vector<char>> seen(producers, std::vector<char>(per_producer, 0));
    std::mutex seen_lock;
    std::atomic<int> taken{0};
    bool ordered = true;
    {
        std::vector<std::jthread> threads;
        for (int p = 0; p < producers; ++p)
            threads.emplace_back([&, p] {
                moodycamel::ProducerToken token(queue);
                std::array<std::pair<int, int>, 100> batch;
                for (int i = 0; i < per_producer; i += 100) {
                    for (int k = 0; k < 100; ++k) batch[k] = {p, i + k};
                    queue.enqueue_bulk(token, batch.begin(), batch.size());
                }
            });
        for (int c = 0; c < consumers; ++c)
            threads.emplace_back([&] {
                moodycamel::ConsumerToken token(queue);
                std::array<std::pair<int, int>, 64> batch;
                std::array<int, producers> last{-1, -1, -1, -1};
                while (taken.load() < total) {
                    const auto n = queue.wait_dequeue_bulk_timed(token, batch.begin(), batch.size(), std::chrono::milliseconds(1));
                    std::lock_guard lock(seen_lock);
                    for (std::size_t k = 0; k < n; ++k) {
                        auto [p, i] = batch[k];
                        if (i <= last[p]) ordered = false;  // per-producer FIFO
                        last[p] = i;
                        ++seen[p][i];
                    }
                    taken.fetch_add(static_cast<int>(n));
                }
            });
    }
    for (const auto& p : seen)
        for (char c : p)
            if (c != 1) return 1;
    if (!ordered) return 2;
    // A timed wait on an empty queue times out; the semaphore counts.
    std::pair<int, int> none;
    if (queue.wait_dequeue_timed(none, std::chrono::milliseconds(2))) return 3;
    moodycamel::LightweightSemaphore sema;
    sema.signal(2);
    if (sema.waitMany(5) != 2 || sema.tryWait()) return 4;
    std::println("concurrentqueue-mpmc: ok ({} items, {} producers, {} consumers)", total, producers, consumers);
    return 0;
}
