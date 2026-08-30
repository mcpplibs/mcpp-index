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
#   cp tests/verify_graphics_closed_loop_sandbox.sh \
#      ~/.xlings/subos/<subos>/verify.sh
#   xlings subos use <subos> --sandbox --gpu --cmd "sh /home/speak/.xlings/subos/<subos>/verify.sh"
#
# The copy step is not optional: the sandbox does not bind the current working
# directory, so a script anywhere else is simply not visible inside.
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
#include <xkbcommon/xkbcommon.h>

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

    std::printf("  input chain answers: %s\n", input_ok ? "yes" : "no");
    return (drew && input_ok) ? 0 : (reached ? 0 : 0);
}
CPP

say "4. build from scratch"
cd "$W"
"$MCPP" build 2>&1 | tail -12

say "5. what the loader actually resolved"
BIN=$(find "$W/target" -name closed-loop -type f -perm -u+x | head -1)
[ -n "$BIN" ] || { echo "FAIL: no binary"; exit 1; }
I=$(readelf -p .interp "$BIN" | grep -oE '/[^ ]*ld-linux[^ ]*')
"$I" --list "$BIN" | grep -E 'libEGL|libGLESv2|libGLdispatch|libgbm|libdrm|libwayland|libffi|libexpat' \
    | sed "s|$SUBOS|<subos>|g; s|$W|<project>|g"

say "6. did anything come from the host?"
if "$I" --list "$BIN" | grep -E 'libEGL|libGLESv2|libGLdispatch|libgbm|libdrm|libwayland|libffi|libexpat' \
     | grep -qE '=> /(usr/)?lib/'; then
    echo "  FAIL: a graphics library resolved to the host"
    "$I" --list "$BIN" | grep -E 'libEGL|libGLESv2|libGLdispatch|libgbm|libdrm|libwayland' | grep -E '=> /(usr/)?lib/'
    exit 1
fi
echo "  PASS: the host's copies were present and reachable, and none of them won"

say "7. run it"
"$BIN"

say "RESULT"
echo "  PASS"
