// The render half of the graphics stack: EGL hands out a context, GLES2 draws.
//
// Every FUNCTION and TYPE below comes from a module — `import khronos.egl;`
// and `import khronos.glesv2;`. The headers are included for the `EGL_*` and
// `GL_*` CONSTANTS only, which are macros and cannot be exported by a module.
//
// ─────────────────────────────────────────────────────────────────────────
// WHY THIS TEST EXISTS AND WHAT IT IS FOR
//
// "libGLESv2 exports 358 symbols" is not the claim worth making — a library
// built from the wrong dispatch table exports about that many too. The claim
// is that a program can get a context and DRAW, and the only honest way to
// check it is to draw and read the pixel back.
//
// So the file has two halves:
//
//   * assertions that hold on ANY machine, including a CI runner with no GPU:
//     the modules carry the API, the libraries are the ones this index built
//     rather than the ecosystem payload's same-soname copies, and all of them
//     route through ONE libGLdispatch;
//   * a real render, gated on a DRM device being present (MCPP_RUN_DRM_DEVICE),
//     because a runner has no /dev/dri at all.
//
// The gate is opt-in for the same reason compat.libdrm's test gates device
// access: a machine without a GPU is not a defect in these packages.
//
// ─────────────────────────────────────────────────────────────────────────
// THE PART THAT IS EASY TO GET FALSELY GREEN
//
// `xim:libglvnd` ships libEGL.so.1, libGLESv2.so.2, libOpenGL.so.0 and
// libGLdispatch.so.0 under exactly these sonames. Only one library per soname
// is ever mapped and nothing warns about the loser, so a test that merely calls
// GL can pass while none of this index's builds are loaded. dladdr pins it.
//
// Note this is a CONSUMER, which is what makes that check meaningful here: the
// fork's own in-package tests link the package's OBJECTS, so their binaries
// define glClear themselves and dladdr reports the executable. Measured.

#ifdef __linux__

#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl32.h>
#include <gbm.h>

#include <dlfcn.h>
#include <fcntl.h>
#include <unistd.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

import khronos.egl;
import khronos.glesv2;

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

// dlsym rather than `&glClear`: taking the address of an imported function
// yields the caller's PLT stub, so dladdr would report this executable.
std::string object_of(const char *symbol)
{
    void *sym = ::dlsym(RTLD_DEFAULT, symbol);
    Dl_info info{};
    if (sym == nullptr || ::dladdr(sym, &info) == 0 || info.dli_fname == nullptr) {
        return {};
    }
    return info.dli_fname;
}

} // namespace

