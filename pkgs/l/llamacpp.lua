-- Form A descriptor: llama.cpp-m ships its own mcpp.toml and a vendored,
-- pinned llama.cpp checkpoint. The default lookup finds that manifest inside
-- the GitHub tag archive. CPU is the default backend; Metal is an additive
-- package feature for macOS ARM64 consumers.
package = {
    spec        = "1",
    name        = "llamacpp",
    namespace   = "mcpplibs",
    description = "C++23 module package for llama.cpp (import llamacpp)",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/llama.cpp-m",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url    = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/v0.1.0.tar.gz",
                sha256 = "9af34d44349e520f2f9bd2eace29eb6a634ab4633a7f3bafa225f77be178ca84",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/v0.1.0.tar.gz",
                sha256 = "9af34d44349e520f2f9bd2eace29eb6a634ab4633a7f3bafa225f77be178ca84",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/v0.1.0.tar.gz",
                sha256 = "9af34d44349e520f2f9bd2eace29eb6a634ab4633a7f3bafa225f77be178ca84",
            },
        },
    },

    -- No `mcpp` field: default lookup finds <verdir>/*/mcpp.toml.
}
