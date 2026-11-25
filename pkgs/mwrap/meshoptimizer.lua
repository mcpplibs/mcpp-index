-- Immutable upstream-aligned mwrap source release (meshoptimizer-m mwrap-1.3, mwrap-1.3.1);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it vendors and links statically,
-- meshoptimizer 1.3, is MIT: the package deploys its README and LICENSE beside
-- programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "meshoptimizer",
    description = "meshoptimizer-m: meshoptimizer 1.3 (indexing, vertex cache and overdraw ordering, simplification, meshlets, vertex and index codecs) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/meshoptimizer-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/meshoptimizer-m/releases/download/${tag}/meshoptimizer-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/meshoptimizer-m/releases/download/mwrap-1.3/meshoptimizer-m-1.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-meshoptimizer/releases/download/1.3/meshoptimizer-m-1.3.tar.gz",
                },
                sha256 = "5172030f7b27b757cff2945d661e12969a191b08ed8b8ce19e70220fd3654e7e",
            },
            ["1.3.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/meshoptimizer-m/releases/download/mwrap-1.3.1/meshoptimizer-m-1.3.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-meshoptimizer/releases/download/1.3.1/meshoptimizer-m-1.3.1.tar.gz",
                },
                sha256 = "663638294c4e54cb37fce138019c5d597e07ee8df25ab11dfa75ff2d772a37d4",
            },
        },
        macosx = {
            ["1.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/meshoptimizer-m/releases/download/mwrap-1.3/meshoptimizer-m-1.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-meshoptimizer/releases/download/1.3/meshoptimizer-m-1.3.tar.gz",
                },
                sha256 = "5172030f7b27b757cff2945d661e12969a191b08ed8b8ce19e70220fd3654e7e",
            },
            ["1.3.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/meshoptimizer-m/releases/download/mwrap-1.3.1/meshoptimizer-m-1.3.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-meshoptimizer/releases/download/1.3.1/meshoptimizer-m-1.3.1.tar.gz",
                },
                sha256 = "663638294c4e54cb37fce138019c5d597e07ee8df25ab11dfa75ff2d772a37d4",
            },
        },
        windows = {
            ["1.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/meshoptimizer-m/releases/download/mwrap-1.3/meshoptimizer-m-1.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-meshoptimizer/releases/download/1.3/meshoptimizer-m-1.3.tar.gz",
                },
                sha256 = "5172030f7b27b757cff2945d661e12969a191b08ed8b8ce19e70220fd3654e7e",
            },
            ["1.3.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/meshoptimizer-m/releases/download/mwrap-1.3.1/meshoptimizer-m-1.3.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-meshoptimizer/releases/download/1.3.1/meshoptimizer-m-1.3.1.tar.gz",
                },
                sha256 = "663638294c4e54cb37fce138019c5d597e07ee8df25ab11dfa75ff2d772a37d4",
            },
        },
    },
}
