// R2 spike: minimal aarch64 GAS .S — proves mcpp assembles + links a GAS .S TU
// on macos-15 (the #1 macOS unknown; FFmpeg/OpenCV SIMD on arm64 is GAS .S).
// macOS arm64 ABI: w0=arg0, w1=arg1, result in w0; C symbol `asm_add` -> `_asm_add`.
.text
.p2align 2
.globl _asm_add
_asm_add:
    add w0, w0, w1
    ret
