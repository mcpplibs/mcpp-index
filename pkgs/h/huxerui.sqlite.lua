local versions = {
    ["0.1.1"] = {
        url = "https://github.com/HuxerUI/Lib-SQLite/archive/refs/tags/v0.1.1.tar.gz",
        sha256 = "e4c7a02ae508220a2ef324a0e7cb6830c2b5fb33fa9a5094a6bfabc6829ad8c7",
    },
}

-- huxerui.sqlite — HuxerUI SQLite persistence library as a native mcpp module package.
--
-- Form A: upstream carries its own `mcpp.toml` (`Lib-SQLite-0.1.1/mcpp.toml`)
-- and `build.mcpp` (`huxerui.rules`) with vendored SQLite 3.53.4 amalgamation
-- (`third_party/sqlite/sqlite3.c`), exporting `import huxerui.sqlite;`
-- (`modules/sqlite.cppm`), depending on `huxerui.huxerui = "0.5.5"` for
-- transitive SDK and platform dependencies.
--
-- 0.1.1 uses plain upstream GitHub URLs (no CN mcpp-res mirror yet).
package = {
    spec        = "1",
    namespace   = "huxerui",
    name        = "sqlite",
    description = "SQLite persistence library with typed records, queries, transactions, and migrations for HuxerUI",
    licenses    = {"MIT", "LicenseRef-Public-Domain"},
    repo        = "https://github.com/HuxerUI/Lib-SQLite",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/HuxerUI/Lib-SQLite/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.1.1"] = versions["0.1.1"],
        },
        macosx = {
            ["0.1.1"] = versions["0.1.1"],
        },
        windows = {
            ["0.1.1"] = versions["0.1.1"],
        },
    },
}
