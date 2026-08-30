// libxkbcommon, exercised through the generated parser.
//
// The package is a fork for exactly one reason: `src/xkbcomp/parser.y` is
// bison's input and the 3,960-line parser is generated. So the test compiles a
// keymap FROM A STRING — that runs the parser end to end and needs no
// xkeyboard-config data on disk, which is what makes it runnable on a CI
// machine and in a sandbox.
//
// A package that linked but whose parser was generated without
// `-p _xkbcommon_`, or not regenerated after a version bump, fails here rather
// than in somebody's compositor.

#ifdef __linux__

#include <xkbcommon/xkbcommon.h>

#include <cstdio>
#include <cstring>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

// A complete, minimal keymap. Every section the parser knows about appears at
// least once, so compiling it exercises the grammar rather than a corner of it.
const char *const KEYMAP =
    "xkb_keymap {\n"
    "  xkb_keycodes { <esc> = 9; <q> = 24; };\n"
    "  xkb_types { type \"ONE_LEVEL\" {\n"
    "      modifiers = none;\n"
    "      level_name[1] = \"Any\";\n"
    "  }; };\n"
    "  xkb_compat { };\n"
    "  xkb_symbols {\n"
    "    key <esc> { [ Escape ] };\n"
    "    key <q>   { [ q ] };\n"
    "  };\n"
    "};";

} // namespace

int main()
{
    // ── 1. A context with no data root ───────────────────────────────────
    // XKB_CONTEXT_NO_DEFAULT_INCLUDES because this package compiles in an
    // EMPTY DFLT_XKB_CONFIG_ROOT on purpose — there is no dataset to include,
    // and asking for one would be asking for the host's.
    xkb_context *ctx = xkb_context_new(XKB_CONTEXT_NO_DEFAULT_INCLUDES);
    check(ctx != nullptr, "xkb_context_new");
    if (ctx == nullptr) {
        std::printf("\n%d check(s) failed\n", failures);
        return 1;
    }

    // ── 2. THE PARSER. This is what the fork exists for ──────────────────
    xkb_keymap *km = xkb_keymap_new_from_string(
        ctx, KEYMAP, XKB_KEYMAP_FORMAT_TEXT_V1, XKB_KEYMAP_COMPILE_NO_FLAGS);
    check(km != nullptr, "xkb_keymap_new_from_string compiled the keymap");
    if (km == nullptr) {
        xkb_context_unref(ctx);
        std::printf("\n%d check(s) failed\n", failures);
        return 1;
    }

    // ── 3. The compiled keymap answers about itself ──────────────────────
    const xkb_keycode_t min = xkb_keymap_min_keycode(km);
    const xkb_keycode_t max = xkb_keymap_max_keycode(km);
    std::printf("   keycodes %u..%u\n", min, max);
    check(min <= 9 && max >= 24, "…and its keycode range covers both keys");

    // ── 4. A key press produces the right keysym ─────────────────────────
    // This is the whole job: keycode in, keysym out, through the state
    // machine the compat and types sections drive.
    xkb_state *st = xkb_state_new(km);
    check(st != nullptr, "xkb_state_new");
    if (st != nullptr) {
        const xkb_keysym_t sym = xkb_state_key_get_one_sym(st, 24);
        char name[64] = {0};
        xkb_keysym_get_name(sym, name, sizeof name);
        std::printf("   keycode 24 -> keysym %s\n", name);
        check(sym == XKB_KEY_q, "keycode 24 resolves to the keysym 'q'");

        char buf[16] = {0};
        const int n = xkb_state_key_get_utf8(st, 24, buf, sizeof buf);
        std::printf("   utf8: \"%s\" (%d byte(s))\n", buf, n);
        check(n == 1 && buf[0] == 'q', "…and to the UTF-8 text \"q\"");

        const xkb_keysym_t esc = xkb_state_key_get_one_sym(st, 9);
        check(esc == XKB_KEY_Escape, "keycode 9 resolves to Escape");

        xkb_state_unref(st);
    }

    // ── 5. The keysym tables, which are their own generated data ─────────
    check(xkb_keysym_from_name("Escape", XKB_KEYSYM_NO_FLAGS) == XKB_KEY_Escape,
          "xkb_keysym_from_name resolves a name to its keysym");

    xkb_keymap_unref(km);
    xkb_context_unref(ctx);

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
