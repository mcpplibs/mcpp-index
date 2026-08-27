-- openkal-macos --- a second implementation.
--
-- Its purpose is as much to test the specification as to be used. A
-- specification satisfied only by the system it was written against has not
-- been shown to be portable, however many programs that system hosts.
--
-- Listed for every platform because a platform table describes availability
-- rather than applicability. A project selects this implementation with a
-- conditional dependency on cfg(os = "macos"); one that selects it elsewhere
-- fails at compile time, which is the correct place for that failure.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-macos",
    description = "An implementation of openkal for macOS, which exists as much to test the specification as to be used",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-macos",
    type        = "package",

    xpm = {
        linux = {
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.4.0/openkal-macos-0.4.0.tar.gz",
                },
                sha256 = "0596e8dbbb7060f19954902c6bbff7ddd4d3f5eeb84399edc9e8b7e3964290a4",
            },
            ["0.3.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.3.4/openkal-macos-0.3.4.tar.gz",
                },
                sha256 = "cb914fafa7e8776ea9442ad04f1aeb231331daa052d9d09d6f802ae4641477ae",
            },
            ["0.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.3.3/openkal-macos-0.3.3.tar.gz",
                },
                sha256 = "5bd55b348e56329922fbbf49f77d097a1e7f0b4585b90d4428f3e419d13e9ff7",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.3.2/openkal-macos-0.3.2.tar.gz",
                },
                sha256 = "b4e9de5e28ca44e827306ec31fb1580f1b9bc2d6af71d6dc8fafa10db1cfb2eb",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.3.1/openkal-macos-0.3.1.tar.gz",
                },
                sha256 = "c9347af16af21969938cffd112abd9a2f930eab28500d15ab8cc17b236f4b766",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.2.0/openkal-macos-0.2.0.tar.gz",
                },
                sha256 = "459f9b11b4af0e06f8d49848389263ef6bfc542cc97491e130d3e13c53e99ab6",
            },
        },
        macosx = {
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.4.0/openkal-macos-0.4.0.tar.gz",
                },
                sha256 = "0596e8dbbb7060f19954902c6bbff7ddd4d3f5eeb84399edc9e8b7e3964290a4",
            },
            ["0.3.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.3.4/openkal-macos-0.3.4.tar.gz",
                },
                sha256 = "cb914fafa7e8776ea9442ad04f1aeb231331daa052d9d09d6f802ae4641477ae",
            },
            ["0.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.3.3/openkal-macos-0.3.3.tar.gz",
                },
                sha256 = "5bd55b348e56329922fbbf49f77d097a1e7f0b4585b90d4428f3e419d13e9ff7",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.3.2/openkal-macos-0.3.2.tar.gz",
                },
                sha256 = "b4e9de5e28ca44e827306ec31fb1580f1b9bc2d6af71d6dc8fafa10db1cfb2eb",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.3.1/openkal-macos-0.3.1.tar.gz",
                },
                sha256 = "c9347af16af21969938cffd112abd9a2f930eab28500d15ab8cc17b236f4b766",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.2.0/openkal-macos-0.2.0.tar.gz",
                },
                sha256 = "459f9b11b4af0e06f8d49848389263ef6bfc542cc97491e130d3e13c53e99ab6",
            },
        },
        windows = {
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.4.0/openkal-macos-0.4.0.tar.gz",
                },
                sha256 = "0596e8dbbb7060f19954902c6bbff7ddd4d3f5eeb84399edc9e8b7e3964290a4",
            },
            ["0.3.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.3.4/openkal-macos-0.3.4.tar.gz",
                },
                sha256 = "cb914fafa7e8776ea9442ad04f1aeb231331daa052d9d09d6f802ae4641477ae",
            },
            ["0.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.3.3/openkal-macos-0.3.3.tar.gz",
                },
                sha256 = "5bd55b348e56329922fbbf49f77d097a1e7f0b4585b90d4428f3e419d13e9ff7",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.3.2/openkal-macos-0.3.2.tar.gz",
                },
                sha256 = "b4e9de5e28ca44e827306ec31fb1580f1b9bc2d6af71d6dc8fafa10db1cfb2eb",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.3.1/openkal-macos-0.3.1.tar.gz",
                },
                sha256 = "c9347af16af21969938cffd112abd9a2f930eab28500d15ab8cc17b236f4b766",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-macos/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-macos/releases/download/0.2.0/openkal-macos-0.2.0.tar.gz",
                },
                sha256 = "459f9b11b4af0e06f8d49848389263ef6bfc542cc97491e130d3e13c53e99ab6",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
