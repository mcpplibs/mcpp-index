-- openkal-dos-tools --- okdos, the seal of a DOS program (openkal-dos's stub
-- before an ELF32 i386 executable). A member of mcpplibs/openkal-dos (one tag,
-- one archive), named by openkal-platform's `[platform.tools]` and run as the
-- DOS row's link seal. Technical experiment only.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-dos-tools",
    description = "okdos: seals an ELF32 i386 executable as a DOS program behind openkal-dos's DPMI stub (technical experiment only)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-dos",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-dos/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-dos/releases/download/0.1.0/openkal-dos-0.1.0.tar.gz",
                },
                sha256 = "2214f353512e114b6fad44e7cfe5f711931a3baefa29de4310b95039d3192e23",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-dos/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-dos/releases/download/0.1.0/openkal-dos-0.1.0.tar.gz",
                },
                sha256 = "2214f353512e114b6fad44e7cfe5f711931a3baefa29de4310b95039d3192e23",
            },
        },
        windows = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-dos/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-dos/releases/download/0.1.0/openkal-dos-0.1.0.tar.gz",
                },
                sha256 = "2214f353512e114b6fad44e7cfe5f711931a3baefa29de4310b95039d3192e23",
            },
        },
    },

    -- The member's manifest, inside the tarball's wrap directory.
    mcpp = "*/tools/mcpp.toml",
}
