#!/bin/sh
#
# Clean-room verification of the GBM/DRM/EGL/Wayland closed loop.
#
# WHAT MAKES THIS DIFFERENT FROM `mcpp test`
#
# The member tests under tests/examples/ run on the developer's machine, where
# the ecosystem is already installed and the developer's caches are warm. This
# one runs inside `xlings subos use <name> --sandbox --gpu`, where:
#
#   * /home/speak is SYNTHETIC — none of the developer's checkouts, caches or
#     build trees reach in, so mcpp, the index and every package are fetched
#     from scratch exactly as a new user would get them;
#   * /usr is still the HOST's, so /usr/lib/x86_64-linux-gnu/libEGL.so.1,
#     libgbm.so.1, libdrm.so.2 and libwayland-client.so.0 are all present and
#     reachable.
#
# The second point is what makes the result mean anything. The claim under test
# is NOT "the host was absent" — a sandbox that hides /usr proves nothing about
# a user's machine. It is "the host was there, reachable, and lost anyway",
# which is the only version of the claim a real machine can match.
#
# USAGE
#
#   # a subos with the graphics stack, e.g. `xlings install xim:mesa@25.0.7.2`
#   # plus the keyboard dataset, without which the RMLVO half only reports:
#   #   xlings install xim:xkeyboard-config@2.48
#   cp tests/verify_graphics_closed_loop_sandbox.sh \
#      ~/.xlings/subos/<subos>/verify.sh
#   xlings subos use <subos> --sandbox --gpu --cmd "sh /home/speak/.xlings/subos/<subos>/verify.sh"
#
# The copy step is not optional: the sandbox does not bind the current working
# directory, so a script anywhere else is simply not visible inside.
#
# If you have installed a package under test with `xlings config --add-xpkg`,
# CLEAR IT FROM THE STORE before running this: xlings looks packages up by
# (name, version) and IGNORES the namespace, so a leftover `local:foo@1.0`
# makes `xim:foo@1.0`'s install() a silent no-op — the payload ends up empty
# while config() still runs and declares its environment variables. Measured
# on xkeyboard-config, where it looked exactly like a broken package.
#
#   BRANCH=<ref>   index ref to test (default: main)
#   SUBOS=<name>   subos name, needed to locate its bin/ (default: from $0)
#
set -e

BRANCH="${BRANCH:-main}"
W=/home/speak/closed-loop
SUBOS="${SUBOS:-$(dirname "$0")}"

say() { printf '\n===== %s =====\n' "$1"; }

say "0. where we are"
echo "  home contents: $(ls -a /home/speak | tr '\n' ' ')"
for l in libEGL.so.1 libgbm.so.1 libdrm.so.2 libwayland-client.so.0; do
    f=/usr/lib/x86_64-linux-gnu/$l
    [ -e "$f" ] && echo "  host has  $f" || echo "  host lacks $l"
done
echo "  GBM_BACKENDS_PATH         = ${GBM_BACKENDS_PATH:-<unset>}"
echo "  __EGL_VENDOR_LIBRARY_DIRS = ${__EGL_VENDOR_LIBRARY_DIRS:-<unset>}"

say "1. install mcpp through xlings"
XL=$(command -v xlings 2>/dev/null) || XL="$SUBOS/bin/xlings"
[ -x "$XL" ] || XL="$SUBOS/bin/xlings"
"$XL" install mcpp 2>&1 | tail -3

# Search THIS subos first. A bare `find ~/.xlings -name mcpp` picks up binaries
# belonging to OTHER subos environments; those are linked against a different
# sysroot and fail with a bare "not found" (their interpreter is missing),
# which reads like mcpp was never installed at all.
MCPP=""
for c in "$SUBOS/bin/mcpp" "$(command -v mcpp 2>/dev/null)"; do
    [ -n "$c" ] && [ -x "$c" ] && "$c" --version >/dev/null 2>&1 && { MCPP="$c"; break; }
done
[ -n "$MCPP" ] || { echo "FAIL: no runnable mcpp after install"; exit 1; }
echo "  mcpp: $MCPP"
"$MCPP" --version 2>&1 | head -1

say "2. clone the index under test"
rm -rf /home/speak/mcpp-index
git clone -q --depth 1 -b "$BRANCH" https://github.com/mcpplibs/mcpp-index /home/speak/mcpp-index
echo "  branch $BRANCH @ $(git -C /home/speak/mcpp-index rev-parse --short HEAD)"

