-- compat.libffi — libffi, built from source.
--
-- The foreign-function-interface library: `ffi_prep_cif` / `ffi_call` build and
-- invoke a call frame at runtime from a described signature. It exists in this
-- index because compat.wayland needs it — `libwayland-client` dispatches every
-- protocol message through `ffi_call` — but it is a general-purpose library and
-- is packaged as one.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: SOURCE BUILD (libffi is a separable project)
--
-- Independent upstream with its own releases, so the index's default rule
-- applies and there is nothing to argue about.
--
-- The ecosystem also has `xim:libffi`, at 3.4.4, installed as a transitive of
-- `xim:mesa`. That does NOT make this a binding — see compat.libdrm for the
-- measurement — but it does constrain the VERSION. The store's installed-check
-- matches (name, version) and ignores the namespace, so a `compat.libffi@3.4.4`
-- would be shadowed by `xim:libffi@3.4.4` and silently never install. 3.4.8 is
-- the current upstream release and does not collide.
--
--     host          0
--     ecosystem     0   no `xim:*` dependency
--     index         0   `deps = {}`
--     transitive    0   libffi.so.8 needs only libc
--
-- ─────────────────────────────────────────────────────────────────────────
-- ARCHITECTURE FILES SELECT THEMSELVES
--
-- libffi is mostly per-ABI assembly, which normally means the build system
-- picks a source set per target. It does not have to here: every file in
-- `src/x86/` opens with its own architecture guard —
--
--     ffi.c      `#if defined(__i386__) || defined(_M_IX86)`
--     ffiw64.c   `#if defined(__x86_64__) || defined(_M_AMD64)`
--     unix64.S   `#ifdef __x86_64__`
--     win64.S    `#ifdef __x86_64__`
--     sysv.S     `#ifdef __i386__`
--
-- so all of them can be listed and the preprocessor drops the ones that do not
-- apply. The `.S` files also `#define LIBFFI_ASM` themselves, so no assembler
-- flag is needed either. This is x86/x86_64 only; another architecture needs
-- its own `src/<arch>/` files added here.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE THREE GENERATED HEADERS
--
-- Upstream's configure produces `fficonfig.h`, substitutes `include/ffi.h.in`
-- into `ffi.h`, and copies the target's `ffitarget.h` into `include/`.
--
-- `fficonfig.h` cannot be derived from the tarball — it is the record of what
-- configure probed — so it is inlined below, verbatim from a real
-- `./configure` run on x86_64-pc-linux-gnu with the host-naming lines dropped.
--
-- The other two ARE derivable, so install() does what configure would rather
-- than hard-coding 500 lines: `ffi.h.in` has exactly four substitutions
-- (@TARGET@, @HAVE_LONG_DOUBLE@, @FFI_EXEC_TRAMPOLINE_TABLE@, @VERSION@) and
-- `ffitarget.h` is a copy. Deriving them keeps this descriptor honest when the
-- version moves.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libffi",
    description = "libffi — portable foreign function interface, built from the upstream release",
    licenses    = {"MIT"},
    repo        = "https://github.com/libffi/libffi",
    type        = "package",

    xpm = {
        linux = {
            ["3.4.8"] = {
                url = {
                    GLOBAL = "https://github.com/libffi/libffi/releases/download/v3.4.8/libffi-3.4.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libffi/releases/download/3.4.8/libffi-3.4.8.tar.gz",
                },
                sha256 = "bc9842a18898bfacb0ed1252c4febcc7e78fa139fd27fdc7a3e30d9d9356119b",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c11",

        -- Upstream's AM_CPPFLAGS is `-I. -I$(top_srcdir)/include -Iinclude
        -- -I$(top_srcdir)/src`; `.` is where fficonfig.h lands and
        -- ffi_common.h opens with `#include <fficonfig.h>`.
        -- Upstream's AM_CPPFLAGS is `-I. -I$(top_srcdir)/include -Iinclude
        -- -I$(top_srcdir)/src`. install() flattens the tree, and fficonfig.h
        -- is generated into `include/` rather than the root so these two
        -- entries cover everything: ffi_common.h opens with
        -- `#include <fficonfig.h>`, and the x86 sources reach `internal64.h`
        -- and friends through `src`.
        include_dirs = {
            "include",
            "src",
        },

        cflags = { "-D_GNU_SOURCE", "-fPIC" },

        sources = {
            -- portable core
            "src/prep_cif.c",
            "src/types.c",
            "src/raw_api.c",
            "src/java_raw_api.c",
            "src/closures.c",
            "src/tramp.c",
            -- x86 family; each guards itself, see the header comment
            "src/x86/ffi.c",
            "src/x86/ffi64.c",
            "src/x86/ffiw64.c",
            "src/x86/sysv.S",
            "src/x86/unix64.S",
            "src/x86/win64.S",
        },

        targets = { ["ffi"] = { kind = "shared", soname = "libffi.so.8" } },
        deps    = {},

        generated_files = {
            ["include/fficonfig.h"] =
[[
/* fficonfig.h.  Generated from fficonfig.h.in by configure.  */
/* fficonfig.h.in.  Generated from configure.ac by autoheader.  */

/* Define if building universal (internal helper macro) */
/* #undef AC_APPLE_UNIVERSAL_BUILD */

/* Define to the flags needed for the .section .eh_frame directive. */
#define EH_FRAME_FLAGS "a"

/* Define this if you want extra debugging. */
/* #undef FFI_DEBUG */

/* Define this if you want statically defined trampolines */
#define FFI_EXEC_STATIC_TRAMP 1

/* Cannot use PROT_EXEC on this target, so, we revert to alternative means */
/* #undef FFI_EXEC_TRAMPOLINE_TABLE */

/* Define this if you want to enable pax emulated trampolines (experimental)
   */
/* #undef FFI_MMAP_EXEC_EMUTRAMP_PAX */

/* Cannot use malloc on this target, so, we revert to alternative means */
/* #undef FFI_MMAP_EXEC_WRIT */

/* Define this if you do not want support for the raw API. */
/* #undef FFI_NO_RAW_API */

/* Define this if you do not want support for aggregate types. */
/* #undef FFI_NO_STRUCTS */

/* Define to 1 if you have the <alloca.h> header file. */
#define HAVE_ALLOCA_H 1

/* Define if your compiler supports pointer authentication. */
/* #undef HAVE_ARM64E_PTRAUTH */

/* Define if your assembler supports .cfi_* directives. */
#define HAVE_AS_CFI_PSEUDO_OP 1

/* Define if your assembler supports .register. */
/* #undef HAVE_AS_REGISTER_PSEUDO_OP */

/* Define if the compiler uses zarch features. */
/* #undef HAVE_AS_S390_ZARCH */

/* Define if your assembler and linker support unaligned PC relative relocs.
   */
/* #undef HAVE_AS_SPARC_UA_PCREL */

/* Define if your assembler supports unwind section type. */
#define HAVE_AS_X86_64_UNWIND_SECTION_TYPE 1

/* Define if your assembler supports PC relative relocs. */
#define HAVE_AS_X86_PCREL 1

/* Define to 1 if you have the <dlfcn.h> header file. */
#define HAVE_DLFCN_H 1

/* Define if __attribute__((visibility("hidden"))) is supported. */
#define HAVE_HIDDEN_VISIBILITY_ATTRIBUTE 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define if you have the long double type and it is bigger than a double */
#define HAVE_LONG_DOUBLE 1

/* Define if you support more than one size of the long double type */
/* #undef HAVE_LONG_DOUBLE_VARIANT */

/* Define to 1 if you have the `memcpy' function. */
#define HAVE_MEMCPY 1

/* Define to 1 if you have the `memfd_create' function. */
#define HAVE_MEMFD_CREATE 1

/* Define if .eh_frame sections should be read-only. */
#define HAVE_RO_EH_FRAME 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdio.h> header file. */
#define HAVE_STDIO_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the <sys/memfd.h> header file. */
/* #undef HAVE_SYS_MEMFD_H */

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to 1 if GNU symbol versioning is used for libatomic. */
#define LIBFFI_GNU_SYMBOL_VERSIONING 1

/* Define to the sub-directory where libtool stores uninstalled libraries. */

/* Name of package */

/* Define to the address where bug reports for this package should be sent. */

/* Define to the full name of this package. */

/* Define to the full name and version of this package. */

/* Define to the one symbol short name of this package. */

/* Define to the home page for this package. */

/* Define to the version of this package. */

/* The size of `double', as computed by sizeof. */
#define SIZEOF_DOUBLE 8

/* The size of `long double', as computed by sizeof. */
#define SIZEOF_LONG_DOUBLE 16

/* The size of `size_t', as computed by sizeof. */
#define SIZEOF_SIZE_T 8

/* Define to 1 if all of the C90 standard headers exist (not just the ones
   required in a freestanding environment). This macro is provided for
   backward compatibility; new code need not use it. */
#define STDC_HEADERS 1

/* Define if symbols are underscored. */
/* #undef SYMBOL_UNDERSCORE */

/* Define this if you are using Purify and want to suppress spurious messages.
   */
/* #undef USING_PURIFY */

/* Version number of package */
#define VERSION "3.4.8"

/* Define WORDS_BIGENDIAN to 1 if your processor stores words with the most
   significant byte first (like Motorola and SPARC, unlike Intel). */
#if defined AC_APPLE_UNIVERSAL_BUILD
# if defined __BIG_ENDIAN__
#  define WORDS_BIGENDIAN 1
# endif
#else
# ifndef WORDS_BIGENDIAN
/* #  undef WORDS_BIGENDIAN */
# endif
#endif


#ifdef HAVE_HIDDEN_VISIBILITY_ATTRIBUTE
#ifdef LIBFFI_ASM
#ifdef __APPLE__
#define FFI_HIDDEN(name) .private_extern name
#else
#define FFI_HIDDEN(name) .hidden name
#endif
#else
#define FFI_HIDDEN __attribute__ ((visibility ("hidden")))
#endif
#else
#ifdef LIBFFI_ASM
#define FFI_HIDDEN(name)
#else
#define FFI_HIDDEN
#endif
#endif
]],
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

-- What configure does to the two derivable headers. Kept as code rather than
-- as two more inlined blobs so a version bump does not silently ship the old
-- ffi.h: this reads the tarball's own `.in` every time.
function install()
    -- Once a descriptor defines install(), the archive is extracted to a
    -- sibling of the install dir instead of into it, and moving it is the
    -- descriptor's job — the same opening compat.libdrm and compat.xcb have.
    local srcroot = pkginfo.install_file():replace(".tar.gz", "")
    if not os.isdir(srcroot) then
        srcroot = "libffi-" .. pkginfo.version()
    end
    if not os.isdir(srcroot) then
        log.error("[libffi] extracted tree not found (looked for %s)", srcroot)
        return false
    end
    os.tryrm(pkginfo.install_dir())
    os.mv(srcroot, pkginfo.install_dir())

    local root = pkginfo.install_dir()

    local template = path.join(root, "include", "ffi.h.in")
    local text = io.readfile(template)
    if not text then
        log.error("[libffi] include/ffi.h.in missing from the release tarball")
        return false
    end

    text = text:gsub("@TARGET@", "X86_64")
               :gsub("@HAVE_LONG_DOUBLE@", "1")
               :gsub("@FFI_EXEC_TRAMPOLINE_TABLE@", "0")
               :gsub("@VERSION@", pkginfo.version())

    if text:find("@[A-Za-z_]+@") then
        log.error("[libffi] ffi.h.in has a placeholder this descriptor does not "
                  .. "substitute; the header would not compile")
        return false
    end
    io.writefile(path.join(root, "include", "ffi.h"), text)

    -- configure copies the target ffitarget.h into include/; ffi.h does
    -- `#include <ffitarget.h>` and consumers need it too.
    local target_header = path.join(root, "src", "x86", "ffitarget.h")
    if not os.isfile(target_header) then
        log.error("[libffi] src/x86/ffitarget.h missing")
        return false
    end
    os.cp(target_header, path.join(root, "include", "ffitarget.h"))

    return true
end
