-- Form B header-only descriptor for cpp-httplib. Optional backends stay off
-- unless a consumer requests the corresponding mcpp feature.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "httplib",
    description = "C++ single-header HTTP/HTTPS server and client library",
    licenses    = {"MIT"},
    repo        = "https://github.com/yhirose/cpp-httplib",
    type        = "package",

    xpm = {
        -- No mcpp-res credentials are available in this environment. Keep the
        -- GLOBAL URL as a plain string until a byte-identical CN asset exists.
        linux = {
            ["0.53.1"] = {
                url    = "https://github.com/yhirose/cpp-httplib/archive/refs/tags/v0.53.1.tar.gz",
                sha256 = "185af9587e270de9a3bfee234c6740f02e82265da33c7a41f97e02ee42f979d2",
            },
        },
        macosx = {
            ["0.53.1"] = {
                url    = "https://github.com/yhirose/cpp-httplib/archive/refs/tags/v0.53.1.tar.gz",
                sha256 = "185af9587e270de9a3bfee234c6740f02e82265da33c7a41f97e02ee42f979d2",
            },
        },
        windows = {
            ["0.53.1"] = {
                url    = "https://github.com/yhirose/cpp-httplib/archive/refs/tags/v0.53.1.tar.gz",
                sha256 = "185af9587e270de9a3bfee234c6740f02e82265da33c7a41f97e02ee42f979d2",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        include_dirs = { "*" },
        generated_files = {
            ["mcpp_generated/compat_httplib_anchor.cpp"] =
                "int mcpp_compat_httplib_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/compat_httplib_anchor.cpp" },
        targets = { ["httplib"] = { kind = "lib" } },

        -- Feature defines are interface requirements for this header-only
        -- package: cpp-httplib's implementation is compiled in consumer TUs.
        features = {
            ["tls"] = {
                defines = { "CPPHTTPLIB_OPENSSL_SUPPORT" },
                deps    = { ["compat.openssl"] = "3.5.1" },
            },
            ["zlib"] = {
                defines = { "CPPHTTPLIB_ZLIB_SUPPORT" },
                deps    = { ["compat.zlib"] = "1.3.2" },
            },
            ["brotli"] = {
                defines = { "CPPHTTPLIB_BROTLI_SUPPORT" },
                deps    = { ["compat.brotli"] = "1.2.0" },
            },
            ["zstd"] = {
                defines = { "CPPHTTPLIB_ZSTD_SUPPORT" },
                deps    = { ["compat.zstd"] = "1.5.7" },
            },
            ["no-exceptions"] = {
                defines = { "CPPHTTPLIB_NO_EXCEPTIONS" },
            },
        },
        deps = {},

        -- Feature entries cannot carry platform-local ldflags. These are the
        -- upstream target's system link requirements; unused system libraries
        -- and frameworks are harmless for feature-free consumers.
        linux = {
            ldflags = { "-lpthread" },
        },
        macosx = {
            ldflags = {
                "-lpthread",
                "-framework", "CFNetwork",
                "-framework", "CoreFoundation",
                "-framework", "Security",
            },
        },
        windows = {
            ldflags = { "-lws2_32", "-lcrypt32" },
        },
    },
}
