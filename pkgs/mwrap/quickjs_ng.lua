-- Immutable upstream-aligned mwrap source release (quickjs-ng-m mwrap-0.17.0).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "quickjs_ng",
    description = "quickjs-ng-m: QuickJS-ng (the small embeddable JavaScript engine) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/quickjs-ng-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/quickjs-ng-m/releases/download/${tag}/quickjs-ng-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["0.17.0"] = {
                url = "https://github.com/mcpplibs/quickjs-ng-m/releases/download/mwrap-0.17.0/quickjs-ng-m-0.17.0.tar.gz",
                sha256 = "33d95449080f2634611101b24afbb7d996c462fb3939698b76d10c0f7c87aca9",
            },
        },
        macosx = {
            ["0.17.0"] = {
                url = "https://github.com/mcpplibs/quickjs-ng-m/releases/download/mwrap-0.17.0/quickjs-ng-m-0.17.0.tar.gz",
                sha256 = "33d95449080f2634611101b24afbb7d996c462fb3939698b76d10c0f7c87aca9",
            },
        },
        windows = {
            ["0.17.0"] = {
                url = "https://github.com/mcpplibs/quickjs-ng-m/releases/download/mwrap-0.17.0/quickjs-ng-m-0.17.0.tar.gz",
                sha256 = "33d95449080f2634611101b24afbb7d996c462fb3939698b76d10c0f7c87aca9",
            },
        },
    },
}
