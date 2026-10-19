-- Form B inline descriptor for SafeInt — header-only checked integer arithmetic.
--
-- Upstream ships two independent public APIs:
--   * SafeInt.hpp   — the C++ SafeInt<T> class;
--   * safe_math.h   — checked C arithmetic over 32- and 64-bit integers.
--
-- Both headers, and safe_math.h's safe_math_impl.h, sit at the archive root,
-- exactly like upstream's INTERFACE include directory. A trivial anchor TU
-- gives mcpp a buildable lib target, following the compat.gtl / compat.eigen
-- shape. There are no optional compilable components to expose as features.
--
-- safe_math.h deliberately rejects a translation unit that has already
-- included SafeInt.hpp, so these APIs must be consumed from separate TUs.
-- A C++ TU using only the C API should wrap #include <safe_math.h> in
-- extern "C"; this keeps upstream's prototype and inline definitions on the
-- same linkage.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "safeint",
    description = "Header-only checked integer arithmetic for C++ and C",
    licenses    = {"MIT"},
    repo        = "https://github.com/dcleblanc/SafeInt",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/dcleblanc/SafeInt/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["3.0.28a"] = {
                -- No verified mcpp-res release is available: use the upstream
                -- archive directly rather than fabricating a CN mirror table.
                url    = "https://github.com/dcleblanc/SafeInt/archive/refs/tags/3.0.28a.tar.gz",
                sha256 = "9e652d065a3cef80623287d5dc61edcf6a95ddab38a9dfeb34f155261fc9cef7",
            },
        },
        macosx = {
            ["3.0.28a"] = {
                url    = "https://github.com/dcleblanc/SafeInt/archive/refs/tags/3.0.28a.tar.gz",
                sha256 = "9e652d065a3cef80623287d5dc61edcf6a95ddab38a9dfeb34f155261fc9cef7",
            },
        },
        windows = {
            ["3.0.28a"] = {
                url    = "https://github.com/dcleblanc/SafeInt/archive/refs/tags/3.0.28a.tar.gz",
                sha256 = "9e652d065a3cef80623287d5dc61edcf6a95ddab38a9dfeb34f155261fc9cef7",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*" },
        generated_files = {
            ["mcpp_generated/safeint_anchor.c"] = [==[
int mcpp_compat_safeint_headers_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/safeint_anchor.c" },
        targets      = { ["safeint"] = { kind = "lib" } },
        deps         = { },
    },
}
