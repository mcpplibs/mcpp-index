-- openkal-windows --- an implementation for a system that shares no ancestry
-- with the one openkal was first written on.
--
-- No `deps`. The interfaces it uses are the ones every installation of that
-- system already has, and it names them in the objects it produces rather than
-- on a link line, so a project that selects it needs nothing further.
--
-- The package is listed for every platform because a descriptor's platform
-- table describes availability rather than applicability. A project selects
-- this implementation with a conditional dependency on `cfg(windows)`, and a
-- project that selects it elsewhere fails at compile time, which is the correct
-- place for that failure.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-windows",
    description = "An implementation of openkal for Windows, on the Win32 interfaces and the object manager beneath them, using no C runtime symbol",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-windows",
    type        = "package",

    xpm = {
        linux = {
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.7.0/openkal-windows-0.7.0.tar.gz",
                },
                sha256 = "9b18d20263d7541399dc7a6f6b2d3c826aa2a34e47fc19658362a028dee690cf",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.6.0/openkal-windows-0.6.0.tar.gz",
                },
                sha256 = "9427383d37874acd3ca7dd51d349d082192c15f7a120fe3404100e21d62a1376",
            },
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.5.0/openkal-windows-0.5.0.tar.gz",
                },
                sha256 = "6bbb6d3ed5a82d847a4b24b90ff1e2e34277560dbadffff67829312b0f47ddb9",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.4.0/openkal-windows-0.4.0.tar.gz",
                },
                sha256 = "5baa87943163998f9daa7b2ca2dd258bf746bfb6764291c671adead1d45ee798",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.3.0/openkal-windows-0.3.0.tar.gz",
                },
                sha256 = "99b783e7d47fce29afe86ff298a915c3255a139ba211f2c8f17199ced3820400",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.2.0/openkal-windows-0.2.0.tar.gz",
                },
                sha256 = "255e15e1829cd4ccca21cf1cb0e2cc9272b5c695b2fd3482d3a3b009a182e6e4",
            },
            ["0.1.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.5/openkal-windows-0.1.5.tar.gz",
                },
                sha256 = "504a64e2561e51cb6b6b77f17dbe01237f536c079780de687d8914934a9e3ead",
            },
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.4/openkal-windows-0.1.4.tar.gz",
                },
                sha256 = "60921c72da51f84dda2a1e761cd45c9d736f6d24e4075360a216c20109569308",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.3/openkal-windows-0.1.3.tar.gz",
                },
                sha256 = "371ce7e54104ddad749964681dfa6fdf0c584278090d754ac95fcb3625939030",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.2/openkal-windows-0.1.2.tar.gz",
                },
                sha256 = "4e4104301ce2dea208de3fca64679bfe2c239aa63cd85fd816065b4dadb3d8b3",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.1/openkal-windows-0.1.1.tar.gz",
                },
                sha256 = "e4e517c80d030eacd5427e85c4431a425d098a151c263554bf79d277f360d444",
            },
        },
        macosx = {
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.7.0/openkal-windows-0.7.0.tar.gz",
                },
                sha256 = "9b18d20263d7541399dc7a6f6b2d3c826aa2a34e47fc19658362a028dee690cf",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.6.0/openkal-windows-0.6.0.tar.gz",
                },
                sha256 = "9427383d37874acd3ca7dd51d349d082192c15f7a120fe3404100e21d62a1376",
            },
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.5.0/openkal-windows-0.5.0.tar.gz",
                },
                sha256 = "6bbb6d3ed5a82d847a4b24b90ff1e2e34277560dbadffff67829312b0f47ddb9",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.4.0/openkal-windows-0.4.0.tar.gz",
                },
                sha256 = "5baa87943163998f9daa7b2ca2dd258bf746bfb6764291c671adead1d45ee798",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.3.0/openkal-windows-0.3.0.tar.gz",
                },
                sha256 = "99b783e7d47fce29afe86ff298a915c3255a139ba211f2c8f17199ced3820400",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.2.0/openkal-windows-0.2.0.tar.gz",
                },
                sha256 = "255e15e1829cd4ccca21cf1cb0e2cc9272b5c695b2fd3482d3a3b009a182e6e4",
            },
            ["0.1.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.5/openkal-windows-0.1.5.tar.gz",
                },
                sha256 = "504a64e2561e51cb6b6b77f17dbe01237f536c079780de687d8914934a9e3ead",
            },
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.4/openkal-windows-0.1.4.tar.gz",
                },
                sha256 = "60921c72da51f84dda2a1e761cd45c9d736f6d24e4075360a216c20109569308",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.3/openkal-windows-0.1.3.tar.gz",
                },
                sha256 = "371ce7e54104ddad749964681dfa6fdf0c584278090d754ac95fcb3625939030",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.2/openkal-windows-0.1.2.tar.gz",
                },
                sha256 = "4e4104301ce2dea208de3fca64679bfe2c239aa63cd85fd816065b4dadb3d8b3",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.1/openkal-windows-0.1.1.tar.gz",
                },
                sha256 = "e4e517c80d030eacd5427e85c4431a425d098a151c263554bf79d277f360d444",
            },
        },
        windows = {
            ["0.7.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.7.0/openkal-windows-0.7.0.tar.gz",
                },
                sha256 = "9b18d20263d7541399dc7a6f6b2d3c826aa2a34e47fc19658362a028dee690cf",
            },
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.6.0/openkal-windows-0.6.0.tar.gz",
                },
                sha256 = "9427383d37874acd3ca7dd51d349d082192c15f7a120fe3404100e21d62a1376",
            },
            ["0.5.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.5.0/openkal-windows-0.5.0.tar.gz",
                },
                sha256 = "6bbb6d3ed5a82d847a4b24b90ff1e2e34277560dbadffff67829312b0f47ddb9",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.4.0/openkal-windows-0.4.0.tar.gz",
                },
                sha256 = "5baa87943163998f9daa7b2ca2dd258bf746bfb6764291c671adead1d45ee798",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.3.0/openkal-windows-0.3.0.tar.gz",
                },
                sha256 = "99b783e7d47fce29afe86ff298a915c3255a139ba211f2c8f17199ced3820400",
            },
            ["0.2.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.2.0/openkal-windows-0.2.0.tar.gz",
                },
                sha256 = "255e15e1829cd4ccca21cf1cb0e2cc9272b5c695b2fd3482d3a3b009a182e6e4",
            },
            ["0.1.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.5/openkal-windows-0.1.5.tar.gz",
                },
                sha256 = "504a64e2561e51cb6b6b77f17dbe01237f536c079780de687d8914934a9e3ead",
            },
            ["0.1.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.4/openkal-windows-0.1.4.tar.gz",
                },
                sha256 = "60921c72da51f84dda2a1e761cd45c9d736f6d24e4075360a216c20109569308",
            },
            ["0.1.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.3/openkal-windows-0.1.3.tar.gz",
                },
                sha256 = "371ce7e54104ddad749964681dfa6fdf0c584278090d754ac95fcb3625939030",
            },
            ["0.1.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.2/openkal-windows-0.1.2.tar.gz",
                },
                sha256 = "4e4104301ce2dea208de3fca64679bfe2c239aa63cd85fd816065b4dadb3d8b3",
            },
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-windows/archive/refs/tags/0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-windows/releases/download/0.1.1/openkal-windows-0.1.1.tar.gz",
                },
                sha256 = "e4e517c80d030eacd5427e85c4431a425d098a151c263554bf79d277f360d444",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
