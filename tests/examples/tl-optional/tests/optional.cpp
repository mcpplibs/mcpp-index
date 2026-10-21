// compat.tl-optional — assert value/empty state, observers, mutation, monadic
// chaining, reference binding, and constexpr construction through the public
// header. The test uses only the standard library in addition to tl/optional.
#include <tl/optional.hpp>

#include <cstdio>
#include <string>
#include <type_traits>

int main() {
    bool ok = true;
    auto check = [&](bool condition, const char* what) {
        if (!condition) {
            std::printf("FAIL: %s\n", what);
            ok = false;
        }
    };

    tl::optional<int> value = tl::make_optional(42);
    tl::optional<int> empty = tl::nullopt;
    check(value.has_value() && *value == 42, "value construction and observer");
    check(!empty.has_value(), "nullopt constructs an empty optional");
    check(value.value_or(7) == 42 && empty.value_or(7) == 7,
          "value_or handles both states");

    constexpr tl::optional<int> constexpr_value = tl::make_optional(11);
    static_assert(constexpr_value.has_value(), "constexpr optional");

    value.reset();
    check(!value, "reset clears the value");
    value.emplace(21);
    check(value && *value == 21, "emplace constructs a new value");

    const auto doubled = empty.map([](int x) { return x * 2; });
    check(!doubled, "map on an empty optional stays empty");
    const auto mapped = tl::make_optional(21).map([](int x) { return x * 2; });
    check(mapped && *mapped == 42, "map transforms a present value");

    const auto chained = tl::make_optional(5).and_then([](int x) {
        return tl::make_optional(x * 3);
    });
    check(chained && *chained == 15, "and_then chains optional-producing calls");

    const auto fallback = empty.or_else([] { return tl::make_optional(13); });
    check(fallback && *fallback == 13, "or_else supplies a fallback");
    check(tl::make_optional(42).map_or([](int x) { return x + 1; }, 0) == 43,
          "map_or applies the mapper when present");
    check(empty.map_or([](int x) { return x + 1; }, 0) == 0,
          "map_or returns the fallback when empty");

    int first = 1;
    int second = 2;
    tl::optional<int&> reference = first;
    check(&*reference == &first, "reference optional binds the original object");
    reference = second;
    check(&*reference == &second, "assignment rebinds the reference");
    *reference = 9;
    check(second == 9, "writing through a reference optional mutates the object");

    tl::optional<std::string> text = std::string("hello");
    auto taken = text.take();
    check(taken && *taken == "hello" && !text,
          "take moves out the value and empties the source");

    static_assert(std::is_same<decltype(tl::make_optional<int&>(first)),
                               tl::optional<int&>>::value,
                  "make_optional preserves reference optionals");

    if (ok) {
        std::puts("tl-optional OK");
    }
    return ok ? 0 : 1;
}
