-- Form B inline descriptor for SQLite — the most widely deployed database
-- engine in the world, distributed as a single C amalgamation. Pure-C source
-- build (same shape as compat.cjson / compat.zlib): compile sqlite3.c into a
-- lib, expose sqlite3.h / sqlite3ext.h via include_dirs. shell.c (the
-- interactive CLI) stays out — it pulls in editline/readline dependencies.
-- The amalgamation builds out of the box with no defines.
--
-- VERSION. 3.45.3 is the FINAL maintenance release of the 3.45.x series, the
-- most widely deployed SQLite line: Ubuntu 24.04 LTS ships 3.45.1 and CPython
-- 3.11/3.12/3.13 official installers ship 3.45.1/3.45.3/3.45.3. Pinning this
-- mature baseline rather than the newest release keeps consumers
-- API-compatible with the largest installed base; newer series can be added
-- later as extra xpm rows (the mcpp block never changes).
--
-- No CN mirror: sqlite.org is the authoritative source for the amalgamation
-- (the GitHub sqlite/sqlite mirror does NOT carry the generated sqlite3.c),
-- and plain-string url is the documented fallback without mcpp-res write
-- access (docs/cn-mirror.md; precedent: compat.hiredis / compat.spdlog).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "sqlite3",
    description = "SQLite — self-contained SQL database engine (C amalgamation)",
    licenses    = {"LicenseRef-Public-Domain"},
    repo        = "https://sqlite.org/",
    type        = "package",

    xpm = {
        linux = {
            ["3.45.3"] = {
                url    = "https://sqlite.org/2024/sqlite-amalgamation-3450300.zip",
                sha256 = "ea170e73e447703e8359308ca2e4366a3ae0c4304a8665896f068c736781c651",
            },
        },
        macosx = {
            ["3.45.3"] = {
                url    = "https://sqlite.org/2024/sqlite-amalgamation-3450300.zip",
                sha256 = "ea170e73e447703e8359308ca2e4366a3ae0c4304a8665896f068c736781c651",
            },
        },
        windows = {
            ["3.45.3"] = {
                url    = "https://sqlite.org/2024/sqlite-amalgamation-3450300.zip",
                sha256 = "ea170e73e447703e8359308ca2e4366a3ae0c4304a8665896f068c736781c651",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        -- Tarball root: exposes sqlite3.h and sqlite3ext.h to consumers
        -- writing `#include <sqlite3.h>`.
        include_dirs = { "*" },
        sources      = { "*/sqlite3.c" },
        targets      = { ["sqlite3"] = { kind = "lib" } },
        deps         = { },
    },
}
