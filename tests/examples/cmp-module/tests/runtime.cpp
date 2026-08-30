import std;
import mcpplibs.cmp;

using mcpplibs::cmp::RunLoop;
using mcpplibs::cmp::Task;

Task<int> scheduled_answer(RunLoop::Scheduler scheduler) {
    co_await scheduler.schedule();
    co_return 42;
}

int main() {
    RunLoop loop {};
    return loop.run(scheduled_answer(loop.get_scheduler())) == 42 ? 0 : 1;
}
