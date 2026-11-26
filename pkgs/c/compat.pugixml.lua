local versions = {
    ["1.16"] = {
        url    = "https://github.com/zeux/pugixml/archive/refs/tags/v1.16.tar.gz",
        sha256 = "357bcab8877dc9943f355d3a72daba1b053238ba955f50fa81586afb65090219",
    },
}

-- compat.pugixml — Light-weight, simple and fast XML parser for C++ with XPath support.
-- Static C++ source build: compiles src/pugixml.cpp and exposes src/ (`<pugixml.hpp>`,
-- `<pugiconfig.hpp>`).
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/`
-- absorbs the GitHub tarball's `pugixml-<ver>/` wrap layer.
-- Plain upstream URLs are used here because no local gitcode `mcpp-res`
-- credentials are available; CN mirrors can be added by maintainers later.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "pugixml",
    description = "Light-weight, simple and fast XML parser for C++ with XPath support",
    licenses    = {"MIT"},
    repo        = "https://github.com/zeux/pugixml",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/zeux/pugixml/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux   = { ["1.16"] = versions["1.16"] },
        macosx  = { ["1.16"] = versions["1.16"] },
        windows = { ["1.16"] = versions["1.16"] },
    },

    mcpp = {
        language      = "c++23",
        import_std    = false,
        license_files = { "*/LICENSE.md" },
        include_dirs  = { "*/src" },
        sources       = { "*/src/pugixml.cpp" },
        targets       = { ["pugixml"] = { kind = "lib" } },
        deps          = {},
    },
}
