#ifdef __APPLE__
import std;
extern "C" int asm_add(int, int);   // defined in asm/add_arm64.S
int main() {
    int r = asm_add(2, 3);
    std::println("asm-macos-spike: aarch64 .S linked OK, asm_add(2,3)={}", r);
    return r == 5 ? 0 : 1;
}
#else
int main() { return 0; }
#endif
