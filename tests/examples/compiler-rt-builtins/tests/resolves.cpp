// The member builds on every runner; the package it names is for the ok-image rows.
import std;

int main() {
    // 128-bit division, which the builtins supply on the rows this package serves.
    const unsigned __int128 n = (static_cast<unsigned __int128>(1) << 100) + 7;
    const unsigned __int128 q = n / 3;
    std::println("compiler-rt-builtins-tests: {}", static_cast<unsigned long long>(q % 1000003));
    return q * 3 + (n % 3) == n ? 0 : 1;
}
