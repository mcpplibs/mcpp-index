-- compat.pdfium — Chromium PDFium C library (prebuilt binaries from bblanchon/pdfium-binaries).
-- Upstream PDFium has no standalone source release outside the Chromium GN / depot_tools
-- checkout; bblanchon/pdfium-binaries builds tagged Chromium milestones cleanly across
-- Linux x86_64, macOS arm64, and Windows x64.
--
-- Archives extract flat at the verdir root (include/, lib/, bin/, LICENSE, licenses/).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "pdfium",
    description = "PDFium — Chromium PDF rendering and manipulation C library (prebuilt binaries from pdfium-binaries, Chromium 160.0.8165.0)",
    licenses    = { "BSD-3-Clause", "Apache-2.0" },
    repo        = "https://pdfium.googlesource.com/pdfium/",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "chromium/${version}",
            url = {
                linux   = "https://github.com/bblanchon/pdfium-binaries/releases/download/${tag}/pdfium-linux-x64.tgz",
                macosx  = "https://github.com/bblanchon/pdfium-binaries/releases/download/${tag}/pdfium-mac-arm64.tgz",
                windows = "https://github.com/bblanchon/pdfium-binaries/releases/download/${tag}/pdfium-win-x64.tgz",
            },
        },
    },

    xpm = {
        linux = {
            ["8165"] = {
                url    = "https://github.com/bblanchon/pdfium-binaries/releases/download/chromium/8165/pdfium-linux-x64.tgz",
                sha256 = "ba7865e16c0271daab75256790be06c26272190afe6e2a70eae0bb39bb99089c",
            },
        },
        macosx = {
            ["8165"] = {
                url    = "https://github.com/bblanchon/pdfium-binaries/releases/download/chromium/8165/pdfium-mac-arm64.tgz",
                sha256 = "112e74d717f3e0310273b70f3c8780e8a61ff11b34834124465c8305c841d350",
            },
        },
        windows = {
            ["8165"] = {
                url    = "https://github.com/bblanchon/pdfium-binaries/releases/download/chromium/8165/pdfium-win-x64.tgz",
                sha256 = "ca7338ae7779b8b1b82f4580305c4d762d214f8df1d54b47647fe3cc75989ded",
            },
        },
    },

    mcpp = {
        language      = "c++23",
        import_std    = false,
        c_standard    = "c11",
        include_dirs  = { "include", "include/cpp" },
        license_files = { "LICENSE", "licenses/*" },

        generated_files = {
            ["mcpp_generated/pdfium_anchor.c"] = [=[
#include <stdlib.h>
#include <fpdfview.h>
#if defined(__APPLE__)
#if !defined(__aarch64__) && !defined(_M_ARM64)
#error "compat.pdfium supplies macOS arm64 only"
#endif
#elif !defined(__x86_64__) && !defined(_M_X64)
#error "compat.pdfium supplies Linux/Windows x86_64 only"
#endif
#if defined(__linux__) && !defined(__GLIBC__)
#error "compat.pdfium Linux prebuilt requires glibc"
#endif
#if defined(_WIN32) && !defined(_MSC_VER)
#error "compat.pdfium Windows prebuilt requires the MSVC ABI"
#endif
int mcpp_compat_pdfium_anchor(void) { return 0; }
]=],
        },
        sources = { "mcpp_generated/pdfium_anchor.c" },
        targets = { ["pdfium"] = { kind = "lib" } },
        deps    = {},

        linux = {
            runtime = {
                libraries           = { "pdfium" },
                link_library_dirs   = { "lib" },
                runtime_search_dirs = { "lib" },
            },
        },
        macosx = {
            ldflags = { "-Wl,-rpath,@loader_path" },
            runtime = {
                libraries           = { "pdfium" },
                link_library_dirs   = { "lib" },
                runtime_search_dirs = { "lib" },
            },
        },
        windows = {
            runtime = {
                libraries           = { "pdfium.dll" },
                link_library_dirs   = { "lib" },
                runtime_search_dirs = { "bin" },
            },
        },
    },
}
