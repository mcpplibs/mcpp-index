-- Immutable upstream-aligned mwrap source release (sheenbidi-m mwrap-3.0.0);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0, and so is the library it links, compat.sheenbidi
-- (SheenBidi 3.0.0, Unicode 17.0.0), linked statically: the package deploys
-- SheenBidi's README and LICENSE and the Unicode License v3 of the data its
-- tables come from beside programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "sheenbidi",
    description = "sheenbidi-m: SheenBidi (the Unicode Bidirectional Algorithm, Unicode 17.0.0) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/sheenbidi-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/sheenbidi-m/releases/download/${tag}/sheenbidi-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["3.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/sheenbidi-m/releases/download/mwrap-3.0.0/sheenbidi-m-3.0.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-sheenbidi/releases/download/3.0.0/sheenbidi-m-3.0.0.tar.gz",
                },
                sha256 = "76a0b0fe0000ae43483b1b6e606908c09381f2d1cd8c736bff8b685c2fec3c41",
            },
        },
        macosx = {
            ["3.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/sheenbidi-m/releases/download/mwrap-3.0.0/sheenbidi-m-3.0.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-sheenbidi/releases/download/3.0.0/sheenbidi-m-3.0.0.tar.gz",
                },
                sha256 = "76a0b0fe0000ae43483b1b6e606908c09381f2d1cd8c736bff8b685c2fec3c41",
            },
        },
        windows = {
            ["3.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/sheenbidi-m/releases/download/mwrap-3.0.0/sheenbidi-m-3.0.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-sheenbidi/releases/download/3.0.0/sheenbidi-m-3.0.0.tar.gz",
                },
                sha256 = "76a0b0fe0000ae43483b1b6e606908c09381f2d1cd8c736bff8b685c2fec3c41",
            },
        },
    },
}
