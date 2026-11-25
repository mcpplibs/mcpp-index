local versions = {
    ["0.3.0"] = {
        url = "https://github.com/yizhinailong/mcr/archive/refs/tags/v0.3.0.tar.gz",
        sha256 = "b78af42daa72c1d12de6677237ddc5a6ee0ab266978109110c3a86b3da83e3f9",
    },
}

-- Form A descriptor: mcr is an mcpp-native library — its own mcpp.toml and
-- build.mcpp sit at the archive root — so the descriptor carries identity and
-- the download address only, and the build comes from upstream through
-- `mcpp = "*/mcpp.toml"` (the galay / marzer.tomlplusplus shape).
--
-- GLOBAL is the TAG ARCHIVE, not a release tarball: upstream publishes git
-- tags v0.1.3 .. v0.1.5, but all three GitHub releases are empty (no assets),
-- so there is nothing else to point at. The archive wraps as `mcr-0.1.5/`,
-- which is what the leading `*/` absorbs.
--
-- All three platforms share the one source archive. TLS is not inlined here
-- because mcr's OWN manifest already branches it — Schannel on Windows,
-- `compat.openssl` on linux/macosx — and Form A means upstream keeps owning
-- that decision. Its dependencies are already in this index; 0.2 removes
-- the JSON API and its nlohmann.json dependency.
--
-- No mcpp-res mirror is configured locally, so the plain-string GLOBAL url is
-- the documented fallback for CN consumers (docs/cn-mirror.md) until a
-- maintainer creates the mirror; lint accepts this form.
package = {
    spec        = "1",
    namespace   = "yizhinailong",
    name        = "mcr",
    description = "Modular C++23 HTTP client on libcurl — sync, async, coroutine and batch requests with typed responses",
    licenses    = {"MIT"},
    repo        = "https://github.com/yizhinailong/mcr",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/yizhinailong/mcr/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.1.5"] = {
                url    = "https://github.com/yizhinailong/mcr/archive/refs/tags/v0.1.5.tar.gz",
                sha256 = "bd55e9dc19b620d7dfb89d20fd4a6b1ab9cf947fe872dc536dee53b4e869f8f5",
            },
            ["0.3.0"] = versions["0.3.0"],
        },
        macosx = {
            ["0.1.5"] = {
                url    = "https://github.com/yizhinailong/mcr/archive/refs/tags/v0.1.5.tar.gz",
                sha256 = "bd55e9dc19b620d7dfb89d20fd4a6b1ab9cf947fe872dc536dee53b4e869f8f5",
            },
            ["0.3.0"] = versions["0.3.0"],
        },
        windows = {
            ["0.1.5"] = {
                url    = "https://github.com/yizhinailong/mcr/archive/refs/tags/v0.1.5.tar.gz",
                sha256 = "bd55e9dc19b620d7dfb89d20fd4a6b1ab9cf947fe872dc536dee53b4e869f8f5",
            },
            ["0.3.0"] = versions["0.3.0"],
        },
    },

    mcpp = "*/mcpp.toml",
}

import("xim.libxpkg.pkginfo")

function install()
    local wrap = "mcr-" .. pkginfo.version()
    -- libc++ 20 does not implement views::join_with. Keep the two 0.2
    -- formatting operations usable on the index's macOS baseline, preserving
    -- empty elements, input order and the exact comma-space separator.
    if pkginfo.version() == "0.2.0" then
        local source = path.join(wrap, "src/options/http.cppm")
        local content = assert(io.readfile(source), "mcr: cannot read " .. source):gsub("\r\n", "\n")
        local function patch(before, after)
            local pattern = before:gsub("(%W)", "%%%1")
            local result, count = content:gsub(pattern, function() return after end)
            assert(count == 1, "mcr: expected exactly one formatting expression")
            content = result
        end
        local function joined(collection, item)
            return "std::string joined; bool first = true;\n"
                .. "            for (auto const& value : " .. collection .. ") {\n"
                .. "                if (!first) joined += \", \"; first = false;\n"
                .. "                joined += " .. item .. ";\n"
                .. "            }\n            return joined;"
        end
        patch('return m_methods | std::views::join_with(std::string_view{ ", " }) | std::ranges::to<std::string>();',
            joined("m_methods", "value"))
        patch('return m_ranges | std::views::transform(&Range::Str) | std::views::join_with(std::string_view{ ", " }) | std::ranges::to<std::string>();',
            joined("m_ranges", "value.Str()"))
        io.writefile(source, content)
        source = path.join(wrap, "src/session/session.cppm")
        content = assert(io.readfile(source), "mcr: cannot read " .. source):gsub("\r\n", "\n")
        patch("for (auto const& [index, entry] : m_sessions | std::views::enumerate) {",
            "for (std::size_t index = 0; index < m_sessions.size(); ++index) {\n"
                .. "            auto const& entry = m_sessions[index];")
        io.writefile(source, content)
    end
    local prefix = pkginfo.install_dir()
    os.tryrm(prefix)
    os.mkdir(prefix)
    os.mv(wrap, path.join(prefix, wrap))
    return true
end
