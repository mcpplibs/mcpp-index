-- Form B inline descriptor for {fmt} exposed as the C++23 module `fmt`, so
-- users can write `import fmt;` out of the box (no `#include` needed). This is
-- the module sibling of the header-based `compat.fmt` package. Namespaced under
-- `fmtlib` (package `fmtlib.fmt`) so a workspace member can route the dependency
-- to this repo's local `[indices] fmtlib = { path }` — an empty namespace would
-- bind to the builtin default index and can't be pointed at a local path. The
-- exported module name is still plain `fmt`, so consumers write `import fmt;`.
--
-- fmt's release DOES ship an official C++20 module interface unit at
-- `src/fmt.cc` (`export module fmt;`), but it cannot be fed to mcpp verbatim:
-- mcpp's M1 module scanner rejects ANY `import` that appears inside a
-- conditional preprocessor block (the scanner is a pre-preprocess text pass, so
-- it can't evaluate the `#ifdef` — the guard is textual, not value-based), and
-- fmt.cc carries `#ifdef FMT_IMPORT_STD / import std; / #endif`. So we reproduce
-- fmt.cc via `generated_files` with two minimal edits: (1) `#define
-- FMT_IMPORT_STD` right after `#define FMT_MODULE`, which flips fmt's own
-- `#ifndef FMT_IMPORT_STD` include block to the import-std path (dropping the
-- ~40 `#include <algorithm>`…`<vector>` lines); (2) that `#ifdef` guard around
-- `import std;` removed so the import sits unconditional at module top level,
-- which the scanner accepts. `import_std = true` makes mcpp build the `std`
-- module first. Everything else is upstream fmt.cc verbatim: the
-- `export module fmt;` line, the FMT_EXPORT macro plumbing (fmt's headers
-- self-`export` under FMT_MODULE), and the tail `#include "format.cc"` /
-- `"os.cc"` that pulls the implementation INTO the module (so its definitions
-- attach to module `fmt`; compiling them as standalone TUs would leave them on
-- the global module and break module linkage).
--
-- include_dirs exposes BOTH `*/include` (so the module unit's `#include
-- <fmt/*.h>` resolves) and `*/src` (so the tail `#include "format.cc"` /
-- `"os.cc"` resolve). The wrapper path under mcpp_generated/ is verdir-relative
-- (no glob), like nlohmann.json / compat.eigen.
--
-- The wrapper MUST be named `.cppm`, not `.cc`. On macOS/Windows mcpp drives
-- Clang in gnu (`--driver-mode=g++`) mode, where Clang decides "is this a module
-- interface unit?" purely from the file extension: `.cppm`/`.ixx` yes, `.cc` no.
-- A `.cc` module unit still compiles, but Clang silently drops `-fmodule-output`
-- as an "unused argument" (-Wunused-command-line-argument), so NO BMI (`fmt.pcm`)
-- is written — the consumer's `import fmt;` then fails with `module 'fmt' not
-- found`. GCC (Linux) keys off `export module` instead of the extension, so `.cc`
-- happened to work there and masked the bug. nlohmann.json already uses `.cppm`;
-- this matches it.
package = {
    spec        = "1",
    namespace   = "fmtlib",
    name        = "fmtlib.fmt",
    description = "A modern formatting library for C++, exposed as C++23 module fmt",
    licenses    = {"MIT"},
    repo        = "https://github.com/fmtlib/fmt",
    type        = "package",

    xpm = {
        linux = {
            ["12.2.0"] = {
                url    = "https://github.com/fmtlib/fmt/archive/refs/tags/12.2.0.tar.gz",
                sha256 = "8b852bb5aa6e7d8564f9e81394055395dd1d1936d38dfd3a17792a02bebd7af0",
            },
        },
        macosx = {
            ["12.2.0"] = {
                url    = "https://github.com/fmtlib/fmt/archive/refs/tags/12.2.0.tar.gz",
                sha256 = "8b852bb5aa6e7d8564f9e81394055395dd1d1936d38dfd3a17792a02bebd7af0",
            },
        },
        windows = {
            ["12.2.0"] = {
                url    = "https://github.com/fmtlib/fmt/archive/refs/tags/12.2.0.tar.gz",
                sha256 = "8b852bb5aa6e7d8564f9e81394055395dd1d1936d38dfd3a17792a02bebd7af0",
            },
        },
    },

    mcpp = {
        schema       = "0.1",
        language     = "c++23",
        import_std   = true,
        modules      = { "fmt" },
        include_dirs = { "*/include", "*/src" },
        generated_files = {
            ["mcpp_generated/fmt_module.cppm"] = "// Formatting library for C++ - C++20 module\n//\n// Copyright (c) 2012 - present, Victor Zverovich and {fmt} contributors\n// All rights reserved.\n//\n// For the license information refer to format.h.\n\nmodule;\n\n#define FMT_MODULE\n\n#define FMT_IMPORT_STD\n\n#ifdef _MSVC_LANG\n#  define FMT_CPLUSPLUS _MSVC_LANG\n#else\n#  define FMT_CPLUSPLUS __cplusplus\n#endif\n\n// Put all implementation-provided headers into the global module fragment\n// to prevent attachment to this module.\n#ifndef FMT_IMPORT_STD\n#  include <algorithm>\n#  include <bitset>\n#  include <chrono>\n#  include <cmath>\n#  include <complex>\n#  include <cstddef>\n#  include <cstdint>\n#  include <cstdio>\n#  include <cstdlib>\n#  include <cstring>\n#  include <ctime>\n#  include <exception>\n#  if FMT_CPLUSPLUS > 202002L\n#    include <expected>\n#  endif\n#  include <filesystem>\n#  include <fstream>\n#  include <functional>\n#  include <iterator>\n#  include <limits>\n#  include <locale>\n#  include <memory>\n#  include <optional>\n#  include <ostream>\n#  include <source_location>\n#  include <stdexcept>\n#  include <string>\n#  include <string_view>\n#  include <system_error>\n#  include <thread>\n#  include <type_traits>\n#  include <typeinfo>\n#  include <utility>\n#  include <variant>\n#  include <vector>\n#else\n#  include <limits.h>\n#  include <stdint.h>\n#  include <stdio.h>\n#  include <stdlib.h>\n#  include <string.h>\n#  include <time.h>\n#endif\n#include <cerrno>\n#include <climits>\n#include <version>\n\n#if __has_include(<cxxabi.h>)\n#  include <cxxabi.h>\n#endif\n#if defined(_MSC_VER) || defined(__MINGW32__)\n#  include <intrin.h>\n#endif\n#if defined __APPLE__ || defined(__FreeBSD__)\n#  include <xlocale.h>\n#endif\n#if __has_include(<winapifamily.h>)\n#  include <winapifamily.h>\n#endif\n#if (__has_include(<fcntl.h>) || defined(__APPLE__) || \\\n     defined(__linux__)) &&                            \\\n    (!defined(WINAPI_FAMILY) || (WINAPI_FAMILY == WINAPI_FAMILY_DESKTOP_APP))\n#  include <fcntl.h>\n#  include <sys/stat.h>\n#  include <sys/types.h>\n#  ifndef _WIN32\n#    include <unistd.h>\n#  else\n#    include <io.h>\n#  endif\n#endif\n#ifdef _WIN32\n#  if defined(__GLIBCXX__)\n#    include <ext/stdio_filebuf.h>\n#    include <ext/stdio_sync_filebuf.h>\n#  endif\n#  define WIN32_LEAN_AND_MEAN\n#  include <windows.h>\n#endif\n\nexport module fmt;\n\nimport std;\n\n#define FMT_EXPORT export\n#define FMT_BEGIN_EXPORT export {\n#define FMT_END_EXPORT }\n\n// If you define FMT_ATTACH_TO_GLOBAL_MODULE\n//  - all declarations are detached from module 'fmt'\n//  - the module behaves like a traditional static library, too\n//  - all library symbols are mangled traditionally\n//  - you can mix TUs with either importing or #including the {fmt} API\n#ifdef FMT_ATTACH_TO_GLOBAL_MODULE\nextern \"C++\" {\n#endif\n\n#ifndef FMT_OS\n#  define FMT_OS 1\n#endif\n\n// All library-provided declarations and definitions must be in the module\n// purview to be exported.\n#include \"fmt/args.h\"\n#include \"fmt/chrono.h\"\n#include \"fmt/color.h\"\n#include \"fmt/compile.h\"\n#include \"fmt/format.h\"\n#if FMT_OS\n#  include \"fmt/os.h\"\n#endif\n#include \"fmt/ostream.h\"\n#include \"fmt/printf.h\"\n#include \"fmt/ranges.h\"\n#include \"fmt/std.h\"\n#include \"fmt/xchar.h\"\n\n#ifdef FMT_ATTACH_TO_GLOBAL_MODULE\n}\n#endif\n\n#ifdef FMT_ATTACH_TO_GLOBAL_MODULE\nextern \"C++\" {\n#endif\n\n#if FMT_HAS_INCLUDE(\"format.cc\")\n#  include \"format.cc\"\n#endif\n#if FMT_OS && FMT_HAS_INCLUDE(\"os.cc\")\n#  include \"os.cc\"\n#endif\n\n#ifdef FMT_ATTACH_TO_GLOBAL_MODULE\n}\n#endif\n",
        },
        sources      = { "mcpp_generated/fmt_module.cppm" },
        targets      = { ["fmt"] = { kind = "lib" } },
        deps         = { },
    },
}