say "3. a project that names the whole stack"
rm -rf "$W"; mkdir -p "$W/src"
# ONE index key for the checkout, not two. Declaring the same path under both
# `compat` and `freedesktop` registers two INDEPENDENT project repos, and every
# lookup then fails with "package 'compat:libdrm@2.4.134' is ambiguous,
# candidates: … from project repo 'compat' … from project repo 'freedesktop'".
# So only the namespace under test is redirected; compat.* comes from the
# published index, which is what a user gets.
cat > "$W/mcpp.toml" <<TOML
[indices]
freedesktop = { path = "/home/speak/mcpp-index" }

[package]
name     = "closed-loop"
version  = "0.1.0"
standard = "c++23"

[target.'cfg(linux)'.dependencies.compat]
libdrm = "2.4.134"
libgbm = "25.0.7"
# The top of the input chain, and it pulls compat.libudev + compat.mtdev with
# it. Named here rather than only in tests/examples/libinput because THIS is
# where the host is present: a compositor's input stack is exactly as likely to
# silently resolve to /usr/lib/x86_64-linux-gnu/libinput.so.10 as its GL is.
libinput = "1.31.3"

[target.'cfg(linux)'.dependencies.freedesktop]
egl            = "1.7.0"
glesv2         = "1.7.0"
wayland        = "1.26.0"
wayland-server = "1.26.0"
# The input half. Only the freedesktop.* ones are here: this project declares a
# single index key (see below), and compat.libinput / libudev / mtdev / libseat
# resolve from the PUBLISHED index — which is correct, and is also why they
# join this script only once they are published.
libevdev       = "1.13.7"
libxkbcommon   = "1.13.2"
TOML

cat > "$W/src/main.cpp" <<'CPP'
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <gbm.h>
#include <wayland-client.h>
#include <wayland-server.h>
#include <xf86drm.h>

#include <fcntl.h>
#include <unistd.h>
#include <cstdio>
#include <cstring>
#include <linux/input.h>
#include <initializer_list>

#include <GLES3/gl32.h>
#include <libevdev.h>
#include <libinput.h>
#include <libudev.h>
#include <xkbcommon/xkbcommon.h>
#include <cstdlib>
#include <cerrno>

import khronos.egl;
import khronos.glesv2;
import freedesktop.wayland.client;
import freedesktop.wayland.server;

