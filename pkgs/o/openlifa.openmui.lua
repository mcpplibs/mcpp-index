-- openlifa.openmui --- the openmui specification, an OpenLifa standard: its
-- registry, the C ABI (include/openmui.h, on the include path of a consumer),
-- and the C++ module that declares its value types.
--
-- A user interface as one semantic tree, of which pixels, accessibility,
-- agents and tests are renderings. The module is `openmui.spec`, named for the
-- specification rather than the organization that publishes it.
--
-- No `deps`. Standard library only (C99 for the header).
package = {
    spec        = "1",
    namespace   = "openlifa",
    name        = "openmui",
    description = "openmui: a user interface as one semantic tree --- an OpenLifa specification, its C ABI and its C++ module",
    licenses    = {"Apache-2.0", "CC-BY-SA-4.0"},
    repo        = "https://github.com/openlifa/openmui",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/openlifa/openmui/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.3.0"] = {
                url    = "https://github.com/openlifa/openmui/archive/refs/tags/0.3.0.tar.gz",
                sha256 = "6986ca5d04e170fc8f8be279c30ffffd248b0e62df2f52e64d570f351d122588",
            },
        },
        macosx = {
            ["0.3.0"] = {
                url    = "https://github.com/openlifa/openmui/archive/refs/tags/0.3.0.tar.gz",
                sha256 = "6986ca5d04e170fc8f8be279c30ffffd248b0e62df2f52e64d570f351d122588",
            },
        },
        windows = {
            ["0.3.0"] = {
                url    = "https://github.com/openlifa/openmui/archive/refs/tags/0.3.0.tar.gz",
                sha256 = "6986ca5d04e170fc8f8be279c30ffffd248b0e62df2f52e64d570f351d122588",
            },
        },
    },
}
