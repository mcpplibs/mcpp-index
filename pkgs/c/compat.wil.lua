-- compat.wil — the Windows Implementation Library: header-only RAII wrappers
-- over Win32 handles, COM pointers and HRESULT-based error handling.
-- A consumer writes `#include <wil/resource.h>`, `<wil/com.h>`, `<wil/result.h>`.
--
-- Shape B (header-only + anchor TU): `*/include` is the whole library, and a
-- trivial anchor gives mcpp a buildable lib target — the compat.eigen /
-- compat.opengl shape.
--
-- WINDOWS-ONLY, and unusually so: this is not a portable library with a Windows
-- backend, it is a library ABOUT Win32. There is no `linux`/`macosx` section to
-- declare, so `check_platform_version_parity` is satisfied by there being only
-- one platform section to compare. Consumers gate the dependency with
-- `[target.'cfg(windows)'.dependencies.compat]`, which is what the test member
-- here does — the same shape compat.x11 and friends use in the other direction.
--
-- NOTHING IS CONFIGURED, on purpose. WIL's behaviour knobs are all macros the
-- CONSUMER defines before including a header — WIL_ENABLE_EXCEPTIONS (on by
-- default when /EHsc is in effect), RESULT_DIAGNOSTICS_LEVEL,
-- WIL_SUPPRESS_EXCEPTIONS, WIL_USE_STL. A package that pre-set any of them would
-- be choosing an error model on its consumers' behalf, and since the library is
-- header-only there is no compiled artifact for the choice to be baked into
-- anyway.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "wil",
    description = "Windows Implementation Library: header-only RAII for Win32 handles, COM and HRESULT",
    licenses    = {"MIT"},
    repo        = "https://github.com/microsoft/wil",
    type        = "package",

    xpm = {
        windows = {
            ["1.0.260126.7"] = {
                url = {
                    GLOBAL = "https://github.com/microsoft/wil/archive/refs/tags/v1.0.260126.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/wil/releases/download/1.0.260126.7/wil-1.0.260126.7.tar.gz",
                },
                sha256 = "de9e03b38ff0ff8d22048f00b111cb631d21c550328f12530ccba71c05c9e361",
            },
        },
    },

    -- Windows is the only platform this library exists for; the other two
    -- sections are absent rather than empty.
    platform_versions_diverge = true,

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/wil_anchor.c"] = "int mcpp_compat_wil_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/wil_anchor.c" },
        targets = { ["wil"] = { kind = "lib" } },
        deps    = { },
    },
}
