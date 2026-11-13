// aimol.tensorvia smoke: import the module, run CPU ops, and read back
// scalars. Every check can fail; a non-zero exit is the signal.
import std;
import tensorvia;

namespace {

int failures = 0;

void check(bool ok, std::string_view what) {
    if (!ok) {
        std::println("FAIL: {}", what);
        ++failures;
    }
}

}  // namespace

int main() {
    const Tensor ones = ops::Ones({4, 4}, DataType::FLOAT32);
    check(ops::Sum(ones).item<float>() == 16.0f, "Sum(Ones(4x4)) == 16");

    const Tensor twos = ops::Add(ones, ones);
    check(ops::Sum(twos).item<float>() == 32.0f, "Sum(Ones+Ones) == 32");

    // Add(tensor, scalar) then Relu: the negative half clamps to zero.
    const Tensor clamped = ops::Relu(ops::Add(ones, -3.0f));
    check(ops::Sum(clamped).item<float>() == 0.0f, "Relu(1-3) == 0");

    // The library's version constant reaches a string_view consumer.
    check(!tensorvia::version.empty(), "version is non-empty");

    std::println("tensorvia smoke: {} failures", failures);
    return failures == 0 ? 0 : 1;
}