int main()
{
    // ── 1. The modules carry the API ─────────────────────────────────────
    EGLDisplay none = EGL_NO_DISPLAY;
    GLenum     err  = GL_NO_ERROR;
    check(none == EGL_NO_DISPLAY && err == GL_NO_ERROR,
          "the two modules' types and the headers' macros agree");

    // ── 2. Each library is THIS index's build ────────────────────────────
    struct { const char *symbol; const char *library; } from[] = {
        {"eglInitialize",           "libEGL.so.1"},
        {"glClear",                 "libGLESv2.so.2"},
        {"__glDispatchMakeCurrent", "libGLdispatch.so.0"},
    };
    for (auto &f : from) {
        const std::string where = object_of(f.symbol);
        check(!where.empty(), (std::string("dladdr locates ") + f.library).c_str());
        if (where.empty()) {
            continue;
        }
        std::printf("   %-24s <- %s\n", f.symbol, where.c_str());
        check(where.find("xim-x-libglvnd") == std::string::npos,
              "…and it is not the ecosystem payload's copy");
    }

    // ── 3. EGL and GLES2 share ONE dispatch ──────────────────────────────
    // This is what makes the family a family. If libEGL came from one build
    // and libGLESv2 from another, both would work in isolation and a context
    // made by one would dispatch through the other's table — the failure mode
    // GLVND's ABI version exists to catch at runtime rather than at build time.
    {
        const std::string a = object_of("eglInitialize");
        const std::string b = object_of("glClear");
        const std::string d = object_of("__glDispatchMakeCurrent");
        check(!a.empty() && !b.empty() && !d.empty() && a != b,
              "libEGL and libGLESv2 are distinct objects");
        // Both must be reachable from the same build tree, and there must be
        // exactly one libGLdispatch — which is what the single `d` proves.
        check(!d.empty(), "exactly one libGLdispatch answers for the process");
    }

    // ── 4. ONE GL flavour, and the check that it is the right one ────────
    //
    // libGLESv2, libGLESv1_CM and libOpenGL are three front ends onto the same
    // dispatch and their symbol sets overlap — all three export `glClear`. An
    // earlier version of this member depended on all three, and `glClear`
    // resolved to libGLESv1_CM.so.1 in a program that meant GLESv2. Nothing
    // warned; the loader simply took whichever it had mapped first.
    //
    // The assertion has to be about ATTRIBUTION, not presence, and that is
    // worth spelling out because the obvious version does not work:
    // `dlsym(RTLD_DEFAULT, "glMatrixMode") == nullptr` looks like it would
    // prove GLESv1 is not linked, and it never fails — libGLdispatch.so.0
    // exports the FULL GL surface (measured: glMatrixMode is in it), because it
    // is the complete dispatch table and the per-flavour libraries are thin
    // front ends that select a subset of it.
    //
    // So the check is which OBJECT answers: `glClear` must come from the
    // flavour front end this project asked for, not from another one and not
    // from the dispatch underneath.
    {
        const std::string where = object_of("glClear");
        std::printf("   glClear resolves in: %s\n", where.c_str());
        check(where.find("libGLESv2.so") != std::string::npos,
              "glClear resolves in libGLESv2 — the flavour this project asked for");
    }

    // ── 5. A real render, opt-in ─────────────────────────────────────────
    if (std::getenv("MCPP_RUN_DRM_DEVICE") == nullptr) {
        std::puts("\n   (the render is opt-in: set MCPP_RUN_DRM_DEVICE=1 on a "
                  "machine with /dev/dri)");
        std::printf("\n%d check(s) failed\n", failures);
        return failures == 0 ? 0 : 1;
    }

    std::puts("\n-- GBM device -> EGL context -> glClear -> glReadPixels --");

    int fd = -1;
    for (const char *node : {"/dev/dri/renderD128", "/dev/dri/card0"}) {
        fd = ::open(node, O_RDWR);
        if (fd >= 0) {
            std::printf("   node: %s\n", node);
            break;
        }
    }
    if (fd < 0) {
        std::puts("   MCPP_RUN_DRM_DEVICE set but no DRM node opened; skipping");
        std::printf("\n%d check(s) failed\n", failures);
        return failures == 0 ? 0 : 1;
    }

    gbm_device *gbm = gbm_create_device(fd);
    check(gbm != nullptr, "gbm_create_device on a real node");
    if (gbm == nullptr) {
        ::close(fd);
        std::printf("\n%d check(s) failed\n", failures);
        return failures == 0 ? 0 : 1;
    }

    EGLDisplay dpy = eglGetPlatformDisplay(EGL_PLATFORM_GBM_KHR, gbm, nullptr);
    check(dpy != EGL_NO_DISPLAY, "eglGetPlatformDisplay(EGL_PLATFORM_GBM_KHR)");

    EGLint major = 0, minor = 0;
    check(dpy != EGL_NO_DISPLAY && eglInitialize(dpy, &major, &minor) == EGL_TRUE,
          "eglInitialize");
    if (dpy != EGL_NO_DISPLAY) {
        std::printf("   EGL %d.%d, vendor %s\n", major, minor,
                    eglQueryString(dpy, EGL_VENDOR));
    }

    // A SURFACELESS context, and that choice is not incidental.
    //
    // The obvious headless recipe — a pbuffer — does not work on GBM: measured,
    // `eglChooseConfig` with `EGL_SURFACE_TYPE = EGL_PBUFFER_BIT` finds nothing,
    // because GBM's surfaces come from `gbm_surface_create` and the platform
    // advertises no pbuffer configs at all. `EGL_KHR_surfaceless_context` is
    // what the platform does support, and it is also what a compositor uses
    // before it has anything to present to: a context with no default
    // framebuffer, rendering into an FBO.
    check(eglBindAPI(EGL_OPENGL_ES_API) == EGL_TRUE, "eglBindAPI(EGL_OPENGL_ES_API)");

    EGLint cfg_attrs[] = {
        EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
        EGL_RED_SIZE,   8, EGL_GREEN_SIZE, 8,
        EGL_BLUE_SIZE,  8, EGL_ALPHA_SIZE, 8,
        EGL_NONE,
    };
    EGLConfig cfg{};
    EGLint n = 0;
    check(eglChooseConfig(dpy, cfg_attrs, &cfg, 1, &n) == EGL_TRUE && n > 0,
          "eglChooseConfig found an ES2-renderable config");

    EGLint ctx_attrs[] = {EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE};
    EGLContext ctx = eglCreateContext(dpy, cfg, EGL_NO_CONTEXT, ctx_attrs);
    check(ctx != EGL_NO_CONTEXT, "eglCreateContext");

    if (ctx != EGL_NO_CONTEXT) {
        check(eglMakeCurrent(dpy, EGL_NO_SURFACE, EGL_NO_SURFACE, ctx) == EGL_TRUE,
              "eglMakeCurrent with no surface (EGL_KHR_surfaceless_context)");

        // The FBO the surfaceless context renders into. This is the piece a
        // pbuffer would have provided.
        GLuint rb = 0, fbo = 0;
        glGenRenderbuffers(1, &rb);
        glBindRenderbuffer(GL_RENDERBUFFER, rb);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, 64, 64);
        glGenFramebuffers(1, &fbo);
        glBindFramebuffer(GL_FRAMEBUFFER, fbo);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                                  GL_RENDERBUFFER, rb);
        check(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE,
              "a 64x64 RGBA8 framebuffer is complete");

        // THE ASSERTION THIS WHOLE FILE IS FOR. Everything above can pass on a
        // stack that cannot draw; this cannot.
        std::printf("   GL_VERSION  %s\n", glGetString(GL_VERSION));
        std::printf("   GL_RENDERER %s\n", glGetString(GL_RENDERER));
        check(glGetString(GL_VERSION) != nullptr,
              "glGetString(GL_VERSION) answers through the module");

        glClearColor(0.25f, 0.5f, 0.75f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        glFinish();

        unsigned char px[4] = {0, 0, 0, 0};
        glReadPixels(32, 32, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, px);
        std::printf("   pixel read back: %u %u %u %u (wanted ~64 128 191 255)\n",
                    px[0], px[1], px[2], px[3]);

        // One quantisation step of slack: the driver may round the float.
        auto near = [](unsigned char got, int want) {
            return got >= want - 2 && got <= want + 2;
        };
        check(near(px[0], 64) && near(px[1], 128) && near(px[2], 191) && near(px[3], 255),
              "the pixel that came back is the colour that was cleared");

        check(glGetError() == GL_NO_ERROR, "no GL error along the way");

        glDeleteFramebuffers(1, &fbo);
        glDeleteRenderbuffers(1, &rb);
        eglMakeCurrent(dpy, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
    }

    if (ctx != EGL_NO_CONTEXT)  { eglDestroyContext(dpy, ctx); }
    if (dpy != EGL_NO_DISPLAY)  { eglTerminate(dpy); }
    gbm_device_destroy(gbm);
    ::close(fd);

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else

int main() { return 0; }

#endif
