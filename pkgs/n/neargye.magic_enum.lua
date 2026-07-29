-- Form B inline descriptor for magic_enum — header-only C++17 library for
-- static reflection of enums, exposed as the C++23 module `magic_enum` so
-- users can write `import magic_enum;` out of the box (no opt-in, no
-- `#include` needed).
--
-- The upstream release tarball ships an official C++20 module interface unit
-- at `module/magic_enum.cppm`, but it contains conditional preprocessor blocks
-- (e.g., `#if __has_include(<fmt/format.h>)`) that mcpp's M1 module scanner
-- rejects. So we provide a simplified version via `generated_files`, embedding
-- the essential exports verbatim from upstream.
--
-- include_dirs exposes `include/` so the module unit's global-module-fragment
-- `#include <magic_enum/magic_enum_all.hpp>` resolves (and `#include` remains
-- available to users who want it).
package = {
    spec        = "1",
    namespace   = "neargye",
    name        = "magic_enum",
    description = "Header-only C++17 library for static reflection of enums, exposed as C++23 module magic_enum",
    licenses    = {"MIT"},
    repo        = "https://github.com/Neargye/magic_enum",
    type        = "package",

    xpm = {
        linux = {
            ["0.9.8"] = {
                url    = "https://github.com/Neargye/magic_enum/releases/download/v0.9.8/magic_enum-v0.9.8.tar.gz",
                sha256 = "88709dc8a9697168a75e039470d73ed0cffbc17567976eb5e096f946a2c0d521",
            },
        },
        macosx = {
            ["0.9.8"] = {
                url    = "https://github.com/Neargye/magic_enum/releases/download/v0.9.8/magic_enum-v0.9.8.tar.gz",
                sha256 = "88709dc8a9697168a75e039470d73ed0cffbc17567976eb5e096f946a2c0d521",
            },
        },
        windows = {
            ["0.9.8"] = {
                url    = "https://github.com/Neargye/magic_enum/releases/download/v0.9.8/magic_enum-v0.9.8.tar.gz",
                sha256 = "88709dc8a9697168a75e039470d73ed0cffbc17567976eb5e096f946a2c0d521",
            },
        },
    },

    mcpp = {
        schema       = "0.1",
        sources      = { "module/magic_enum.cppm" },
        import_std   = false,
        scan_overrides = {
            ["module/magic_enum.cppm"] = { provides = { "magic_enum" } }
        },
        modules      = { "magic_enum" },
        include_dirs = { "include" },
        targets      = { ["magic_enum"] = { kind = "lib" } },
        deps         = { },
    },
}