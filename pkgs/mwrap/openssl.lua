-- Immutable upstream-aligned mwrap source release (openssl-m mwrap-3.5.9);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it links, compat.openssl 3.5.9 (the
-- 3.5 LTS, built at install time by OpenSSL's own Configure for the host; the
-- OpenSSL mcpplibs.mwrap.grpc 1.83.0.1 links, so a program using both links
-- one OpenSSL), is Apache-2.0 too, linked statically: the package deploys
-- OpenSSL's README and LICENSE beside programs (runtime.deploy). The module
-- surface is recorded in the archive's src/surface.tsv and rendered by its
-- build.mcpp as the package is built. The wrapper's CI covers Linux x86_64
-- (GCC, LLVM), Linux aarch64 (LLVM: mcpp's GCC there is a musl toolchain),
-- macOS and Windows; there is no cross target.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "openssl",
    description = "openssl-m: OpenSSL 3.5 LTS (libcrypto and libssl) as C++23 modules: every declaration of the headers, the inline functions declared again, the constants and call macros under their names",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/openssl-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/openssl-m/releases/download/${tag}/openssl-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["3.5.9"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openssl-m/releases/download/mwrap-3.5.9/openssl-m-3.5.9.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-openssl/releases/download/3.5.9/openssl-m-3.5.9.tar.gz",
                },
                sha256 = "df3d0458c18538b9dc680221e2e78e9b5eacc632d37c33efbc744ac64def5e8f",
            },
        },
        macosx = {
            ["3.5.9"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openssl-m/releases/download/mwrap-3.5.9/openssl-m-3.5.9.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-openssl/releases/download/3.5.9/openssl-m-3.5.9.tar.gz",
                },
                sha256 = "df3d0458c18538b9dc680221e2e78e9b5eacc632d37c33efbc744ac64def5e8f",
            },
        },
        windows = {
            ["3.5.9"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openssl-m/releases/download/mwrap-3.5.9/openssl-m-3.5.9.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-openssl/releases/download/3.5.9/openssl-m-3.5.9.tar.gz",
                },
                sha256 = "df3d0458c18538b9dc680221e2e78e9b5eacc632d37c33efbc744ac64def5e8f",
            },
        },
    },
}
