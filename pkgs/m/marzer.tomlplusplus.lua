-- Form B inline descriptor for toml++ (marzer/tomlplusplus) — a TOML config
-- file parser and serializer for C++17 (and later), exposed as the C++23
-- module `tomlplusplus` so users can write `import tomlplusplus;` out of the
-- box (no opt-in, no `#include` needed).
--
-- Why generated: the released v3.4.0 source tarball is header-only and ships
-- NO module interface unit. Upstream HAS authored an official one at
-- `src/modules/tomlplusplus.cppm` (`export module tomlplusplus;`), but it
-- lives on the `master` branch only and is not in any release tag yet (v3.4.0
-- 404s for that path). So we provide it ourselves via mcpp's `generated_files`,
-- embedding upstream's official tomlplusplus.cppm. The base headers stay
-- pinned to the reproducible v3.4.0 release tag, straight from upstream —
-- no fork in the trust path.
--
-- ONE deviation from upstream master's cppm, deliberate and minimal:
-- `using TOML_NAMESPACE::get_line;` is dropped. `get_line` was added to
-- `impl/source_region.hpp` AFTER v3.4.0 and does not exist in the pinned
-- headers, so re-exporting it would not compile. Every other line is verbatim.
--
-- Evolution: once a toml++ release (>3.4.0) ships src/modules/tomlplusplus.cppm,
-- switch `sources` to "*/src/modules/tomlplusplus.cppm", drop `generated_files`,
-- and the get_line re-export comes back with it.
--
-- include_dirs exposes the tarball's include/ so the module unit's global-module
-- fragment `#include <toml++/toml.hpp>` resolves (and `#include` remains
-- available to users who want it). The upstream path is a GLOB — the leading
-- `*` absorbs the archive's `tomlplusplus-3.4.0/` wrap layer — while the
-- generated cppm path is verdir-relative (no glob), like nlohmann.json.
package = {
    spec        = "1",
    namespace   = "marzer",
    name        = "tomlplusplus",
    description = "TOML config file parser and serializer for C++, exposed as C++23 module tomlplusplus",
    licenses    = {"MIT"},
    repo        = "https://github.com/marzer/tomlplusplus",
    type        = "package",

    xpm = {
        linux = {
            ["3.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/marzer/tomlplusplus/archive/refs/tags/v3.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tomlplusplus/releases/download/3.4.0/tomlplusplus-3.4.0.tar.gz",
                },
                sha256 = "8517f65938a4faae9ccf8ebb36631a38c1cadfb5efa85d9a72e15b9e97d25155",
            },
        },
        macosx = {
            ["3.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/marzer/tomlplusplus/archive/refs/tags/v3.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tomlplusplus/releases/download/3.4.0/tomlplusplus-3.4.0.tar.gz",
                },
                sha256 = "8517f65938a4faae9ccf8ebb36631a38c1cadfb5efa85d9a72e15b9e97d25155",
            },
        },
        windows = {
            ["3.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/marzer/tomlplusplus/archive/refs/tags/v3.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tomlplusplus/releases/download/3.4.0/tomlplusplus-3.4.0.tar.gz",
                },
                sha256 = "8517f65938a4faae9ccf8ebb36631a38c1cadfb5efa85d9a72e15b9e97d25155",
            },
        },
    },

    mcpp = {
        schema       = "0.1",
        language     = "c++23",
        import_std   = false,
        modules      = { "tomlplusplus" },
        include_dirs = { "*/include" },
        -- Upstream's official module unit (master @ src/modules/tomlplusplus.cppm),
        -- reproduced verbatim apart from the get_line drop documented above.
        -- Verdir-relative path, no glob.
        generated_files = {
            ["mcpp_generated/tomlplusplus.cppm"] = [==[
/**
 * @file tomlpp.cppm
 * @brief File containing the module declaration for toml++.
 */

module;

#define TOML_UNDEF_MACROS 0
#include <toml++/toml.hpp>

export module tomlplusplus;

/**
 * @namespace toml
 * @brief The toml++ namespace toml:: 
 */
export namespace toml {
    /**
     * @namespace literals
     * @brief The toml++ namespace toml::literals::
     */
    inline namespace literals {
        using TOML_NAMESPACE::literals::operator""_toml;
        using TOML_NAMESPACE::literals::operator""_tpath;
    }

    using TOML_NAMESPACE::array;
    using TOML_NAMESPACE::date;
    using TOML_NAMESPACE::date_time;
    using TOML_NAMESPACE::inserter;
    using TOML_NAMESPACE::json_formatter;
    using TOML_NAMESPACE::key;
    using TOML_NAMESPACE::node;
    using TOML_NAMESPACE::node_view;
    using TOML_NAMESPACE::parse_error;
    using TOML_NAMESPACE::parse_result;
    using TOML_NAMESPACE::path;
    using TOML_NAMESPACE::path_component;
    using TOML_NAMESPACE::source_position;
    using TOML_NAMESPACE::source_region;
    using TOML_NAMESPACE::table;
    using TOML_NAMESPACE::time;
    using TOML_NAMESPACE::time_offset;
    using TOML_NAMESPACE::toml_formatter;
    using TOML_NAMESPACE::value;
    using TOML_NAMESPACE::yaml_formatter;
    using TOML_NAMESPACE::format_flags;
    using TOML_NAMESPACE::node_type;
    using TOML_NAMESPACE::path_component_type;
    using TOML_NAMESPACE::value_flags;
    using TOML_NAMESPACE::array_iterator;
    using TOML_NAMESPACE::const_array_iterator;
    using TOML_NAMESPACE::const_table_iterator;
    using TOML_NAMESPACE::default_formatter;
    using TOML_NAMESPACE::inserted_type_of;
    using TOML_NAMESPACE::optional;
    using TOML_NAMESPACE::source_index;
    using TOML_NAMESPACE::source_path_ptr;
    using TOML_NAMESPACE::table_iterator;

    using TOML_NAMESPACE::at_path;
    using TOML_NAMESPACE::operator""_toml;
    using TOML_NAMESPACE::operator""_tpath;
    using TOML_NAMESPACE::operator<<;
    using TOML_NAMESPACE::parse;
    using TOML_NAMESPACE::parse_file;

    using TOML_NAMESPACE::is_array;
    using TOML_NAMESPACE::is_boolean;
    using TOML_NAMESPACE::is_chronological;
    using TOML_NAMESPACE::is_container;
    using TOML_NAMESPACE::is_date;
    using TOML_NAMESPACE::is_date_time;
    using TOML_NAMESPACE::is_floating_point;
    using TOML_NAMESPACE::is_integer;
    using TOML_NAMESPACE::is_key;
    using TOML_NAMESPACE::is_key_or_convertible;
    using TOML_NAMESPACE::is_node;
    using TOML_NAMESPACE::is_node_view;
    using TOML_NAMESPACE::is_number;
    using TOML_NAMESPACE::is_string;
    using TOML_NAMESPACE::is_table;
    using TOML_NAMESPACE::is_time;
    using TOML_NAMESPACE::is_value;

	using TOML_NAMESPACE::preserve_source_value_flags;
}
]==],
        },
        sources      = { "mcpp_generated/tomlplusplus.cppm" },
        targets      = { ["tomlplusplus"] = { kind = "lib" } },
        deps         = { },
    },
}
