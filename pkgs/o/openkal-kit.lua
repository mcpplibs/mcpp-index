-- openkal-kit --- facilities composed from openkal's interfaces.
--
-- Form A because the package is described by its own mcpp.toml.
--
-- ⭐ PUBLISHED OUT OF THE SPECIFICATION'S OWN TARBALL, at `*/kit/mcpp.toml`.
-- The precedent is grpc-plugin and grpcgen, which are published the same way
-- out of grpc-m's archive, and it is why the version key here need not equal
-- the tag: openkal-kit 0.1.0 comes from openkal's 0.8.0 archive.
--
-- The package's own manifest reaches the specification by `path = ".."` and its
-- headers by `include_dirs = ["../include"]`. Both escape the package's
-- directory and hold because the whole archive is extracted and the manifest is
-- then located within it --- which is what the glob below expresses.
--
-- WHY IT IS A SEPARATE PACKAGE AND NOT PART OF THE SPECIFICATION.
--
-- openkal admits an interface only when it is a minimal capability every kernel
-- has and cannot be composed from the interfaces already present. That rule is
-- what keeps openkal implementable on a machine with firmware and nothing else,
-- and it leaves a gap: awaiting two streams at once, or parsing an endpoint out
-- of a configuration file, are composed rather than primitive. This package is
-- where such a composition is written once.
--
-- The distinction is structural rather than stated. Clause 10 makes openkal's
-- contract a C application binary interface; this package exports no name
-- beginning with `kal_` and is C++ modules in `namespace kal::kit`, so a
-- program linking it is not read as an implementation that has added names.
-- The consequence that matters is that this package MAY evolve, which clause 8
-- forbids the specification from doing.
--
-- No `deps`. Its one dependency is the specification, named in its own manifest
-- and satisfied from within the same archive.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-kit",
    description = "Facilities composed from openkal's interfaces, and not part of the specification",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/kit-0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/kit-0.1.1/openkal-kit-0.1.1.tar.gz",
                },
                sha256 = "9c0e763179554daa5aa8dd9680351e7710a343462b068a939f475634d43802bb",
            },
        },
        macosx = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/kit-0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/kit-0.1.1/openkal-kit-0.1.1.tar.gz",
                },
                sha256 = "9c0e763179554daa5aa8dd9680351e7710a343462b068a939f475634d43802bb",
            },
        },
        windows = {
            ["0.1.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal/archive/refs/tags/kit-0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal/releases/download/kit-0.1.1/openkal-kit-0.1.1.tar.gz",
                },
                sha256 = "9c0e763179554daa5aa8dd9680351e7710a343462b068a939f475634d43802bb",
            },
        },
    },

    -- The package's own manifest, in the kit's directory inside the wrap.
    mcpp = "*/kit/mcpp.toml",
}