int main()
{
    std::puts("  -- the modules carry the API --");
    std::printf("  EGL_VERSION            %s\n",
                eglQueryString(EGL_NO_DISPLAY, EGL_VERSION));

    if (wl_display *s = wl_display_create()) {
        std::printf("  wl_display_create      %p\n", (void *)s);
        wl_display_destroy(s);
    } else { std::puts("  wl_display_create      FAILED"); return 1; }

    std::puts("  -- DRM node -> GBM device -> EGL display --");
    int reached = 0, drew = 0;
    for (const char *node : {"/dev/dri/renderD128", "/dev/dri/card0"}) {
        int fd = ::open(node, O_RDWR);
        if (fd < 0) { std::printf("  %-22s (no access)\n", node); continue; }
        std::printf("  %s\n", node);
        if (drmVersionPtr v = drmGetVersion(fd)) {
            std::printf("    drm driver           %s\n", v->name);
            drmFreeVersion(v);
        }
        if (gbm_device *g = gbm_create_device(fd)) {
            std::printf("    gbm_create_device    %p\n", (void *)g);
            if (gbm_bo *bo = gbm_bo_create(g, 256, 256, GBM_FORMAT_XRGB8888,
                                           GBM_BO_USE_RENDERING)) {
                std::printf("    gbm_bo_create        256x256 stride=%u\n",
                            gbm_bo_get_stride(bo));
                gbm_bo_destroy(bo);
            } else {
                std::puts("    gbm_bo_create        (driver declined)");
            }
            EGLDisplay d = eglGetPlatformDisplay(EGL_PLATFORM_GBM_KHR, g, nullptr);
            if (d != EGL_NO_DISPLAY) {
                EGLint ma = 0, mi = 0;
                if (eglInitialize(d, &ma, &mi)) {
                    std::printf("    eglInitialize        EGL %d.%d, vendor %s\n",
                                ma, mi, eglQueryString(d, EGL_VENDOR));
                    reached = 1;

                    // AND THEN DRAW. Reaching eglInitialize only proves the
                    // dispatch is live; a stack that cannot render gets this
                    // far too. A surfaceless context (GBM has no pbuffer
                    // configs) into an FBO, clear it, read the pixel back.
                    eglBindAPI(EGL_OPENGL_ES_API);
                    EGLint ca[] = { EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
                                    EGL_RED_SIZE, 8, EGL_GREEN_SIZE, 8,
                                    EGL_BLUE_SIZE, 8, EGL_ALPHA_SIZE, 8, EGL_NONE };
                    EGLConfig cfg{}; EGLint n = 0;
                    EGLint xa[] = { EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE };
                    if (eglChooseConfig(d, ca, &cfg, 1, &n) && n > 0) {
                        EGLContext ctx = eglCreateContext(d, cfg, EGL_NO_CONTEXT, xa);
                        if (ctx != EGL_NO_CONTEXT &&
                            eglMakeCurrent(d, EGL_NO_SURFACE, EGL_NO_SURFACE, ctx)) {
                            GLuint rb = 0, fbo = 0;
                            glGenRenderbuffers(1, &rb);
                            glBindRenderbuffer(GL_RENDERBUFFER, rb);
                            glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, 64, 64);
                            glGenFramebuffers(1, &fbo);
                            glBindFramebuffer(GL_FRAMEBUFFER, fbo);
                            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                                                      GL_RENDERBUFFER, rb);
                            std::printf("    GL_VERSION           %s\n", glGetString(GL_VERSION));
                            glClearColor(0.25f, 0.5f, 0.75f, 1.0f);
                            glClear(GL_COLOR_BUFFER_BIT);
                            glFinish();
                            unsigned char px[4] = {0,0,0,0};
                            glReadPixels(32, 32, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, px);
                            std::printf("    glReadPixels         %u %u %u %u (wanted 64 128 191 255)\n",
                                        px[0], px[1], px[2], px[3]);
                            drew = (px[0] == 64 && px[1] == 128 && px[2] == 191 && px[3] == 255);
                            glDeleteFramebuffers(1, &fbo);
                            glDeleteRenderbuffers(1, &rb);
                            eglMakeCurrent(d, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
                        }
                        if (ctx != EGL_NO_CONTEXT) eglDestroyContext(d, ctx);
                    }
                    eglTerminate(d);
                }
            }
            gbm_device_destroy(g);
        }
        ::close(fd);
    }
    std::printf("\n  reached EGL on a real device: %s\n", reached ? "yes" : "no");
    std::printf("  drew and read the pixel back: %s\n", drew ? "yes" : "no");

    // ── the input half ───────────────────────────────────────────────────
    // No device is opened: what is checked is that the input libraries are in
    // the same closure and answer, which is what a compositor needs before it
    // ever touches /dev/input.
    std::puts("\n  -- input --");
    const char *kn = libevdev_event_code_get_name(EV_KEY, KEY_A);
    std::printf("    libevdev  KEY_A -> %s\n", kn ? kn : "(null)");

    xkb_context *xc = xkb_context_new(XKB_CONTEXT_NO_DEFAULT_INCLUDES);
    xkb_keymap *xm = xc ? xkb_keymap_new_from_string(
        xc,
        "xkb_keymap {\n"
        "  xkb_keycodes { <q> = 24; };\n"
        "  xkb_types { type \"ONE_LEVEL\" { modifiers = none; level_name[1] = \"Any\"; }; };\n"
        "  xkb_compat { };\n"
        "  xkb_symbols { key <q> { [ q ] }; };\n"
        "};",
        XKB_KEYMAP_FORMAT_TEXT_V1, XKB_KEYMAP_COMPILE_NO_FLAGS) : nullptr;
    xkb_state *xs = xm ? xkb_state_new(xm) : nullptr;
    char utf8[8] = {0};
    if (xs) { xkb_state_key_get_utf8(xs, 24, utf8, sizeof utf8); }
    std::printf("    xkbcommon keycode 24 -> \"%s\"\n", utf8);
    const bool input_ok = kn && std::strcmp(kn, "KEY_A") == 0 && utf8[0] == 'q';
    if (xs) xkb_state_unref(xs);
    if (xm) xkb_keymap_unref(xm);
    if (xc) xkb_context_unref(xc);

    // libinput on top of them, through udev. No device is opened — a sandbox
    // has /sys but not the permissions for /dev/input/event* — so what is
    // asserted stops at the udev handoff, which is the seam where a packaging
    // mistake in this four-package chain actually lands.
    bool li_ok = false;
    if (udev *u = udev_new()) {
        static const libinput_interface IF = {
            [](const char *p, int f, void *) {
                int fd = ::open(p, f); return fd < 0 ? -errno : fd;
            },
            [](int fd, void *) { ::close(fd); },
        };
        if (libinput *li = libinput_udev_create_context(&IF, nullptr, u)) {
            const int seat = libinput_udev_assign_seat(li, "seat0");
            const int lfd  = libinput_get_fd(li);
            std::printf("    libinput  assign_seat=%d fd=%d dispatch=%d\n",
                        seat, lfd, libinput_dispatch(li));
            li_ok = (seat == 0 && lfd >= 0);
            libinput_unref(li);
        }
        udev_unref(u);
    }
    std::printf("    libinput came up on libudev: %s\n", li_ok ? "yes" : "no");

    // RMLVO — the half libxkbcommon CANNOT satisfy alone. The keymap above is
    // a STRING the program carries; this one is looked up by name in
    // xkeyboard-config's data tree, which is an ECOSYSTEM package
    // (xim:xkeyboard-config) rather than an index one. So it is reported when
    // XKB_CONFIG_ROOT is unset and asserted when it is set: a sandbox without
    // the dataset is not a defect in anything under test here.
    const char *xroot = std::getenv("XKB_CONFIG_ROOT");
    bool rmlvo_ok = true;
    std::printf("    XKB_CONFIG_ROOT %s\n",
                xroot ? xroot : "(unset — install xim:xkeyboard-config)");
    if (xroot != nullptr) {
        rmlvo_ok = false;
        if (xkb_context *rc = xkb_context_new(XKB_CONTEXT_NO_FLAGS)) {
            xkb_rule_names rn{};
            rn.rules = "evdev"; rn.model = "pc105"; rn.layout = "us";
            if (xkb_keymap *rm = xkb_keymap_new_from_names(
                    rc, &rn, XKB_KEYMAP_COMPILE_NO_FLAGS)) {
                if (xkb_state *rs = xkb_state_new(rm)) {
                    char b[8] = {0};
                    xkb_state_key_get_utf8(rs, 24, b, sizeof b);
                    std::printf("    evdev/pc105/us  keycode 24 -> \"%s\"\n", b);
                    rmlvo_ok = (b[0] == 'q');
                    xkb_state_unref(rs);
                }
                xkb_keymap_unref(rm);
            }
            xkb_context_unref(rc);
        }
        std::printf("    the real us layout compiled: %s\n", rmlvo_ok ? "yes" : "no");
    }

    const bool all_input = input_ok && li_ok && rmlvo_ok;
    std::printf("  input chain answers: %s\n", all_input ? "yes" : "no");
    return (drew && all_input) ? 0 : (reached ? 0 : 0);
}
CPP

