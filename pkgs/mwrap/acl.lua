-- Immutable upstream-aligned mwrap source release (acl-m mwrap-2.1.0, the first release of upstream
-- 2.1.0); GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the header-only libraries it vendors, the
-- Animation Compression Library 2.1.0 and the Realtime Math 2.2.0 it pins,
-- are MIT: the package deploys their READMEs and LICENSEs beside programs
-- (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "acl",
    description = "acl-m: the Animation Compression Library 2.1.0 and Realtime Math 2.2.0 (skeletal clips compressed within a stated error, played back at any time) as a C++23 module",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/acl-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/acl-m/releases/download/${tag}/acl-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["2.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/acl-m/releases/download/mwrap-2.1.0/acl-m-2.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-acl/releases/download/2.1.0/acl-m-2.1.0.tar.gz",
                },
                sha256 = "b974ddb90229593ce20dc8ef86f529720bc7983e09700db8cd67a326069a11a4",
            },
        },
        macosx = {
            ["2.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/acl-m/releases/download/mwrap-2.1.0/acl-m-2.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-acl/releases/download/2.1.0/acl-m-2.1.0.tar.gz",
                },
                sha256 = "b974ddb90229593ce20dc8ef86f529720bc7983e09700db8cd67a326069a11a4",
            },
        },
        windows = {
            ["2.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/acl-m/releases/download/mwrap-2.1.0/acl-m-2.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-acl/releases/download/2.1.0/acl-m-2.1.0.tar.gz",
                },
                sha256 = "b974ddb90229593ce20dc8ef86f529720bc7983e09700db8cd67a326069a11a4",
            },
        },
    },
}
