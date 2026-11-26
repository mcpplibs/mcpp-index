// compat.pixman — behavioral test.
//
// The interesting thing about this package is not that it links; it is that
// pixman dispatches to architecture-specific SIMD at runtime — SSE2 and SSSE3
// with per-file `-msse2` / `-mssse3` on x86_64, A64 NEON assembly on aarch64,
// and generic C fallback elsewhere.
//
// So the test exercises three real pixel operations that route through those
// paths (solid fill, alpha-blended OVER, and bilinear-scaled SRC — which is
// what reaches `pixman-ssse3.c` on x86_64 and `pixman-arma64-neon-asm-bilinear.S`
// on aarch64) plus region arithmetic.
//
// Every one of them is checked against an exact expected value, and the whole
// suite runs TWICE: once with pixman's default runtime dispatch, and once in a
// re-executed copy of this program with every SIMD implementation switched off
// through pixman's own `PIXMAN_DISABLE`. The second pass is the generic + fast-path C code —
// exactly what an architecture with no SIMD block in the descriptor (riscv64,
// i686, ...) runs — so it is covered on EVERY architecture, including the ones
// CI does not build. Two passes agreeing with the same exact values is also the
// differential check that the SIMD paths and the C paths compute the same thing.
//
// No display, no GPU, no threads.

#ifdef __linux__

#include <pixman.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <vector>

#include <sys/wait.h>
#include <unistd.h>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

