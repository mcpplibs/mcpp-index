-- toml++ (marzer/tomlplusplus) — a TOML config file parser and serializer for
-- C++17 (and later), exposed as the C++23 module `tomlplusplus`: `import
-- tomlplusplus;` works out of the box, from the project AND from build.mcpp:
--
--   [build-dependencies.marzer]
--   tomlplusplus = { version = "3.4.0", host-module = true }
--
-- Form A, with install() writing the manifest. Why not Form B (`mcpp = {...}`
-- with generated_files), which this package used before:
--   * a build.mcpp host module needs a lib root, `[lib] path` or
--     `src/<name>.cppm`, and the Form B vocabulary has no `lib` key. The lib
--     root states the export surface, so it is written down here, not inferred.
--   * mcpp reads no verdir mcpp.toml while a Form B table is present, and
--     generated_files exists only inside that table — so the manifest is
--     written by install(), into the unpacked tree, next to upstream's files.
--
-- Why generated at all: the released v3.4.0 tarball is header-only and ships NO
-- module interface unit. Upstream HAS authored an official one at
-- `src/modules/tomlplusplus.cppm` (`export module tomlplusplus;`), but only on
-- `master` (v3.4.0 404s for that path). install() writes it at that same path,
-- so the payload has the shape a future release will have. The base headers
-- stay pinned to the reproducible v3.4.0 release tag, straight from upstream —
-- no fork in the trust path.
--
-- TWO deviations from upstream master's cppm, deliberate and minimal:
--   * `using TOML_NAMESPACE::get_line;` is dropped: `get_line` was added to
--     `impl/source_region.hpp` AFTER v3.4.0 and does not exist in the pinned
--     headers.
--   * the global module fragment includes `"../../include/toml++/toml.hpp"`
--     instead of `<toml++/toml.hpp>`: mcpp compiles a host module alone, with
--     none of the package's include_dirs (mcpp-community/mcpp#797). The
--     relative path names the same file in every compile, so ordinary
--     consumers are unaffected.
--
-- Evolution: once a toml++ release (>3.4.0) ships src/modules/tomlplusplus.cppm,
-- install() stops writing the unit (keeping only mcpp.toml), and get_line comes
-- back with it; once mcpp#797 lands, the include returns to `<toml++/toml.hpp>`.
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
                -- 1: Form B -> Form A (install() writes mcpp.toml + the module unit).
                revision = 1,
            },
        },
        macosx = {
            ["3.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/marzer/tomlplusplus/archive/refs/tags/v3.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tomlplusplus/releases/download/3.4.0/tomlplusplus-3.4.0.tar.gz",
                },
                sha256 = "8517f65938a4faae9ccf8ebb36631a38c1cadfb5efa85d9a72e15b9e97d25155",
                -- 1: Form B -> Form A (install() writes mcpp.toml + the module unit).
                revision = 1,
            },
        },
        windows = {
            ["3.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/marzer/tomlplusplus/archive/refs/tags/v3.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/tomlplusplus/releases/download/3.4.0/tomlplusplus-3.4.0.tar.gz",
                },
                sha256 = "8517f65938a4faae9ccf8ebb36631a38c1cadfb5efa85d9a72e15b9e97d25155",
                -- 1: Form B -> Form A (install() writes mcpp.toml + the module unit).
                revision = 1,
            },
        },
    },

    -- `*` absorbs the archive's tomlplusplus-<version>/ wrap layer.
    mcpp = "*/mcpp.toml",
}

local MCPP_TOML = [==[
[package]
namespace = "marzer"
name      = "tomlplusplus"
version   = "@VERSION@"
standard  = "c++23"

[language]
import_std = false

# The export surface: the one module unit. Required by build.mcpp's
# host-module path, which has no other way to find it.
[lib]
path = "src/modules/tomlplusplus.cppm"

[modules]
exports = ["tomlplusplus"]

[build]
sources      = ["src/modules/tomlplusplus.cppm"]
# The module unit's GMF and users who prefer `#include <toml++/toml.hpp>`.
include_dirs = ["include"]

[targets.tomlplusplus]
kind = "lib"
]==]

-- Upstream's official module unit (master @ src/modules/tomlplusplus.cppm),
-- reproduced verbatim apart from the two deviations documented above.
local MODULE_UNIT = [==[
/**
 * @file tomlpp.cppm
 * @brief File containing the module declaration for toml++.
 */

module;

#define TOML_UNDEF_MACROS 0
// mcpp#797: a host-module compile is not given this package's include_dirs,
// so reach the header relative to this file (src/modules/ -> include/).
// Same file either way; restore `<toml++/toml.hpp>` once mcpp#797 is settled.
#include "../../include/toml++/toml.hpp"

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
]==]

import("xim.libxpkg.pkginfo")

function install()
    -- Reproduce the default unpack shape — install_dir/<wrap>/... — so the
    -- `*/mcpp.toml` pointer matches exactly one wrap level. NO SHELL and no
    -- directory listing in this sandbox: the wrap is asked about by name.
    local v     = pkginfo.version()
    local idir  = pkginfo.install_dir()
    local layer = path.join(idir, "tomlplusplus-" .. v)
    os.tryrm(idir)
    os.mkdir(idir)
    for _, name in ipairs({ "tomlplusplus-" .. v, "tomlplusplus-v" .. v }) do
        if os.isfile(path.join(name, "include", "toml++", "toml.hpp")) then
            os.mv(name, layer)
            break
        end
    end
    if not os.isfile(path.join(layer, "include", "toml++", "toml.hpp")) then
        log.error("tomlplusplus: no include/toml++/toml.hpp under %s after "
                  .. "unpacking; the archive layout changed", layer)
        return false
    end

    io.writefile(path.join(layer, "mcpp.toml"),
                 (MCPP_TOML:gsub("@VERSION@", v)))
    os.mkdir(path.join(layer, "src", "modules"))
    io.writefile(path.join(layer, "src", "modules", "tomlplusplus.cppm"), MODULE_UNIT)
    return true
end
