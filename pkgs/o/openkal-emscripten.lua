-- openkal-emscripten --- the first implementation written ABOVE a C library.
--
-- Every other implementation in this ecosystem is written on a kernel's own
-- interface: a register discipline, a trap instruction, a table of numbers.
-- Emscripten has no kernel to issue a call to; it has a C library over a
-- JavaScript host, and clause 2 of the specification permits exactly this
-- arrangement in as many words: "an implementation may be built upon a C
-- library, beneath one, or without one."
--
-- Listed for every platform because a platform table describes availability
-- rather than applicability. A project selects this implementation with a
-- conditional dependency on cfg(os = "emscripten"); one that selects it
-- elsewhere fails at compile time, which is the correct place for that
-- failure.
--
-- IT PROVIDES TWELVE OF THE FIFTEEN INTERFACES, and the absence is the report.
-- `openkal.process`, `openkal.exec` and `openkal.space` are not there: no
-- fork, no exec, no writable-then-executable memory, no second address space.
-- A program that uses one of those seventeen names fails at LINK naming the
-- symbol, which is clause 6.2's second time -- the mechanism rather than a
-- defect. Measured:
--
--   wasm-ld: error: obj/main.o: undefined symbol: kal_process_spawn
--
-- `openkal.task` is behind the `threads` feature, because `-pthread` selects a
-- different C library build, memory model and loader contract on this
-- platform. Without the feature its translation unit is empty and the eight
-- symbols do not exist, which is the same treatment the three absent
-- interfaces get. From 0.1.1 the feature states `requires_abi = { threads =
-- true }`, and the consumer's root manifest supplies the switch for the whole
-- link with `[target.'cfg(os = "emscripten")'.abi] threads = true` (mcpp
-- 2026.9.12.2); a consumer that activates the feature without it is refused
-- before anything compiles.
--
-- Conformance, measured with emsdk 6.0.9 under node: 86 held, 0 did not hold,
-- 13 not observed.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-emscripten",
    description = "An implementation of openkal for Emscripten, written above a C library rather than beneath one",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-emscripten",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-emscripten/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-emscripten/releases/download/0.1.1/openkal-emscripten-0.1.1.tar.gz",
                },
                sha256 = "a33359fc3f3d35f713cacd88b5a2859e77d0ddca4662b9c30da5dce83a36ec6d",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-emscripten/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-emscripten/releases/download/0.1.0/openkal-emscripten-0.1.0.tar.gz",
                },
                sha256 = "9c5ca4ae4c3bb22b127e2fbf6ca5bd4ecbdd80eac4a28018e3deb0c7ebd07b6d",
            },
        },
        macosx = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-emscripten/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-emscripten/releases/download/0.1.1/openkal-emscripten-0.1.1.tar.gz",
                },
                sha256 = "a33359fc3f3d35f713cacd88b5a2859e77d0ddca4662b9c30da5dce83a36ec6d",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-emscripten/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-emscripten/releases/download/0.1.0/openkal-emscripten-0.1.0.tar.gz",
                },
                sha256 = "9c5ca4ae4c3bb22b127e2fbf6ca5bd4ecbdd80eac4a28018e3deb0c7ebd07b6d",
            },
        },
        windows = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-emscripten/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-emscripten/releases/download/0.1.1/openkal-emscripten-0.1.1.tar.gz",
                },
                sha256 = "a33359fc3f3d35f713cacd88b5a2859e77d0ddca4662b9c30da5dce83a36ec6d",
            },
            ["0.1.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-emscripten/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-emscripten/releases/download/0.1.0/openkal-emscripten-0.1.0.tar.gz",
                },
                sha256 = "9c5ca4ae4c3bb22b127e2fbf6ca5bd4ecbdd80eac4a28018e3deb0c7ebd07b6d",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
