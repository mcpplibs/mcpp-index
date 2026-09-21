-- Form A descriptor: boost-module ships its own mcpp.toml at the archive root,
-- and that manifest IS the build. The `mcpp` field therefore points at it
-- rather than inlining a Form B descriptor, because the package needs things an
-- inline descriptor cannot express: a build.mcpp umbrella generator, the
-- vendored Boost source tree (deps/boost/), and the committed generator output
-- under src/gen_exports/.
--
-- Version naming is upstream's wrapper scheme `b<boost version>w<wrapper
-- version>` (this release is Boost 1.91.0 x modules wrapper 0.0.0). Upstream
-- tags are not bare semver, so the xpm key carries that string verbatim.
--
-- No mcpp-res mirror is configured yet (no CN access): the plain-string GLOBAL
-- url is the documented fallback for CN consumers until a maintainer creates
-- the mirror.
package = {
    spec        = "1",
    namespace   = "boost",
    name        = "boost",
    description = "Boost 1.91.0 as C++23 named modules — import boost.<lib>; or the umbrella import boost;",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/ZheFeng7110/boost-module",
    type        = "package",

    xpm = {
        linux = {
            ["b1.91.0w0.0.0"] = {
                url    = "https://github.com/ZheFeng7110/boost-module/archive/refs/tags/b1.91.0w0.0.0.tar.gz",
                sha256 = "7b6434d67383a8598f41bfd563eabb2be7ee23578cc7a65094ff6926c3d23df7",
            },
        },
        macosx = {
            ["b1.91.0w0.0.0"] = {
                url    = "https://github.com/ZheFeng7110/boost-module/archive/refs/tags/b1.91.0w0.0.0.tar.gz",
                sha256 = "7b6434d67383a8598f41bfd563eabb2be7ee23578cc7a65094ff6926c3d23df7",
            },
        },
        windows = {
            ["b1.91.0w0.0.0"] = {
                url    = "https://github.com/ZheFeng7110/boost-module/archive/refs/tags/b1.91.0w0.0.0.tar.gz",
                sha256 = "7b6434d67383a8598f41bfd563eabb2be7ee23578cc7a65094ff6926c3d23df7",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
