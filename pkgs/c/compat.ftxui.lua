-- M6.x glob-aware Form B descriptor for FTXUI 6.1.9.
--
-- Pure C++ library (no C++23 modules); compiled sources + public headers.
-- Uses mcpp 0.0.4's glob exclusion (`!` prefix) to skip the ~46
-- *_test.cpp / *_fuzzer.cpp files that live alongside the library
-- sources in the same directories.
--
-- Produces a single static archive `libftxui.a` covering all three
-- upstream cmake targets (ftxui-screen, ftxui-dom, ftxui-component).

package = {
    spec        = "1",
    namespace = "compat",
    name        = "compat.ftxui",
    description = "C++ Functional Terminal User Interface (screen + dom + component)",
    licenses    = {"MIT"},
    repo        = "https://github.com/ArthurSonzogni/FTXUI",
    type        = "package",

    xpm = {
        linux = {
            ["6.1.9"] = {
                url    = "https://github.com/ArthurSonzogni/FTXUI/archive/refs/tags/v6.1.9.tar.gz",
                sha256 = "45819c1e54914783d4a1ca5633885035d74146778a1f74e1213cdb7b76340e71",
            },
        },
        macosx = {
            ["6.1.9"] = {
                url    = "https://github.com/ArthurSonzogni/FTXUI/archive/refs/tags/v6.1.9.tar.gz",
                sha256 = "45819c1e54914783d4a1ca5633885035d74146778a1f74e1213cdb7b76340e71",
            },
        },
        windows = {
            ["6.1.9"] = {
                url    = "https://github.com/ArthurSonzogni/FTXUI/archive/refs/tags/v6.1.9.tar.gz",
                sha256 = "45819c1e54914783d4a1ca5633885035d74146778a1f74e1213cdb7b76340e71",
            },
        },
    },

    -- Form B `mcpp` segment: paths are globs relative to the verdir.
    -- The leading `*/` absorbs the GitHub tarball's `FTXUI-6.1.9/` wrap.
    mcpp = {
        language     = "c++23",
        import_std   = false,          -- pure compiled lib, no `import std;`
        include_dirs = { "*/include", "*/src" },   -- src/ for private headers (box_helper.hpp etc.),
        sources = {
            "*/src/ftxui/**/*.cpp",
            "!*/src/ftxui/**/*_test.cpp",      -- 30+ gtest files
            "!*/src/ftxui/**/*_fuzzer.cpp",     -- ~16 fuzz targets
        },
        targets = { ["ftxui"] = { kind = "lib" } },
        deps    = { },
        windows = {
            cxxflags = { "-DUNICODE", "-D_UNICODE" },
        },
    },
}
