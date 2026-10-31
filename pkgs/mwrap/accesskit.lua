-- Immutable upstream-aligned mwrap source release (accesskit-m mwrap-0.23.1).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "accesskit",
    description = "accesskit-m: AccessKit's C bindings as a C++23 module (one accessibility tree served to UIA, NSAccessibility and AT-SPI)",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/accesskit-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/accesskit-m/releases/download/${tag}/accesskit-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["0.23.1"] = {
                url = "https://github.com/mcpplibs/accesskit-m/releases/download/mwrap-0.23.1/accesskit-m-0.23.1.tar.gz",
                sha256 = "799928a7914f3eef7808f358f6bd14c8b18b141e0cd4f34eff99ea8b282fe893",
            },
        },
        macosx = {
            ["0.23.1"] = {
                url = "https://github.com/mcpplibs/accesskit-m/releases/download/mwrap-0.23.1/accesskit-m-0.23.1.tar.gz",
                sha256 = "799928a7914f3eef7808f358f6bd14c8b18b141e0cd4f34eff99ea8b282fe893",
            },
        },
        windows = {
            ["0.23.1"] = {
                url = "https://github.com/mcpplibs/accesskit-m/releases/download/mwrap-0.23.1/accesskit-m-0.23.1.tar.gz",
                sha256 = "799928a7914f3eef7808f358f6bd14c8b18b141e0cd4f34eff99ea8b282fe893",
            },
        },
    },
}