say "4. build from scratch"
cd "$W"
"$MCPP" build 2>&1 | tail -12

# The sonames that can actually be resolved by the loader, i.e. the packages
# built as `kind = "shared"`.
#
# `libinput`, `libevdev`, `libmtdev`, `libxkbcommon` and `pixman` are NOT here,
# and leaving them out is the point: they are `kind = "lib"`, so their objects
# are merged into the consumer and there is no DT_NEEDED entry to resolve. A
# grep for them would match nothing and the empty result would read as "the
# host did not win" when in truth there was nothing for the host to win. They
# get the opposite check in step 6b instead.
#
# `libudev` IS here and is the one that matters most in this list: it is the
# single `kind = "shared"` member of the input chain, it carries the CANONICAL
# `libudev.so.1` soname on purpose, and the host has its own copy.
SONAMES='libEGL|libGLESv2|libGLdispatch|libgbm|libdrm|libwayland|libffi|libexpat|libudev'

say "5. what the loader actually resolved"
BIN=$(find "$W/target" -name closed-loop -type f -perm -u+x | head -1)
[ -n "$BIN" ] || { echo "FAIL: no binary"; exit 1; }
I=$(readelf -p .interp "$BIN" | grep -oE '/[^ ]*ld-linux[^ ]*')
"$I" --list "$BIN" | grep -E "$SONAMES" \
    | sed "s|$SUBOS|<subos>|g; s|$W|<project>|g"

