-- Form B inline descriptor for nlohmann/json — "JSON for Modern C++",
-- exposed as the C++23 module `nlohmann.json` so users can write
-- `import nlohmann.json;` out of the box (no opt-in, no `#include` needed).
--
-- Why generated: the released v3.12.0 source tarball is header-only and
-- ships NO module interface unit. Upstream HAS authored an official one at
-- `src/modules/json.cppm` (`export module nlohmann.json;`), but it lives on
-- the `develop` branch only and is not in any release tag yet (v3.12.0 /
-- v3.11.3 both 404 for that path). So we provide it ourselves via mcpp's
-- `generated_files`, embedding upstream's official json.cppm VERBATIM
-- (incl. the literals and the MSVC #3970 `detail` re-exports). The base
-- headers stay pinned to the reproducible v3.12.0 release tag.
--
-- Evolution: once a nlohmann release (>3.12.0) ships src/modules/json.cppm,
-- switch `sources` to "*/src/modules/json.cppm" and drop `generated_files`.
--
-- include_dirs exposes single_include so the wrapper's `#include
-- <nlohmann/json.hpp>` resolves (and `#include` remains available to users
-- who want it). All upstream paths are GLOBS; the wrapper path under
-- mcpp_generated/ is verdir-relative (no glob), like compat.zlib.
package = {
    spec        = "1",
    namespace   = "nlohmann",
    name        = "nlohmann.json",
    description = "JSON for Modern C++, exposed as C++23 module nlohmann.json",
    licenses    = {"MIT"},
    repo        = "https://github.com/nlohmann/json",
    type        = "package",

    xpm = {
        linux = {
            ["3.12.0"] = {
                url    = {
                    GLOBAL = "https://github.com/nlohmann/json/archive/refs/tags/v3.12.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/nlohmann-json/releases/download/3.12.0/nlohmann-json-3.12.0.tar.gz",
                },
                sha256 = "4b92eb0c06d10683f7447ce9406cb97cd4b453be18d7279320f7b2f025c10187",
            },
        },
        macosx = {
            ["3.12.0"] = {
                url    = {
                    GLOBAL = "https://github.com/nlohmann/json/archive/refs/tags/v3.12.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/nlohmann-json/releases/download/3.12.0/nlohmann-json-3.12.0.tar.gz",
                },
                sha256 = "4b92eb0c06d10683f7447ce9406cb97cd4b453be18d7279320f7b2f025c10187",
            },
        },
        windows = {
            ["3.12.0"] = {
                url    = {
                    GLOBAL = "https://github.com/nlohmann/json/archive/refs/tags/v3.12.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/nlohmann-json/releases/download/3.12.0/nlohmann-json-3.12.0.tar.gz",
                },
                sha256 = "4b92eb0c06d10683f7447ce9406cb97cd4b453be18d7279320f7b2f025c10187",
            },
        },
    },

    mcpp = {
        schema       = "0.1",
        language     = "c++23",
        import_std   = false,
        modules      = { "nlohmann.json" },
        include_dirs = { "*/single_include" },
        -- Upstream's official module unit (develop @ src/modules/json.cppm),
        -- reproduced verbatim. Verdir-relative path, no glob.
        generated_files = {
            ["mcpp_generated/nlohmann.json.cppm"] = [==[
module;

// GCC workaround for C++ modules support.
// When using C++20 modules, some compilers (particularly GCC) may have issues
// with template instantiations in the module preamble. If you encounter
// "redefinition" errors when including nlohmann/json.hpp, try one of:
// 1. Include nlohmann/json.hpp in your module preamble BEFORE other #includes
// 2. Or use: import nlohmann.json;  instead of #include <nlohmann/json.hpp>
// 3. Or upgrade to a newer GCC version with better modules support.
// See: https://github.com/nlohmann/json/issues/5103

#include <nlohmann/json.hpp>

export module nlohmann.json;

export
NLOHMANN_JSON_NAMESPACE_BEGIN

using NLOHMANN_JSON_NAMESPACE::adl_serializer;
using NLOHMANN_JSON_NAMESPACE::basic_json;
using NLOHMANN_JSON_NAMESPACE::json;
using NLOHMANN_JSON_NAMESPACE::json_pointer;
using NLOHMANN_JSON_NAMESPACE::ordered_json;
using NLOHMANN_JSON_NAMESPACE::ordered_map;
using NLOHMANN_JSON_NAMESPACE::to_string;

inline namespace literals
{
inline namespace json_literals
{
    using NLOHMANN_JSON_NAMESPACE::literals::json_literals::operator""_json;
    using NLOHMANN_JSON_NAMESPACE::literals::json_literals::operator""_json_pointer;
} // namespace json_literals
} // namespace literals

// Note: the following nlohmann::detail symbols must be exported due to
// an MSVC bug failing to compile without these symbols visible (ticket #3970)
namespace detail
{
    using NLOHMANN_JSON_NAMESPACE::detail::json_sax_dom_callback_parser;
    using NLOHMANN_JSON_NAMESPACE::detail::unknown_size;
} // namespace detail

NLOHMANN_JSON_NAMESPACE_END
]==],
        },
        sources      = { "mcpp_generated/nlohmann.json.cppm" },
        targets      = { ["nlohmann_json"] = { kind = "lib" } },
        deps         = { },
    },
}
