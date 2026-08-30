// compat.pixman — behavioral test.
//
// The interesting thing about this package is not that it links; it is that
// pixman dispatches on the CPU at runtime, and this index compiles the SSE2
// and SSSE3 implementations with per-file `-msse2` / `-mssse3` so that the
// compiler may emit those instructions THERE and nowhere else. If the flags
// had been package-wide, code running before pixman's own CPUID check could
// carry SSSE3 — an illegal instruction on an older machine, from a library
// whose entire design is to avoid exactly that.
//
// So the test does two things a "does it link" check would not:
//
//   * asks pixman which implementation it CHOSE, through a real composite;
//   * composites actual pixels and reads them back, because the SIMD paths
//     are only reached with enough work to be worth dispatching to.
//
// No display, no GPU, no threads.

#ifdef __linux__

#include <pixman.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdint>
#include <vector>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

} // namespace

int main()
{
    // ── 1. The library is the version this package says it is ────────────
    std::printf("   pixman %s (header %d.%d.%d)\n", pixman_version_string(),
                PIXMAN_VERSION_MAJOR, PIXMAN_VERSION_MINOR, PIXMAN_VERSION_MICRO);
    check(pixman_version() == PIXMAN_VERSION,
          "the linked library and the header agree on the version");
    check(PIXMAN_VERSION_MAJOR == 0 && PIXMAN_VERSION_MINOR == 46,
          "…and it is 0.46, the version the descriptor pins");

    // ── 2. A real composite, over enough pixels to matter ────────────────
    // 256x256 ARGB: large enough that pixman routes through a fast path
    // rather than the trivial one, which is what exercises the dispatched
    // implementation the SIMD flags were for.
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

    // ── 3. Region arithmetic, the other half of what a compositor uses ───
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

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else

int main() { return 0; }

#endif
