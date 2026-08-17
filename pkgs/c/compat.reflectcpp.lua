-- compat.reflectcpp — reflect-cpp, compile-time reflection for C++ structs plus
-- the serialization formats built on it. A consumer writes `#include <rfl.hpp>`
-- and `#include <rfl/json.hpp>`.
--
-- Shape A with an umbrella TU. Upstream ships ONE umbrella source per backend
-- (`src/reflectcpp.cpp` pulls the five core `rfl/*.cpp`, `src/reflectcpp_json.cpp`
-- pulls `rfl/json/{Writer,to_schema}.cpp`), which is what its own CMake compiles.
--
-- ONLY core + JSON are compiled here. The avro / bson / capnproto / cbor /
-- flexbuf / msgpack / toml / xml / yaml umbrellas each `#include` a third-party
-- library's headers — avro-c, libbson, capnproto, tinyxml2, yaml-cpp, … — so
-- compiling them would turn an otherwise dependency-free package into one with
-- nine external dependencies. They belong behind features, each with its own
-- `deps`, once there is a descriptor for the library each needs.
--
-- yyjson comes from INSIDE reflect-cpp, and that is deliberate. `rfl/json/*.hpp`
-- probes `__has_include(<yyjson.h>)`: if an external yyjson is on the include
-- path it uses that one, otherwise it falls back to
-- `include/rfl/thirdparty/yyjson.h`. Exposing only `include/` keeps the vendored
-- copy in play, so this package does NOT depend on compat.yyjson and cannot
-- disagree with it about yyjson's version. `src/yyjson.c` — the vendored
-- implementation — includes `"yyjson.h"` flat, which is why
-- `include/rfl/thirdparty` is a second include root: it is where that header is.
--
-- A consumer that wants the *external* yyjson simply depends on compat.yyjson
-- too; its include root then wins the `__has_include` probe. Nothing here has
-- to change for that, but the two copies must then agree on
-- `yyjson_api_inline`, so it is not the default.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "reflectcpp",
    description = "Compile-time reflection and serialization for C++ structs (core + JSON)",
    licenses    = {"MIT"},
    repo        = "https://github.com/getml/reflect-cpp",
    type        = "package",

    xpm = {
        linux = {
            ["0.25.0"] = {
                url = {
                    GLOBAL = "https://github.com/getml/reflect-cpp/archive/refs/tags/v0.25.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/reflectcpp/releases/download/0.25.0/reflectcpp-0.25.0.tar.gz",
                },
                sha256 = "de74d3793fd3dde9105ebe0f40bffb28df7009d59e0714389e4d29fcb46a1a3f",
            },
        },
        macosx = {
            ["0.25.0"] = {
                url = {
                    GLOBAL = "https://github.com/getml/reflect-cpp/archive/refs/tags/v0.25.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/reflectcpp/releases/download/0.25.0/reflectcpp-0.25.0.tar.gz",
                },
                sha256 = "de74d3793fd3dde9105ebe0f40bffb28df7009d59e0714389e4d29fcb46a1a3f",
            },
        },
        windows = {
            ["0.25.0"] = {
                url = {
                    GLOBAL = "https://github.com/getml/reflect-cpp/archive/refs/tags/v0.25.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/reflectcpp/releases/download/0.25.0/reflectcpp-0.25.0.tar.gz",
                },
                sha256 = "de74d3793fd3dde9105ebe0f40bffb28df7009d59e0714389e4d29fcb46a1a3f",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include", "*/include/rfl/thirdparty" },
        sources      = {
            "*/src/reflectcpp.cpp",
            "*/src/reflectcpp_json.cpp",
            "*/src/yyjson.c",
        },
        targets      = { ["reflectcpp"] = { kind = "lib" } },
        deps         = { },
    },
}