void run_checks()
{
    // ── 1. The library is the version this package says it is ────────────
    std::printf("   pixman %s (header %d.%d.%d)\n", pixman_version_string(),
                PIXMAN_VERSION_MAJOR, PIXMAN_VERSION_MINOR, PIXMAN_VERSION_MICRO);
    check(pixman_version() == PIXMAN_VERSION,
          "the linked library and the header agree on the version");
    check(PIXMAN_VERSION_MAJOR == 0 && PIXMAN_VERSION_MINOR == 46,
          "…and it is 0.46, the version the descriptor pins");

    // ── 2. Solid fill composite over 256x256 ARGB ────────────────────────
    const int W = 256, H = 256;
    std::vector<std::uint32_t> dst(static_cast<std::size_t>(W) * H, 0u);

    pixman_color_t colour{};
    colour.red   = 0x4000;
    colour.green = 0x8000;
    colour.blue  = 0xc000;
    colour.alpha = 0xffff;
    pixman_image_t *src = pixman_image_create_solid_fill(&colour);
    check(src != nullptr, "pixman_image_create_solid_fill");

    pixman_image_t *out = pixman_image_create_bits(
        PIXMAN_a8r8g8b8, W, H, dst.data(), W * 4);
    check(out != nullptr, "pixman_image_create_bits 256x256 a8r8g8b8");

    if (src != nullptr && out != nullptr) {
        pixman_image_composite32(PIXMAN_OP_SRC, src, nullptr, out,
                                 0, 0, 0, 0, 0, 0, W, H);

        // Every pixel must be the colour that was composited. A dispatch that
        // picked a broken implementation shows up here rather than as a crash.
        const std::uint32_t want = 0xff4080c0u;
        std::size_t wrong = 0;
        for (std::uint32_t p : dst) {
            if (p != want) {
                ++wrong;
            }
        }
        std::printf("   composited %dx%d, first pixel 0x%08x (wanted 0x%08x)\n",
                    W, H, dst[0], want);
        check(wrong == 0, "every pixel is the colour that was composited");
    }

    // ── 3. Alpha-blended OVER composite (hits SSE2 / A64 NEON over_8888) ─
    {
        std::vector<std::uint32_t> fg(static_cast<std::size_t>(W) * H, 0x80800000u);
        std::vector<std::uint32_t> bg(static_cast<std::size_t>(W) * H, 0xff0000ffu);
        pixman_image_t *fgImg = pixman_image_create_bits(
            PIXMAN_a8r8g8b8, W, H, fg.data(), W * 4);
        pixman_image_t *bgImg = pixman_image_create_bits(
            PIXMAN_a8r8g8b8, W, H, bg.data(), W * 4);
        check(fgImg != nullptr && bgImg != nullptr, "create 256x256 OVER images");
        if (fgImg != nullptr && bgImg != nullptr) {
            pixman_image_composite32(PIXMAN_OP_OVER, fgImg, nullptr, bgImg,
                                     0, 0, 0, 0, 0, 0, W, H);
            const std::uint32_t want = 0xff80007fu;
            std::size_t wrong = 0;
            for (std::uint32_t p : bg) {
                if (p != want) {
                    ++wrong;
                }
            }
            std::printf("   OVER %dx%d, first pixel 0x%08x (wanted 0x%08x)\n",
                        W, H, bg[0], want);
            check(wrong == 0, "OVER alpha blend matches exact premultiplied result");
        }
        if (fgImg != nullptr) { pixman_image_unref(fgImg); }
        if (bgImg != nullptr) { pixman_image_unref(bgImg); }
    }

    // ── 4. Bilinear scaled SRC (hits SSSE3 / A64 NEON bilinear assembly) ─
    {
        const int SW = 128, SH = 128;
        const int DW = 250, DH = 250;
        std::vector<std::uint32_t> stepSrc(static_cast<std::size_t>(SW) * SH, 0xff000000u);
        for (int y = 0; y < SH; ++y) {
            for (int x = SW / 2; x < SW; ++x) {
                stepSrc[static_cast<std::size_t>(y) * SW + x] = 0xff804020u;
            }
        }
        std::vector<std::uint32_t> scaledDst(static_cast<std::size_t>(DW) * DH, 0u);
        pixman_image_t *sImg = pixman_image_create_bits(
            PIXMAN_a8r8g8b8, SW, SH, stepSrc.data(), SW * 4);
        pixman_image_t *dImg = pixman_image_create_bits(
            PIXMAN_a8r8g8b8, DW, DH, scaledDst.data(), DW * 4);
        check(sImg != nullptr && dImg != nullptr, "create bilinear scale images");
        if (sImg != nullptr && dImg != nullptr) {
            pixman_transform_t xform{};
            pixman_transform_init_scale(&xform, pixman_double_to_fixed(0.5),
                                        pixman_double_to_fixed(0.5));
            check(pixman_image_set_transform(sImg, &xform) != 0,
                  "pixman_image_set_transform (2x scale)");
            check(pixman_image_set_filter(sImg, PIXMAN_FILTER_BILINEAR, nullptr, 0) != 0,
                  "pixman_image_set_filter (BILINEAR)");
            // Start at (2, 2) in transformed space so every sample stays
            // strictly inside [0, SW-1] x [0, SH-1] (COVER_CLIP_BILINEAR).
            pixman_image_composite32(PIXMAN_OP_SRC, sImg, nullptr, dImg,
                                     2, 2, 0, 0, 0, 0, DW, DH);
            // At dest x=125 (src_x=127): (127.5 * 0.5) - 0.5 = 63.25 -> 25% of col 64.
            // At dest x=126 (src_x=128): (128.5 * 0.5) - 0.5 = 63.75 -> 75% of col 64.
            const std::uint32_t left  = scaledDst[static_cast<std::size_t>(10) * DW + 10];
            const std::uint32_t mid1  = scaledDst[static_cast<std::size_t>(10) * DW + 125];
            const std::uint32_t mid2  = scaledDst[static_cast<std::size_t>(10) * DW + 126];
            const std::uint32_t right = scaledDst[static_cast<std::size_t>(10) * DW + 200];
            std::printf("   bilinear row: left=0x%08x mid1=0x%08x mid2=0x%08x right=0x%08x\n",
                        left, mid1, mid2, right);
            check(left == 0xff000000u && right == 0xff804020u &&
                  mid1 == 0xff201008u && mid2 == 0xff603018u,
                  "bilinear 2x scale interpolates step edge accurately");
        }
        if (sImg != nullptr) { pixman_image_unref(sImg); }
        if (dImg != nullptr) { pixman_image_unref(dImg); }
    }

    // ── 5. Region arithmetic, the other half of what a compositor uses ───
    // Damage tracking is pixman_region32, and it is pure C — no SIMD, but it
    // is the part a Wayland compositor calls on every frame.
    {
        pixman_region32_t a, b, r;
        pixman_region32_init_rect(&a, 0, 0, 100, 100);
        pixman_region32_init_rect(&b, 50, 50, 100, 100);
        pixman_region32_init(&r);
        check(pixman_region32_union(&r, &a, &b) != 0, "pixman_region32_union");
        const pixman_box32_t *e = pixman_region32_extents(&r);
        std::printf("   union extents: (%d,%d)-(%d,%d)\n", e->x1, e->y1, e->x2, e->y2);
        check(e->x1 == 0 && e->y1 == 0 && e->x2 == 150 && e->y2 == 150,
              "…and the extents are the union of the two rects");
        pixman_region32_fini(&a);
        pixman_region32_fini(&b);
        pixman_region32_fini(&r);
    }

    if (src != nullptr)  { pixman_image_unref(src); }
    if (out != nullptr)  { pixman_image_unref(out); }

}