say "6. did anything come from the host?"
if "$I" --list "$BIN" | grep -E "$SONAMES" | grep -qE '=> /(usr/)?lib/'; then
    echo "  FAIL: a graphics library resolved to the host"
    "$I" --list "$BIN" | grep -E "$SONAMES" | grep -E '=> /(usr/)?lib/'
    exit 1
fi
echo "  PASS: the host's copies were present and reachable, and none of them won"

say "6b. and the merged-in ones brought no shared library at all"
# The `kind = "lib"` half, checked by ABSENCE rather than by origin.
#
# Their objects are linked into the binary, so a correct build has no
# DT_NEEDED for them — from anywhere. If `libinput.so.10` or `libevdev.so.2`
# shows up in the load map, the link was satisfied by a shared library instead
# of by the descriptor's objects, and on this machine that library is the
# HOST's. Step 6 cannot see it: these sonames are deliberately not in $SONAMES
# because in a correct build there is nothing there to inspect.
#
# Absence, not `nm`: a stripped binary has no .symtab, so "the symbol is
# defined here" is not reliably answerable, while "no shared library provides
# it" is — and it is the same claim from the other side. That the code is
# present and works is what step 7 demonstrates.
MERGED='libinput\.so|libevdev\.so|libmtdev\.so|libxkbcommon\.so|libpixman'
if "$I" --list "$BIN" | grep -E "$MERGED"; then
    echo "  FAIL: a kind=\"lib\" package resolved to a shared library (above)"
    exit 1
fi
echo "  PASS: none of libinput/libevdev/libmtdev/libxkbcommon/pixman is a DT_NEEDED"

say "7. run it"
# Captured rather than streamed, because one of the assertions below is about
# what libinput printed. Shown in full either way.
OUT=/home/speak/closed-loop.out
"$BIN" >"$OUT" 2>&1 || true
cat "$OUT"

say "8. the datasets the ecosystem supplies, checked by their absence of complaint"
# Two of the discovery variables lead to DATA rather than to code, and both
# degrade GRACEFULLY when unset — libinput runs on built-in defaults, xkbcommon
# compiles only keymaps handed to it as strings. A run without them still says
# PASS everywhere above, which is exactly why they need their own check.
#
# The observable is the complaint. libinput logs
#
#     failed to find data files ... will negatively affect device behavior
#
# when its quirks directory is empty or unset. So: if the variable is set, that
# message must be GONE. If it is not set, this reports rather than fails —
# a subos without the datasets is a legitimate configuration, not a defect.
data_fail=0
if [ -n "${LIBINPUT_QUIRKS_DIR:-}" ]; then
    echo "  LIBINPUT_QUIRKS_DIR = $LIBINPUT_QUIRKS_DIR ($(ls "$LIBINPUT_QUIRKS_DIR"/*.quirks 2>/dev/null | wc -l) files)"
    if grep -q 'failed to find data files' "$OUT"; then
        echo "  FAIL: the quirks database is declared but libinput did not load it"
        data_fail=1
    else
        echo "  ok: libinput loaded the quirks database (no 'failed to find data files')"
    fi
else
    echo "  LIBINPUT_QUIRKS_DIR unset — install xim:libinput-quirks to exercise this"
    grep -q 'failed to find data files' "$OUT" \
        && echo "  (and libinput said so, as it should)"
fi

if [ -n "${XKB_CONFIG_ROOT:-}" ]; then
    echo "  XKB_CONFIG_ROOT     = $XKB_CONFIG_ROOT ($(ls "$XKB_CONFIG_ROOT/symbols" 2>/dev/null | wc -l) layouts)"
    grep -q 'the real us layout compiled: yes' "$OUT" \
        || { echo "  FAIL: the dataset is declared but the us layout did not compile"; data_fail=1; }
else
    echo "  XKB_CONFIG_ROOT unset — install xim:xkeyboard-config to exercise this"
fi
[ "$data_fail" -eq 0 ] || exit 1

say "RESULT"
echo "  PASS"
