-- Form A descriptor: the source repo has its own mcpp.toml. We omit the
-- `mcpp` field entirely — mcpp will default-look-up <verdir>/mcpp.toml
-- and <verdir>/*/mcpp.toml, which catches the GitHub tarball's
-- `<repo>-<tag>/mcpp.toml` layout. Add `mcpp = "<glob>"` only if the
-- default lookup is ambiguous or wrong for your tarball.
package = {
    spec        = "1",
    namespace = "mcpplibs",
    name        = "templates",
    description = "Minimal C++23 modular hello library",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpp-community/templates",
    type        = "package",

    xpm = {
        linux = {
            ["0.0.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpp-community/templates/archive/refs/tags/v0.0.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/templates/releases/download/0.0.1/templates-0.0.1.tar.gz",
                },
                sha256 = "348640a5b8fb09c6392e5487234f426f0d1dd6b1ed46e6644cdec3c9d65e7fd3",
            },
        },
        macosx = {
            ["0.0.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpp-community/templates/archive/refs/tags/v0.0.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/templates/releases/download/0.0.1/templates-0.0.1.tar.gz",
                },
                sha256 = "348640a5b8fb09c6392e5487234f426f0d1dd6b1ed46e6644cdec3c9d65e7fd3",
            },
        },
        windows = {
            ["0.0.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpp-community/templates/archive/refs/tags/v0.0.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/templates/releases/download/0.0.1/templates-0.0.1.tar.gz",
                },
                sha256 = "348640a5b8fb09c6392e5487234f426f0d1dd6b1ed46e6644cdec3c9d65e7fd3",
            },
        },
    },

    -- (no `mcpp` field — default lookup will find <verdir>/*/mcpp.toml)
}
