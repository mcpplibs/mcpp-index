-- compat.arrow-adbc — Apache Arrow ADBC (Arrow Database Connectivity) C/C++
-- driver manager and optional bundled drivers.
--
-- Core build compiles only the C/C++ driver manager (`adbc_driver_manager`,
-- 4 TUs) with zero external dependencies (vendored `<toml++/toml.hpp>` lives
-- privately inside `*/c/vendor` and never enters consumer include paths).
--
-- Enabling the optional `sqlite` feature adds the in-tree SQLite ADBC driver
-- (6 C/C++ TUs: sqlite, statement_reader, driver/common, driver/framework,
-- vendored nanoarrow) together with `compat.sqlite3` and `compat.fmt`.
--
-- Static export handling: `adbc.h` checks `#if !defined(ADBC_EXPORT)` and
-- defaults to `__declspec(dllimport)` on `_WIN32` unless `ADBC_EXPORT` is
-- pre-defined. Since top-level `defines` stays package-private, `default`
-- implies `staticlib` carrying `defines = { "ADBC_EXPORT=" }`, which
-- interface-propagates to both package and consumer translation units.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "arrow-adbc",
    description = "Apache Arrow ADBC (Arrow Database Connectivity) C/C++ driver manager and optional SQLite driver",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/apache/arrow-adbc",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "apache-arrow-adbc-${version}",
            url = "https://github.com/apache/arrow-adbc/releases/download/${tag}/apache-arrow-adbc-${version}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["25"] = {
                url    = "https://github.com/apache/arrow-adbc/releases/download/apache-arrow-adbc-25/apache-arrow-adbc-25.tar.gz",
                sha256 = "de2910f951eeb3c57d882e621a32d133580cc6b0ad01ac25056f4ac709b8b2c0",
            },
        },
        macosx = {
            ["25"] = {
                url    = "https://github.com/apache/arrow-adbc/releases/download/apache-arrow-adbc-25/apache-arrow-adbc-25.tar.gz",
                sha256 = "de2910f951eeb3c57d882e621a32d133580cc6b0ad01ac25056f4ac709b8b2c0",
            },
        },
        windows = {
            ["25"] = {
                url    = "https://github.com/apache/arrow-adbc/releases/download/apache-arrow-adbc-25/apache-arrow-adbc-25.tar.gz",
                sha256 = "de2910f951eeb3c57d882e621a32d133580cc6b0ad01ac25056f4ac709b8b2c0",
            },
        },
    },

    mcpp = {
        language      = "c++23",
        import_std    = false,
        c_standard    = "c11",
        license_files = { "*/LICENSE.txt", "*/NOTICE.txt" },

        -- Public ADBC C headers (`<arrow-adbc/adbc.h>`, `<arrow-adbc/adbc_driver_manager.h>`,
        -- `<arrow-adbc/driver/sqlite.h>`, `<adbc.h>`, `<adbc_driver_manager.h>`).
        include_dirs = { "*/c/include" },

        generated_files = {
            ["mcpp_generated/driver/sqlite/config.h"] = [==[
/* configure_file() of c/driver/sqlite/config.h.in for apache-arrow-adbc-25 (ADBC_VERSION 1.13.0). */
#define SQLITE_DRIVER_VERSION_STRING "1.13.0"
]==],
        },

        -- Core driver manager (zero external dependencies).
        sources = {
            "*/c/driver_manager/adbc_driver_manager.cc",
            "*/c/driver_manager/adbc_driver_manager_api.cc",
            "*/c/driver_manager/adbc_driver_manager_driver_loading.cc",
            "*/c/driver_manager/adbc_driver_manager_profiles.cc",
        },

        targets = { ["arrow-adbc"] = { kind = "lib" } },
        deps    = {},

        features = {
            ["default"] = {
                implies = { "staticlib" },
            },
            ["staticlib"] = {
                defines = { "ADBC_EXPORT=" },
            },
            ["sqlite"] = {
                sources = {
                    "*/c/driver/sqlite/sqlite.cc",
                    "*/c/driver/sqlite/statement_reader.c",
                    "*/c/driver/common/utils.c",
                    "*/c/driver/framework/objects.cc",
                    "*/c/driver/framework/utility.cc",
                    "*/c/vendor/nanoarrow/nanoarrow.c",
                },
                deps = {
                    ["compat.sqlite3"] = "3.45.3",
                    ["compat.fmt"]     = "12.2.0",
                },
                flags = {
                    {
                        glob    = "*/c/driver/sqlite/sqlite.cc",
                        defines = { "ADBC_NO_COMMON_ENTRYPOINTS" },
                    },
                    {
                        glob    = "*/c/driver/sqlite/statement_reader.c",
                        defines = { "SIZEOF_TIME_T=8" },
                    },
                },
            },
        },

        linux = {
            include_dirs         = { "*/c", "*/c/vendor", "*/c/driver", "mcpp_generated" },
            private_include_dirs = { "*/c", "*/c/vendor", "*/c/driver", "mcpp_generated" },
            cxxflags             = { "-DADBC_CONDA_BUILD=0" },
            ldflags              = { "-ldl" },
        },

        macosx = {
            include_dirs         = { "*/c", "*/c/vendor", "*/c/driver", "mcpp_generated" },
            private_include_dirs = { "*/c", "*/c/vendor", "*/c/driver", "mcpp_generated" },
            cxxflags             = { "-DADBC_CONDA_BUILD=0" },
        },

        windows = {
            include_dirs         = { "*/c", "*/c/vendor", "*/c/driver", "mcpp_generated" },
            private_include_dirs = { "*/c", "*/c/vendor", "*/c/driver", "mcpp_generated" },
            cxxflags             = { "-DADBC_CONDA_BUILD=0", "-DNOMINMAX", "-D_CRT_SECURE_NO_WARNINGS" },
            cflags               = { "-D_CRT_SECURE_NO_WARNINGS" },
            ldflags              = { "-ladvapi32", "-luuid", "-lshell32" },
        },
    },
}