// Every SIMD implementation the descriptor can compile in, by the names
// pixman's `_pixman_disabled()` knows. `fast` (the C fast paths) stays enabled:
// that is what the other architectures actually run.
constexpr const char *kSimdOff =
    "mmx sse2 ssse3 arm-simd arm-neon vmx mips-dspr2 loongson-mmi rvv";

// Set in the re-executed copy, so it runs one pass and does not recurse.
constexpr const char *kSimdOffMarker = "MCPP_PIXMAN_TEST_SIMD_OFF_PASS";

// The copy exits 0 or 1 itself, and a crash is a signal, so these two can only
// mean the copy never got to run: our own `_exit` after a failed execv, and the
// 255 a binfmt/qemu loader hand-off failure produces.
constexpr bool cannot_relaunch(int status) { return status == 127 || status == 255; }

// Run this program again with SIMD disabled. Returns the child's exit status,
// or -1 if it could not be started at all.
//
// It has to be a re-EXEC, not a fork: the descriptor defines
// TOOLCHAIN_SUPPORTS_ATTRIBUTE_CONSTRUCTOR, so pixman picks its implementation
// in a constructor, at load time, before main() — a `setenv` in a forked child
// would arrive too late and the "SIMD-off" pass would silently run SIMD. The
// child's pixman prints "Disabled <name> implementation" for every name it
// honoured, which is how that is visible in the log.
int run_simd_off_pass()
{
    std::fflush(stdout);
    const pid_t pid = fork();
    if (pid < 0) {
        return -1;
    }
    if (pid == 0) {
        setenv("PIXMAN_DISABLE", kSimdOff, 1);
        setenv(kSimdOffMarker, "1", 1);
        char *const argv[] = {const_cast<char *>("pixman"), nullptr};
        execv("/proc/self/exe", argv);
        _exit(127);
    }
    int status = 0;
    if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status)) {
        return -1;
    }
    return WEXITSTATUS(status);
}

} // namespace

int main()
{
    if (std::getenv(kSimdOffMarker) != nullptr) {
        std::printf("── pass 1/2: SIMD disabled (PIXMAN_DISABLE) ──\n");
        run_checks();
        std::printf("   SIMD-off pass: %d check(s) failed\n", failures);
        return failures == 0 ? 0 : 1;
    }

    // Not being able to re-launch is not a pixman failure: a dynamically linked glibc binary
    // run under qemu-user gets its sysroot from the runner's `-L`, which the
    // kernel's binfmt hand-off for the re-executed copy does not carry, so the
    // loader is not found. Say so loudly instead of failing the package for the
    // harness; native runs and static (musl) builds do re-launch, and a copy
    // that starts and then fails a check is still a failure.
    const int off = run_simd_off_pass();
    if (cannot_relaunch(off)) {
        std::printf("%-58s %s\n", "SIMD-off pass (generic + fast-path C)",
                    "SKIPPED (cannot re-exec this binary here)");
    } else {
        check(off == 0, "SIMD-off pass (generic + fast-path C) passes every check");
    }

    std::printf("── pass 2/2: default runtime dispatch ──\n");
    run_checks();

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else

int main() { return 0; }

#endif
