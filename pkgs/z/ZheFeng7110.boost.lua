-- Form A descriptor: boost-module ships its own mcpp.toml at the archive root,
-- and that manifest IS the build. The `mcpp` field therefore points at it
-- rather than inlining a Form B descriptor, because the package needs things an
-- inline descriptor cannot express: a build.mcpp umbrella generator, the
-- vendored Boost source tree (deps/boost/), and the committed generator output
-- under src/gen_exports/.
--
-- Version naming is upstream's wrapper scheme `v<boost version>.<wrapper
-- version>`. Upstream tags are bare semver, so the xpm key carries that string verbatim.
--
-- No mcpp-res mirror is configured yet (no CN access): the plain-string GLOBAL
-- url is the documented fallback for CN consumers until a maintainer creates
-- the mirror.
package = {
    spec        = "1",
    namespace   = "ZheFeng7110",
    name        = "boost",
    description = "Boost as C++23 named modules — import boost.<lib>; or the umbrella import boost;",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/ZheFeng7110/boost-module",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0.0.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/ZheFeng7110/boost-module/releases/download/v1.92.0.0.0.0/boost-module-v1.92.0.0.0.0.tar.xz",
                    CN     = "https://gitcode.com/ZheFeng7/boost-module/releases/download/v1.92.0.0.0.0/boost-module-v1.92.0.0.0.0.tar.xz",
                },
                sha256 = "c500ee0914d6727e225fe119187839e5d6fb531ecf896e4a669624a6ff8285ab",
            },
            ["1.91.0.0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/ZheFeng7110/boost-module/releases/download/v1.91.0.0.1.0/boost-module-v1.91.0.0.1.0.tar.xz",
                    CN     = "https://gitcode.com/ZheFeng7/boost-module/releases/download/v1.91.0.0.1.0/boost-module-v1.91.0.0.1.0.tar.xz",
                },
                sha256 = "63a9aae63140f22e518a4ee758332afd5b5037d916731dc9c8339dea1a1e1010",
            },
        },
        macosx = {
            ["1.92.0.0.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/ZheFeng7110/boost-module/releases/download/v1.92.0.0.0.0/boost-module-v1.92.0.0.0.0.tar.xz",
                    CN     = "https://gitcode.com/ZheFeng7/boost-module/releases/download/v1.92.0.0.0.0/boost-module-v1.92.0.0.0.0.tar.xz",
                },
                sha256 = "c500ee0914d6727e225fe119187839e5d6fb531ecf896e4a669624a6ff8285ab",
            },
            ["1.91.0.0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/ZheFeng7110/boost-module/releases/download/v1.91.0.0.1.0/boost-module-v1.91.0.0.1.0.tar.xz",
                    CN     = "https://gitcode.com/ZheFeng7/boost-module/releases/download/v1.91.0.0.1.0/boost-module-v1.91.0.0.1.0.tar.xz",
                },
                sha256 = "63a9aae63140f22e518a4ee758332afd5b5037d916731dc9c8339dea1a1e1010",
            },
        },
        windows = {
            ["1.92.0.0.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/ZheFeng7110/boost-module/releases/download/v1.92.0.0.0.0/boost-module-v1.92.0.0.0.0.tar.xz",
                    CN     = "https://gitcode.com/ZheFeng7/boost-module/releases/download/v1.92.0.0.0.0/boost-module-v1.92.0.0.0.0.tar.xz",
                },
                sha256 = "c500ee0914d6727e225fe119187839e5d6fb531ecf896e4a669624a6ff8285ab",
            },
            ["1.91.0.0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/ZheFeng7110/boost-module/releases/download/v1.91.0.0.1.0/boost-module-v1.91.0.0.1.0.tar.xz",
                    CN     = "https://gitcode.com/ZheFeng7/boost-module/releases/download/v1.91.0.0.1.0/boost-module-v1.91.0.0.1.0.tar.xz",
                },
                sha256 = "63a9aae63140f22e518a4ee758332afd5b5037d916731dc9c8339dea1a1e1010",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
