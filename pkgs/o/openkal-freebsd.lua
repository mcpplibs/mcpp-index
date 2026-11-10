-- openkal-freebsd --- openkal for FreeBSD, on the kernel's system-call interface.
--
-- No descriptor-level `deps`: the source manifest names the openkal contract.
-- Two arrangements share the package. Hosted, a program keeps FreeBSD's own C
-- library beside it (mcpp's route A over a FreeBSD base package); standalone
-- (the feature `standalone`), it is the kernel layer beneath openkal-musl
-- (route B, the rows x86_64-freebsd-musl and aarch64-freebsd-musl), which
-- selects it in its own manifest. It needs mcpp 2026.11.10.1, the first release
-- whose built-in rows name FreeBSD.
--
-- The package is listed for every platform because a descriptor's platform
-- table describes availability rather than applicability: it is built on any
-- host for a FreeBSD target.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-freebsd",
    description = "An implementation of openkal for FreeBSD, written on the kernel's system-call interface, hosted beside the system's C library or standalone beneath openkal-musl",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-freebsd",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-freebsd/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-freebsd/releases/download/0.1.0/openkal-freebsd-0.1.0.tar.gz",
                },
                sha256 = "c9d4a73f7f76f09f2f0f5dfc484f3a0db10eb57971aae30d47677e657b8b30ac",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-freebsd/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-freebsd/releases/download/0.1.0/openkal-freebsd-0.1.0.tar.gz",
                },
                sha256 = "c9d4a73f7f76f09f2f0f5dfc484f3a0db10eb57971aae30d47677e657b8b30ac",
            },
        },
        windows = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-freebsd/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-freebsd/releases/download/0.1.0/openkal-freebsd-0.1.0.tar.gz",
                },
                sha256 = "c9d4a73f7f76f09f2f0f5dfc484f3a0db10eb57971aae30d47677e657b8b30ac",
            },
        },
    },
}
