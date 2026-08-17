-- compat.sqlitecpp — SQLiteCpp, a thin RAII C++ wrapper over the SQLite C API.
-- A consumer writes `#include <SQLiteCpp/SQLiteCpp.h>`.
--
-- Shape A, with the one interesting bit being where SQLite comes from.
--
-- Upstream vendors sqlite3 as a GIT SUBMODULE, and a source tarball carries no
-- submodules — so `sqlite3/sqlite3.c` simply is not in the archive and the
-- library would not link. The dependency edge on `compat.sqlite3` replaces it,
-- which is also the better arrangement: two consumers of SQLite in one link now
-- share ONE amalgamation rather than each embedding a private copy with its own
-- compile-time options.
--
-- WHAT IS NOT COMPILED. `src/` holds exactly the wrapper's 11 TUs and nothing
-- else, so the glob needs no trimming. Upstream's `tests/`, `examples/` and the
-- `googletest/` submodule are elsewhere in the tree.
--
-- COMPILE OPTIONS ARE DELIBERATELY ABSENT. SQLiteCpp's CMake offers
-- SQLITECPP_USE_ASSERT_ON_ERRORS (aborts the process on a misused API instead of
-- throwing) and SQLITE_ENABLE_COLUMN_METADATA (adds Column::getOriginName and
-- friends, and requires the SAME define when SQLite itself was built). Neither
-- is something a package should decide for its consumers: the first changes the
-- error model, the second has to agree with compat.sqlite3's build. The headers
-- guard both with #ifdef, so a consumer that wants either declares it — and for
-- the metadata one, must also build SQLite with it.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "sqlitecpp",
    description = "SQLiteCpp: a smart and easy to use C++ SQLite3 wrapper",
    licenses    = {"MIT"},
    repo        = "https://github.com/SRombauts/SQLiteCpp",
    type        = "package",

    xpm = {
        linux = {
            ["3.3.3"] = {
                url = {
                    GLOBAL = "https://github.com/SRombauts/SQLiteCpp/archive/refs/tags/3.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sqlitecpp/releases/download/3.3.3/sqlitecpp-3.3.3.tar.gz",
                },
                sha256 = "33bd4372d83bc43117928ee842be64d05e7807f511b5195f85d30015cad9cac6",
            },
        },
        macosx = {
            ["3.3.3"] = {
                url = {
                    GLOBAL = "https://github.com/SRombauts/SQLiteCpp/archive/refs/tags/3.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sqlitecpp/releases/download/3.3.3/sqlitecpp-3.3.3.tar.gz",
                },
                sha256 = "33bd4372d83bc43117928ee842be64d05e7807f511b5195f85d30015cad9cac6",
            },
        },
        windows = {
            ["3.3.3"] = {
                url = {
                    GLOBAL = "https://github.com/SRombauts/SQLiteCpp/archive/refs/tags/3.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sqlitecpp/releases/download/3.3.3/sqlitecpp-3.3.3.tar.gz",
                },
                sha256 = "33bd4372d83bc43117928ee842be64d05e7807f511b5195f85d30015cad9cac6",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        include_dirs = { "*/include" },
        sources      = { "*/src/*.cpp" },
        targets      = { ["SQLiteCpp"] = { kind = "lib" } },
        deps         = { ["compat.sqlite3"] = "3.45.3" },
    },
}
