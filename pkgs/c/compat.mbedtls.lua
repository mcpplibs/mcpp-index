-- M6.x glob-aware Form B descriptor for mbedtls.
--
-- Pure-C library; relies on mcpp 0.0.2's C-language compile rule (`.c`
-- routed to `c_object` via the gcc/clang sibling driver). Produces a
-- single static archive `libmbedtls.a` that bundles all of mbedtls's
-- crypto + x509 + ssl translation units — the same arrangement xmake's
-- mbedtls package emits when used by `add_packages("mbedtls")`.

package = {
    spec        = "1",
    namespace = "compat",
    name        = "mbedtls",
    description = "An open source, portable, easy to use, readable and flexible TLS library, and reference implementation of the PSA Cryptography API",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/Mbed-TLS/mbedtls",
    type        = "package",

    xpm = {
        linux = {
            ["3.6.1"] = {
                url    = {
                    GLOBAL = "https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/mbedtls-3.6.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mbedtls/releases/download/3.6.1/mbedtls-3.6.1.tar.gz",
                },
                sha256 = "db75d2f7f35e29cf09f7bd6734d8ee3325f29c298ef071350c5e70a40dd4f0f9",
            },
        },
        macosx = {
            ["3.6.1"] = {
                url    = {
                    GLOBAL = "https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/mbedtls-3.6.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mbedtls/releases/download/3.6.1/mbedtls-3.6.1.tar.gz",
                },
                sha256 = "db75d2f7f35e29cf09f7bd6734d8ee3325f29c298ef071350c5e70a40dd4f0f9",
            },
        },
        windows = {
            ["3.6.1"] = {
                url    = {
                    GLOBAL = "https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/mbedtls-3.6.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mbedtls/releases/download/3.6.1/mbedtls-3.6.1.tar.gz",
                },
                sha256 = "db75d2f7f35e29cf09f7bd6734d8ee3325f29c298ef071350c5e70a40dd4f0f9",
            },
        },
    },

    -- Form B `mcpp` segment: paths are globs relative to the verdir
    -- (~/.mcpp/registry/data/xpkgs/<idx>-x-mbedtls/<ver>/). The leading
    -- `*/` absorbs the GitHub tarball's `mbedtls-mbedtls-3.6.1/` wrap.
    mcpp = {
        language     = "c++23",                   -- the [package].standard knob; mcpp uses it for the C++23 toolchain.
        import_std   = false,                     -- pure C lib — no std module.
        sources      = { "*/library/*.c" },       -- 108 sources, all of crypto + x509 + ssl.
        include_dirs = { "*/include", "*/library" },
        c_standard   = "c11",
        targets      = { ["mbedtls"] = { kind = "lib" } },
        deps         = { },
        -- Windows with musl as the C library (an openkal graph) used to carry a
        -- `target_cfg` here (`-U_WIN32 -D__unix__`): mbedtls selects its
        -- entropy, timing and socket code by asking whether the environment is
        -- Windows (_WIN32) or Unix (__unix__), the triple answered Windows, and
        -- the C library these units actually compile against is POSIX-shaped
        -- (openkal-musl: getrandom, clock_gettime, BSD sockets), so the flags
        -- corrected what the triple implied for mbedtls's own translation
        -- units. openkal-musl now declares `[c-abi] presents = "posix"`
        -- (design:
        -- openkal/.agents/docs/2026-09-18-openkal-c-environment-and-personalities-design.md
        -- §3.2), and mcpp realises that declaration for the whole target
        -- rather than one package at a time, so _WIN32 is simply absent and
        -- __unix__ is simply present there to begin with; the `target_cfg` is
        -- withdrawn rather than reproduced.
        windows = {
            ldflags = { "-lbcrypt" },
        },
    },
}
