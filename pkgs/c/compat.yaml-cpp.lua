-- compat.yaml-cpp — yaml-cpp, a YAML 1.2 parser and emitter for C++.
--
-- Shape A (C++ source compat): no configure step, no generated config header,
-- no submodules, no platform code in the library itself, so one source list
-- covers linux/macosx/windows and both versions.
--
-- TWO VERSIONS, ONE SOURCE LIST. 0.9.0 adds exactly one translation unit
-- (src/fptostring.cpp, shortest round-trip float formatting over the vendored
-- src/contrib/dragonbox.h) and one public header (yaml-cpp/fptostring.h); the
-- `*/src/*.cpp` glob picks it up where it exists. The two tags are spelled
-- differently upstream (`0.8.0` vs `yaml-cpp-0.9.0`), so the archive wrap dirs
-- differ too (`yaml-cpp-0.8.0/` vs `yaml-cpp-yaml-cpp-0.9.0/`); the leading `*`
-- absorbs both.
--
-- Sources are upstream's CMake target exactly: `src/*.cpp` plus, with
-- YAML_CPP_BUILD_CONTRIB at its default ON, `src/contrib/*.cpp` (the
-- GraphBuilder API declared in the public yaml-cpp/contrib/graphbuilder.h).
-- The src/ headers are all reached by same-directory quoted includes, so the
-- private `src` include root upstream adds is not needed.
--
-- Upstream defect, left as upstream has it: GraphBuilderInterface's destructor
-- is declared pure virtual and defined nowhere, so a class derived from it
-- links only if its user defines `~GraphBuilderInterface()`. Supplying it here
-- would give every consumer who already writes it a duplicate symbol.
--
-- YAML_CPP_STATIC_DEFINE. Upstream's CMake makes it a PUBLIC definition of a
-- static build, and include/yaml-cpp/dll.h is the only header that reads it.
-- Without it, on the MSVC ABI (this index's windows leg defines _MSC_VER),
-- every YAML_CPP_API declaration becomes __declspec(dllimport) and a consumer
-- of these statically linked objects fails with `__declspec(dllimport)`
-- undefined symbols; on ELF it is only the difference between
-- visibility("default") and nothing, so Linux never notices. A descriptor's
-- `defines` reach only this package's own TUs, so the define is delivered to
-- consumers by a same-named shim that every public header already funnels
-- through, and tests/examples/yaml-cpp asserts it arrived.
--
-- openkal: nothing here is conditional on it. yaml-cpp needs only the C++
-- standard library, and its one compiler-specific branch (dragonbox.h's
-- <intrin.h> under _MSC_VER) is taken only where _MSC_VER is defined.
-- tests/openkal/members.toml measures tests/examples/yaml-cpp.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "yaml-cpp",
    description = "yaml-cpp — YAML 1.2 parser and emitter for C++ (static)",
    licenses    = {"MIT"},
    repo        = "https://github.com/jbeder/yaml-cpp",
    type        = "package",

    xpm = {
        linux = {
            ["0.8.0"] = {
                url = {
                    GLOBAL = "https://github.com/jbeder/yaml-cpp/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/yaml-cpp/releases/download/0.8.0/yaml-cpp-0.8.0.tar.gz",
                },
                sha256 = "fbe74bbdcee21d656715688706da3c8becfd946d92cd44705cc6098bb23b3a16",
            },
            ["0.9.0"] = {
                url = {
                    GLOBAL = "https://github.com/jbeder/yaml-cpp/archive/refs/tags/yaml-cpp-0.9.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/yaml-cpp/releases/download/0.9.0/yaml-cpp-0.9.0.tar.gz",
                },
                sha256 = "25cb043240f828a8c51beb830569634bc7ac603978e0f69d6b63558dadefd49a",
            },
        },
        macosx = {
            ["0.8.0"] = {
                url = {
                    GLOBAL = "https://github.com/jbeder/yaml-cpp/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/yaml-cpp/releases/download/0.8.0/yaml-cpp-0.8.0.tar.gz",
                },
                sha256 = "fbe74bbdcee21d656715688706da3c8becfd946d92cd44705cc6098bb23b3a16",
            },
            ["0.9.0"] = {
                url = {
                    GLOBAL = "https://github.com/jbeder/yaml-cpp/archive/refs/tags/yaml-cpp-0.9.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/yaml-cpp/releases/download/0.9.0/yaml-cpp-0.9.0.tar.gz",
                },
                sha256 = "25cb043240f828a8c51beb830569634bc7ac603978e0f69d6b63558dadefd49a",
            },
        },
        windows = {
            ["0.8.0"] = {
                url = {
                    GLOBAL = "https://github.com/jbeder/yaml-cpp/archive/refs/tags/0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/yaml-cpp/releases/download/0.8.0/yaml-cpp-0.8.0.tar.gz",
                },
                sha256 = "fbe74bbdcee21d656715688706da3c8becfd946d92cd44705cc6098bb23b3a16",
            },
            ["0.9.0"] = {
                url = {
                    GLOBAL = "https://github.com/jbeder/yaml-cpp/archive/refs/tags/yaml-cpp-0.9.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/yaml-cpp/releases/download/0.9.0/yaml-cpp-0.9.0.tar.gz",
                },
                sha256 = "25cb043240f828a8c51beb830569634bc7ac603978e0f69d6b63558dadefd49a",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,

        -- Consumers write `#include <yaml-cpp/yaml.h>`. ORDER MATTERS:
        -- mcpp_generated FIRST, so the dll.h shim below is found before
        -- upstream's, which it then reaches with #include_next.
        include_dirs = { "mcpp_generated", "*/include" },

        generated_files = {
            -- Delivers YAML_CPP_STATIC_DEFINE to every TU that opens a
            -- yaml-cpp header, which no descriptor key can do. See the header
            -- note.
            ["mcpp_generated/yaml-cpp/dll.h"] = [==[
// mcpp-index shim: yaml-cpp is built as objects here, not as a shared library,
// so every declaration must be plain rather than dllimport/visibility-default.
// Upstream reads YAML_CPP_STATIC_DEFINE in this header and nowhere else, and
// every public yaml-cpp header reaches this one.
#ifndef MCPP_COMPAT_YAML_CPP_STATIC_SHIM
#define MCPP_COMPAT_YAML_CPP_STATIC_SHIM
#ifndef YAML_CPP_STATIC_DEFINE
#  define YAML_CPP_STATIC_DEFINE
#endif
#include_next <yaml-cpp/dll.h>
#endif
]==],
        },

        sources = {
            "*/src/*.cpp",
            "*/src/contrib/*.cpp",
        },

        targets = { ["yaml-cpp"] = { kind = "lib" } },
        deps    = { },

        -- Belt and braces for this package's OWN TUs; the shim above is what
        -- reaches everyone else's.
        defines = { "YAML_CPP_STATIC_DEFINE" },
    },
}
