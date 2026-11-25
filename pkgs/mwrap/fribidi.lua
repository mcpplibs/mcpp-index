-- Immutable upstream-aligned mwrap source release (fribidi-m mwrap-1.0.16).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
--
-- The wrapper is Apache-2.0; the library it links, compat.fribidi, stays
-- LGPL-2.1-or-later and is linked statically: the package deploys FriBidi's
-- COPYING, AUTHORS and README beside programs (runtime.deploy).
--
-- 1.0.16.1 is a wrapper revision: its templates write the dependency selector
-- unquoted (`mcpplibs.mwrap.fribidi = ...`); the quoted form is deprecated
-- since mcpp 2026.11.8.1 and removed in 2027.2.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "fribidi",
    description = "fribidi-m: GNU FriBidi (the Unicode Bidirectional Algorithm) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/fribidi-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/fribidi-m/releases/download/${tag}/fribidi-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.0.16.1"] = {
                url = "https://github.com/mcpplibs/fribidi-m/releases/download/mwrap-1.0.16.1/fribidi-m-1.0.16.1.tar.gz",
                sha256 = "9a8af5aada70bd54c7690b58d1e6436848711e46aaea096647b5d688ece4a6ab",
            },
            ["1.0.16"] = {
                url = "https://github.com/mcpplibs/fribidi-m/releases/download/mwrap-1.0.16/fribidi-m-1.0.16.tar.gz",
                sha256 = "e05d6f3407689e8372a9876c1a0089df38cfbe33a7df9174ef80c134b7b198f4",
            },
        },
        macosx = {
            ["1.0.16.1"] = {
                url = "https://github.com/mcpplibs/fribidi-m/releases/download/mwrap-1.0.16.1/fribidi-m-1.0.16.1.tar.gz",
                sha256 = "9a8af5aada70bd54c7690b58d1e6436848711e46aaea096647b5d688ece4a6ab",
            },
            ["1.0.16"] = {
                url = "https://github.com/mcpplibs/fribidi-m/releases/download/mwrap-1.0.16/fribidi-m-1.0.16.tar.gz",
                sha256 = "e05d6f3407689e8372a9876c1a0089df38cfbe33a7df9174ef80c134b7b198f4",
            },
        },
        windows = {
            ["1.0.16.1"] = {
                url = "https://github.com/mcpplibs/fribidi-m/releases/download/mwrap-1.0.16.1/fribidi-m-1.0.16.1.tar.gz",
                sha256 = "9a8af5aada70bd54c7690b58d1e6436848711e46aaea096647b5d688ece4a6ab",
            },
            ["1.0.16"] = {
                url = "https://github.com/mcpplibs/fribidi-m/releases/download/mwrap-1.0.16/fribidi-m-1.0.16.tar.gz",
                sha256 = "e05d6f3407689e8372a9876c1a0089df38cfbe33a7df9174ef80c134b7b198f4",
            },
        },
    },
}
