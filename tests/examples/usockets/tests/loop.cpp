// Behavioral test: a real event loop iteration, driven by uSockets' own timer.
//
// The struct-layout hazard this package warns about is invisible to a build:
// `us_loop_t` has a different shape under LIBUS_USE_LIBUV, and a consumer that
// disagrees corrupts memory rather than failing to link. So the test allocates
// loop-attached extension memory, writes to it from a timer callback, and reads
// it back afterwards — if the layouts disagreed, that write lands somewhere else.
#include <libusockets.h>

#include <cassert>
#include <cstring>

namespace {

struct LoopExt {
    int ticks;
    int magic;
};

struct TimerExt {
    us_loop_t* loop;
    int budget;
};

constexpr int kMagic = 0x5AFE;

void on_wakeup(us_loop_t*) {}
void on_pre(us_loop_t*) {}
void on_post(us_loop_t*) {}

void on_timer(us_timer_t* timer) {
    auto* text = static_cast<TimerExt*>(us_timer_ext(timer));
    auto* lext = static_cast<LoopExt*>(us_loop_ext(text->loop));

    assert(lext->magic == kMagic && "loop extension memory moved — layout mismatch");
    ++lext->ticks;

    if (--text->budget <= 0) {
        us_timer_close(timer);
    }
}

}  // namespace

int main() {
    us_loop_t* loop = us_create_loop(nullptr, on_wakeup, on_pre, on_post,
                                     static_cast<unsigned int>(sizeof(LoopExt)));
    assert(loop != nullptr);

    auto* lext = static_cast<LoopExt*>(us_loop_ext(loop));
    std::memset(lext, 0, sizeof(LoopExt));
    lext->magic = kMagic;

    us_timer_t* timer = us_create_timer(loop, 0, static_cast<unsigned int>(sizeof(TimerExt)));
    assert(timer != nullptr);
    auto* text = static_cast<TimerExt*>(us_timer_ext(timer));
    text->loop = loop;
    text->budget = 3;

    // 1 ms, repeating: the loop must actually run and re-arm.
    us_timer_set(timer, on_timer, 1, 1);

    us_loop_run(loop);   // returns when nothing is left referencing the loop

    assert(lext->ticks == 3);
    assert(lext->magic == kMagic);

    us_loop_free(loop);
    return 0;
}
