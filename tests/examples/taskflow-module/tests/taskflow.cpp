import std;
import tf;

bool taskflow_utility_ok();

int main() {
    tf::Executor executor(2);
    tf::Taskflow flow;
    int left = 0;
    int right = 0;
    int joined = 0;
    auto a = flow.emplace([&] { left = 20; });
    auto b = flow.emplace([&] { right = 22; });
    auto c = flow.emplace([&] { joined = left + right; });
    a.precede(c);
    b.precede(c);
    executor.run(flow).get();
    if (joined != 42) return 1;

    std::vector<int> values(1024, 1);
    int sum = 0;
    tf::Taskflow reduction;
    reduction.reduce(values.begin(), values.end(), sum, std::plus<int>{});
    executor.run(reduction).get();
    return sum == 1024 && taskflow_utility_ok() ? 0 : 2;
}
