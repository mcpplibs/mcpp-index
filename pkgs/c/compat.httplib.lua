local versions = {
    ["0.62.0"] = {
        url = "https://github.com/yhirose/cpp-httplib/archive/refs/tags/v0.62.0.tar.gz",
        sha256 = "7bba5949c56e772236432f69da03197fd4c12dc443455b9d81f6a05575431fc8",
    },
    ["0.63.0"] = {
        url = "https://github.com/yhirose/cpp-httplib/archive/refs/tags/v0.63.0.tar.gz",
        sha256 = "44ab42e16926e95f7641d286bc90d739ab1c16886114d7cc5bc7a9f905c5edf8",
    },
    ["0.64.0"] = {
        url = "https://github.com/yhirose/cpp-httplib/archive/refs/tags/v0.64.0.tar.gz",
        sha256 = "1ada413782af5e67e80452c39b7c90beb6fa4fc8341e18c0896bf95684b9a620",
    },
}

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

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/yhirose/cpp-httplib/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        -- No mcpp-res credentials are available in this environment. Keep the
        -- GLOBAL URL as a plain string until a byte-identical CN asset exists.
        linux = {
            ["0.53.1"] = {
                url    = "https://github.com/yhirose/cpp-httplib/archive/refs/tags/v0.53.1.tar.gz",
                sha256 = "185af9587e270de9a3bfee234c6740f02e82265da33c7a41f97e02ee42f979d2",
            },
            ["0.62.0"] = versions["0.62.0"],
            ["0.63.0"] = versions["0.63.0"],
            ["0.64.0"] = versions["0.64.0"],
        },
        macosx = {
            ["0.53.1"] = {
                url    = "https://github.com/yhirose/cpp-httplib/archive/refs/tags/v0.53.1.tar.gz",
                sha256 = "185af9587e270de9a3bfee234c6740f02e82265da33c7a41f97e02ee42f979d2",
            },
            ["0.62.0"] = versions["0.62.0"],
            ["0.63.0"] = versions["0.63.0"],
            ["0.64.0"] = versions["0.64.0"],
        },
        windows = {
            ["0.53.1"] = {
                url    = "https://github.com/yhirose/cpp-httplib/archive/refs/tags/v0.53.1.tar.gz",
                sha256 = "185af9587e270de9a3bfee234c6740f02e82265da33c7a41f97e02ee42f979d2",
            },
            ["0.62.0"] = versions["0.62.0"],
            ["0.63.0"] = versions["0.63.0"],
            ["0.64.0"] = versions["0.64.0"],
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
