// The installed Abseil wrapper through import alone: strings split, joined and
// formatted; a flat_hash_map counting words; StatusOr with its error path;
// civil time in UTC; a Mutex shared by threads (not on the Web, which runs
// without threads); the release constant mapped from its macro.
import std;
import mcpplibs.mwrap.abseil;

namespace {
int failures = 0;
void check(bool ok, std::string_view what) {
    if (!ok) {
        ++failures;
        std::println("FAIL: {}", what);
    }
}

absl::StatusOr<int> parse_port(std::string_view text) {
    int port = 0;
    if (!absl::SimpleAtoi(text, &port)) return absl::InvalidArgumentError(absl::StrCat("not a number: ", text));
    if (port <= 0 || port > 65535) return absl::OutOfRangeError(absl::StrFormat("port %d out of range", port));
    return port;
}
}  // namespace

int main() {
    std::vector<std::string> words = absl::StrSplit("the quick brown fox jumps over the lazy dog the end", ' ');
    absl::flat_hash_map<std::string, int> counts;
    for (const auto& word : words) ++counts[word];
    check(counts["the"] == 3 && counts.size() == 9, "flat_hash_map word counts");
    check(absl::StrJoin(std::vector<int>{1, 2, 3}, "-") == "1-2-3", "StrJoin");
    check(absl::StrFormat("%08.3f", 3.14159) == "0003.142", "StrFormat");

    const auto good = parse_port("8080");
    const auto bad = parse_port("http");
    const auto far = parse_port("70000");
    check(good.ok() && *good == 8080, "StatusOr value");
    check(!bad.ok() && absl::IsInvalidArgument(bad.status()) && bad.status().message() == "not a number: http", "StatusOr error");
    check(absl::IsOutOfRange(far.status()), "StatusOr out of range");

    const absl::CivilSecond moment(2026, 11, 19, 12, 30, 0);
    const absl::Time time = absl::FromCivil(moment, absl::UTCTimeZone());
    check(absl::FormatTime("%Y-%m-%dT%H:%M:%S", time + absl::Hours(36), absl::UTCTimeZone()) == "2026-11-21T00:30:00", "civil time in UTC");
    check(absl::ToUnixSeconds(time) == 1795091400, "Unix seconds");

#if !defined(__EMSCRIPTEN__)
    absl::Mutex mutex;
    long total = 0;
    {
        std::vector<std::jthread> threads;
        for (int t = 0; t < 4; ++t)
            threads.emplace_back([&] {
                for (int i = 0; i < 1000; ++i) {
                    absl::MutexLock lock(&mutex);
                    ++total;
                }
            });
    }
    check(total == 4000, "Mutex across threads");
#endif

    check(mcpplibs::mwrap::abseil::macros::ABSL_LTS_RELEASE_VERSION == 20250512, "ABSL_LTS_RELEASE_VERSION");
    std::println("{}", failures == 0 ? "abseil-basics: all checks passed" : "abseil-basics: FAILED");
    return failures == 0 ? 0 : 1;
}
