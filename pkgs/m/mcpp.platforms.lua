-- mcpp:platforms -- rows for systems the engine does not carry: each system's
-- triples, the base each row links against (a sysroot package of xim) and,
-- where an image of the system exists, the runner that boots it (mcpp SPEC-013,
-- SPEC-016). A project selects the package for the rows it builds:
--
--   [target.'cfg(any(os = "freebsd", os = "netbsd", os = "openbsd"))']
--   platform = "mcpp.platforms@0.1.0"
--   runner   = true          # consent to the row's runner (fetches an image)
--
-- 0.1.0 (package floor mcpp 2026.11.17.1): FreeBSD 14.5, NetBSD 10.2 and
-- OpenBSD 8.0, x86_64 and aarch64. NetBSD's C++ layer is libc++ from source
-- (llvm.libcxx), so `import std` holds over the release's GCC 10 libstdc++
-- base. Runners: FreeBSD (both), NetBSD and OpenBSD (x86_64). The rows build on
-- Linux hosts (mcpp-community/mcpp-platforms#1).
package = {
    spec        = "1",
    namespace   = "mcpp",
    name        = "platforms",
    description = "Rows for systems the engine does not carry (FreeBSD, NetBSD, OpenBSD): their definitions, bases and runners, as one versioned statement mcpp reads",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpp-community/mcpp-platforms",
    type        = "package",

    -- The rows this platform serves, for mcpp's platform column (SPEC-013 §14): derived
    -- from the newest version's manifest by tools/platform_rows.py, never written by hand.
    platform_rows = { "aarch64-freebsd", "aarch64-netbsd", "aarch64-openbsd", "x86_64-freebsd", "x86_64-netbsd", "x86_64-openbsd" },
    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/mcpp-community/mcpp-platforms/archive/refs/tags/${tag}.tar.gz",
        },
    },

    -- The descriptor points at the source archive of the tag; the CN asset is the
    -- same bytes, so one sha256 names both.
    xpm = {
        linux = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-platforms/archive/refs/tags/0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-platforms/releases/download/0.1.0/mcpp-platforms-0.1.0.tar.gz",
                },
                sha256 = "bd09836f9952af28ede3f9c4568aafd999ace803f2cad21fed0aa4ca495893f3",
            },
            ["latest"] = { ref = "0.1.0" },
        },
    },

    -- The package's own manifest, at the archive root.
    mcpp = "*/mcpp.toml",
}
