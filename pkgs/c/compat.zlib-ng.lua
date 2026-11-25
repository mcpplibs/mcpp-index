-- compat.zlib-ng — zlib-ng in its zlib-compatible form, built from source.
--
-- The zlib API (`zlib.h`, `compress2`, `uncompress`, `inflate`, the gz files)
-- over zlib-ng's implementation: the same streams and the same names as
-- compat.zlib, with the inner loops of inflate, adler32 and the deflate match
-- search written for the processor's vector unit. A consumer that wants zlib's
-- interface and not madler's code chooses this package instead of compat.zlib;
-- the two define the same symbols and do not share a link.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY IT EXISTS (mcpp-community/mcpp design 2026-11-08, W5)
--
-- mcppls-clangd's ok image reads its index shards through zlib. Against a
-- native clangd linked to macOS's own libz, whose inflate and adler32 use
-- NEON, the image's warm start took 1.214–1.332 times the processor time with
-- compat.zlib and 0.973–1.107 with no zlib at all, on the same runner (runs
-- 42369457883 and 42386660489, four pairs each). The difference is the
-- decompression of the shards, and zlib-ng's NEON inflate is what closes it.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE PROCESSOR'S PATHS ARE CHOSEN AT COMPILE TIME
--
-- Upstream chooses among its implementations at run time (functable.c over
-- cpu_features.c, which reads the auxiliary vector, cpuid or sysctl). An ok
-- image has none of these: openkal names no processor feature. This package
-- is therefore CMake's `WITH_RUNTIME_CPU_DETECTION=OFF` build, in which
-- arch_functions.h binds each function to the best implementation the
-- target's BASELINE guarantees:
--
--     aarch64   NEON (Armv8-A has it): inflate_fast, adler32, chunkmemset,
--               slide_hash, compare256 and longest_match
--     x86_64    SSE2 (x86-64 has it): chunkmemset, inflate_fast, slide_hash,
--               compare256, longest_match and the CRC's chorba fold
--
-- Every architecture source but one opens with its own guard (`#ifdef
-- ARM_NEON`, `#ifdef X86_SSE2`), so all of them are listed and the
-- configuration header below sets the guard from the compiler's architecture
-- macro, the way compat.wamr chooses its target. arch/x86/slide_hash_sse2.c
-- has no guard, because upstream's CMake lists it for x86 only; it is
-- compiled through a generated source that includes it under `X86_SSE2`. A path beyond the baseline (the Armv8 CRC32
-- instructions, SSSE3, AVX2, PCLMULQDQ) needs either a flag the whole program
-- would then require or detection at run time, and is not built. The CRC32
-- instructions matter to gzip streams only: a zlib stream, which is what LLVM
-- writes, is checked with adler32.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE GENERATED HEADERS
--
-- CMake writes three public headers and one private one. install() derives
-- them from the tarball's templates rather than inlining 2000 lines, so a
-- version bump cannot ship an old header:
--
--     zlib.h                  zlib.h.in with @ZLIB_SYMBOL_PREFIX@ empty (no
--                             prefix: the names are zlib's own)
--     zconf.h                 zconf.h.in, with configure's `#ifdef
--                             HAVE_UNISTD_H` written as `#if !defined(_WIN32)`
--     zlib_name_mangling.h    zlib_name_mangling.h.empty, as CMake copies it
--     gzread_mangle.h         gzread_mangle.h.in with the prefix empty (gzread.c
--                             undefines zlib.h's gzgetc macro through it)
--
-- CMake writes `#if 1` into zconf.h on a POSIX system and leaves the line on
-- Windows. The condition written here is the same decision taken by the
-- header itself, so the library and every consumer compute z_off_t from one
-- text and cannot disagree (compat.zlib needs a package-private `-include`
-- for the same line and documents the split; this package has none). On
-- Windows with musl as the C library (an openkal graph) `_WIN32` is absent,
-- because openkal-musl presents POSIX, and the header takes the POSIX branch
-- there as well.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "zlib-ng",
    description = "zlib-ng in its zlib-compatible form: zlib's API with vectorised inflate, adler32 and deflate",
    licenses    = {"Zlib"},
    repo        = "https://github.com/zlib-ng/zlib-ng",
    type        = "package",

    xpm = {
        linux = {
            ["2.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/zlib-ng/zlib-ng/archive/refs/tags/2.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/zlib-ng/releases/download/2.3.3/zlib-ng-2.3.3.tar.gz",
                },
                sha256 = "f9c65aa9c852eb8255b636fd9f07ce1c406f061ec19a2e7d508b318ca0c907d1",
            },
        },
        macosx = {
            ["2.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/zlib-ng/zlib-ng/archive/refs/tags/2.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/zlib-ng/releases/download/2.3.3/zlib-ng-2.3.3.tar.gz",
                },
                sha256 = "f9c65aa9c852eb8255b636fd9f07ce1c406f061ec19a2e7d508b318ca0c907d1",
            },
        },
        windows = {
            ["2.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/zlib-ng/zlib-ng/archive/refs/tags/2.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/zlib-ng/releases/download/2.3.3/zlib-ng-2.3.3.tar.gz",
                },
                sha256 = "f9c65aa9c852eb8255b636fd9f07ce1c406f061ec19a2e7d508b318ca0c907d1",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        -- The tree's root holds the public headers install() writes and the
        -- private ones every architecture source includes by name
        -- (`#include "zbuild.h"` from arch/arm/), as compat.zlib's root does.
        include_dirs = {"*", "mcpp_generated/include"},
        -- Package-private: the configuration of zlib-ng's own translation
        -- units. No line of it changes a public declaration; zlib.h and
        -- zconf.h read none of these names.
        cflags = { "-include", "mcpp_zlibng_config.h" },
        linux = {
            cflags = { "-D_GNU_SOURCE" },
        },
        generated_files = {
            ["mcpp_generated/include/mcpp_zlibng_config.h"] =
[==[
#ifndef MCPP_ZLIBNG_CONFIG_H
#define MCPP_ZLIBNG_CONFIG_H
/* CMake's definitions for zlib-ng 2.3.3 with ZLIB_COMPAT=ON and
   WITH_RUNTIME_CPU_DETECTION=OFF, taken from its compile_commands.json, with
   the architecture taken from the compiler instead of from CMake's probe. */
#define ZLIB_COMPAT 1
#define WITH_GZFILEOP 1
#define WITH_OPTIM 1
#define DISABLE_RUNTIME_CPU_DETECTION 1
#if defined(__GNUC__) || defined(__clang__)
#  define HAVE_ATTRIBUTE_ALIGNED 1
#  define HAVE_BUILTIN_ASSUME_ALIGNED 1
#  define HAVE_BUILTIN_CTZ 1
#  define HAVE_BUILTIN_CTZLL 1
#  define HAVE_VISIBILITY_HIDDEN 1
#  define HAVE_VISIBILITY_INTERNAL 1
#endif
#if defined(__aarch64__) || defined(_M_ARM64)
#  define ARM_FEATURES 1
#  define ARM_NEON 1
#  define ARM_NEON_HASLD4 1
#elif defined(__x86_64__) || defined(_M_X64)
#  define X86_FEATURES 1
#  define X86_SSE2 1
#endif
#endif
]==],
            -- The one architecture source without a guard of its own.
            ["mcpp_generated/slide_hash_sse2.c"] =
[==[
#ifdef X86_SSE2
#include "arch/x86/slide_hash_sse2.c"
#endif
]==],
        },
        sources = {
            "*/adler32.c",
            "*/compress.c",
            "*/crc32.c",
            "*/crc32_braid_comb.c",
            "*/deflate.c",
            "*/deflate_fast.c",
            "*/deflate_huff.c",
            "*/deflate_medium.c",
            "*/deflate_quick.c",
            "*/deflate_rle.c",
            "*/deflate_slow.c",
            "*/deflate_stored.c",
            "*/functable.c",
            "*/gzlib.c",
            "*/gzread.c",
            "*/gzwrite.c",
            "*/infback.c",
            "*/inflate.c",
            "*/inftrees.c",
            "*/insert_string.c",
            "*/insert_string_roll.c",
            "*/trees.c",
            "*/uncompr.c",
            "*/zutil.c",
            -- The portable implementations: the baseline every architecture
            -- falls back to, and the only one of the others.
            "*/arch/generic/adler32_c.c",
            "*/arch/generic/adler32_fold_c.c",
            "*/arch/generic/chunkset_c.c",
            "*/arch/generic/compare256_c.c",
            "*/arch/generic/crc32_braid_c.c",
            "*/arch/generic/crc32_chorba_c.c",
            "*/arch/generic/crc32_fold_c.c",
            "*/arch/generic/slide_hash_c.c",
            -- Each guarded by its own `#ifdef`; see the header comment.
            "*/arch/arm/adler32_neon.c",
            "*/arch/arm/chunkset_neon.c",
            "*/arch/arm/compare256_neon.c",
            "*/arch/arm/slide_hash_neon.c",
            "*/arch/x86/chorba_sse2.c",
            "*/arch/x86/chunkset_sse2.c",
            "*/arch/x86/compare256_sse2.c",
            "mcpp_generated/slide_hash_sse2.c",
        },
        targets = { ["zlib"] = { kind = "lib" } },
        deps    = {},
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

-- What CMake's configure_file does to the four headers.
function install()
    -- Once a descriptor defines install(), the archive is extracted beside the
    -- install dir; the tree is moved into it under its own name, so the layout
    -- is the one an extraction without install() has (`*/zlib.h`).
    local name = "zlib-ng-" .. pkginfo.version()
    local srcroot = pkginfo.install_file():replace(".tar.gz", "")
    if not os.isdir(srcroot) then srcroot = name end
    if not os.isdir(srcroot) then
        log.error("[zlib-ng] extracted tree not found (looked for %s)", srcroot)
        return false
    end
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())
    local root = path.join(pkginfo.install_dir(), name)
    os.mv(srcroot, root)

    local function derive(template, header, edit)
        local text = io.readfile(path.join(root, template))
        if not text then
            log.error("[zlib-ng] %s missing from the release tarball", template)
            return false
        end
        text = edit(text)
        if text:find("@[A-Za-z_]+@") then
            log.error("[zlib-ng] %s has a placeholder this descriptor does not substitute", template)
            return false
        end
        io.writefile(path.join(root, header), text)
        return true
    end

    if not derive("zlib.h.in", "zlib.h", function(t)
        return (t:gsub("@ZLIB_SYMBOL_PREFIX@", ""))
    end) then return false end

    local unistd = "#ifdef HAVE_UNISTD_H    /* may be set to #if 1 by configure/cmake/etc */"
    if not derive("zconf.h.in", "zconf.h", function(t)
        local s, e = t:find(unistd, 1, true)
        if not s then return t .. "\n@UNISTD_LINE_NOT_FOUND@\n" end
        return t:sub(1, s - 1) .. "#if !defined(_WIN32)    /* CMake writes #if 1 here on a POSIX system */" .. t:sub(e + 1)
    end) then return false end

    if not derive("gzread_mangle.h.in", "gzread_mangle.h", function(t)
        return (t:gsub("@ZLIB_SYMBOL_PREFIX@", ""))
    end) then return false end

    if not os.isfile(path.join(root, "zlib_name_mangling.h.empty")) then
        log.error("[zlib-ng] zlib_name_mangling.h.empty missing from the release tarball")
        return false
    end
    os.cp(path.join(root, "zlib_name_mangling.h.empty"), path.join(root, "zlib_name_mangling.h"))
    return true
end
