-- compat.expat — Expat, built from source.
--
-- The stream-oriented XML parser. It is in this index because
-- `wayland-scanner` parses `protocol/wayland.xml` with it, but Expat is a
-- general-purpose library and is packaged as one.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: SOURCE BUILD (Expat is a separable project)
--
-- Independent upstream with its own releases, so the index's default rule
-- applies.
--
-- The ecosystem carries `xim:expat` at 2.6.2 as a transitive of `xim:mesa`.
-- That does not make this a binding — see compat.libdrm for why coexistence is
-- fine — but it does constrain the VERSION: the store's installed-check
-- matches (name, version) ignoring the namespace, so `compat.expat@2.6.2`
-- would be shadowed and would silently never install. 2.7.1 is the current
-- upstream release and does not collide.
--
--     host          0
--     ecosystem     0   no `xim:*` dependency
--     index         0   `deps = {}`
--     transitive    0   libexpat.so.1 needs only libc
--
-- ─────────────────────────────────────────────────────────────────────────
-- THREE TRANSLATION UNITS, NOT FIVE
--
-- `lib/` holds five `.c` files and upstream compiles three of them:
-- `xmltok_impl.c` and `xmltok_ns.c` are `#include`d BY `xmltok.c` (three and
-- two times respectively, each time with different macros set) rather than
-- compiled on their own. Listing them as sources would compile them once more
-- with no macros defined and produce duplicate symbols.
--
-- ─────────────────────────────────────────────────────────────────────────
-- expat_config.h IS INLINED
--
-- It is configure's record of what it probed and cannot be derived from the
-- tarball, so it is reproduced below verbatim from a real `./configure` run on
-- x86_64 linux-gnu, minus the lines that name the build host. The entries that
-- matter behaviorally are `XML_DTD`, `XML_GE`, `XML_NS` and
-- `XML_CONTEXT_BYTES`: they are feature switches, not probes, and turning any
-- of them off silently changes what the parser accepts.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "expat",
    description = "Expat — stream-oriented XML parser, built from the upstream release",
    licenses    = {"MIT"},
    repo        = "https://github.com/libexpat/libexpat",
    type        = "package",

    xpm = {
        linux = {
            ["2.7.1"] = {
                url = {
                    GLOBAL = "https://github.com/libexpat/libexpat/releases/download/R_2_7_1/expat-2.7.1.tar.xz",
                    CN     = "https://gitcode.com/mcpp-res/expat/releases/download/2.7.1/expat-2.7.1.tar.xz",
                },
                sha256 = "354552544b8f99012e5062f7d570ec77f14b412a3ff5c7d8d0dae62c0d217c30",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c11",

        -- `lib` carries both the public headers (expat.h, expat_external.h)
        -- and the private ones the three TUs include; `expat_config.h` is
        -- generated into it so one entry covers the build and consumers.
        include_dirs = { "lib" },

        -- No config-selection macro: xmlparse.c does a plain
        -- `#include "expat_config.h"`, and generating it into `lib/` (rather
        -- than the top level, where upstream puts it behind a `-I..`) means the
        -- quote-form lookup finds it in its own directory.
        cflags = {
            "-D_GNU_SOURCE",
            "-fPIC",
        },

        sources = {
            "lib/xmlparse.c",
            "lib/xmltok.c",
            "lib/xmlrole.c",
        },

        -- STATIC, unlike compat.libdrm's shared build, and the difference is
        -- not an oversight.
        --
        -- libdrm is shared because Mesa's payload has DT_NEEDED on
        -- `libdrm.so.2` and the two must be ONE mapping — libdrm keeps mutable
        -- file-static state (`drmHashTable`, `nr_fds`, `connection`) over a
        -- shared set of fds, so a second copy is a split ledger. Expat has no
        -- equivalent: every bit of parser state hangs off the XML_Parser the
        -- caller owns, so a consumer that merges these objects while Mesa loads
        -- the payload's libexpat.so.1 is not sharing anything to corrupt.
        --
        -- And there is a concrete reason to prefer static here. Expat's only
        -- consumer in this index is `freedesktop.wayland-scanner`, a
        -- `kind = "bin"` HOST TOOL that mcpp builds in a sub-build and then
        -- RUNS during another package's build.mcpp. A host tool linking a
        -- shared dependency comes out with a DT_NEEDED nothing satisfies —
        -- mcpp does not stage the .so beside the tool, and the sub-build's
        -- bin/ holds the executable alone:
        --
        --     wayland-scanner: error while loading shared libraries:
        --     libexpat.so.1: cannot open shared object file
        --
        -- That reproduces only on a machine without a graphics stack: with
        -- Mesa installed the tool's RPATH reaches `<registry>/subos/default/lib`
        -- and silently binds to `xim:expat`'s copy instead — the WRONG library,
        -- succeeding. Static removes the question.
        targets = { ["expat"] = { kind = "lib" } },
        deps    = {},

        generated_files = {
            ["lib/expat_config.h"] =
[[
/* expat_config.h.  Generated from expat_config.h.in by configure.  */
/* expat_config.h.in.  Generated from configure.ac by autoheader.  */

#ifndef EXPAT_CONFIG_H
#define EXPAT_CONFIG_H 1

/* Define if building universal (internal helper macro) */
/* #undef AC_APPLE_UNIVERSAL_BUILD */

/* 1234 = LILENDIAN, 4321 = BIGENDIAN */
#define BYTEORDER 1234

/* Define to 1 if you have the `arc4random' function. */
/* #undef HAVE_ARC4RANDOM */

/* Define to 1 if you have the `arc4random_buf' function. */
#define HAVE_ARC4RANDOM_BUF 1

/* define if the compiler supports basic C++11 syntax */
/* #undef HAVE_CXX11 */

/* Define to 1 if you have the <dlfcn.h> header file. */
#define HAVE_DLFCN_H 1

/* Define to 1 if you have the <fcntl.h> header file. */
#define HAVE_FCNTL_H 1

/* Define to 1 if you have the `getpagesize' function. */
#define HAVE_GETPAGESIZE 1

/* Define to 1 if you have the `getrandom' function. */
#define HAVE_GETRANDOM 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define to 1 if you have the `bsd' library (-lbsd). */
/* #undef HAVE_LIBBSD */

/* Define to 1 if you have a working `mmap' system call. */
#define HAVE_MMAP 1

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

/* Define to 1 if you have `syscall' and `SYS_getrandom'. */
#define HAVE_SYSCALL_GETRANDOM 1

/* Define to 1 if you have the <sys/param.h> header file. */
#define HAVE_SYS_PARAM_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to the sub-directory where libtool stores uninstalled libraries. */

/* Name of package */

/* Define to the address where bug reports for this package should be sent. */

/* Define to the full name of this package. */

/* Define to the full name and version of this package. */

/* Define to the one symbol short name of this package. */

/* Define to the home page for this package. */

/* Define to the version of this package. */

/* Define to 1 if all of the C90 standard headers exist (not just the ones
   required in a freestanding environment). This macro is provided for
   backward compatibility; new code need not use it. */
#define STDC_HEADERS 1

/* Version number of package */
#define VERSION "2.7.1"

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

/* Define to allow retrieving the byte offsets for attribute names and values.
   */
/* #undef XML_ATTR_INFO */

/* Define to specify how much context to retain around the current parse
   point, 0 to disable. */
#define XML_CONTEXT_BYTES 1024

/* Define to include code reading entropy from `/dev/urandom'. */
#define XML_DEV_URANDOM 1

/* Define to make parameter entity parsing functionality available. */
#define XML_DTD 1

/* Define as 1/0 to enable/disable support for general entities. */
#define XML_GE 1

/* Define to make XML Namespaces functionality available. */
#define XML_NS 1

/* Define to empty if `const' does not conform to ANSI C. */
/* #undef const */

/* Define to `long int' if <sys/types.h> does not define. */
/* #undef off_t */

#endif // ndef EXPAT_CONFIG_H
]],
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

-- Once a descriptor defines install(), the archive is extracted to a sibling of
-- the install dir rather than into it; moving it is the descriptor's job. Same
-- opening as compat.libdrm, compat.libffi and compat.xcb.
function install()
    local srcroot = pkginfo.install_file():replace(".tar.xz", "")
    if not os.isdir(srcroot) then
        srcroot = "expat-" .. pkginfo.version()
    end
    if not os.isdir(srcroot) then
        log.error("[expat] extracted tree not found (looked for %s)", srcroot)
        return false
    end

    os.tryrm(pkginfo.install_dir())
    os.mv(srcroot, pkginfo.install_dir())

    if not os.isfile(path.join(pkginfo.install_dir(), "lib", "expat.h")) then
        log.error("[expat] lib/expat.h missing from the release tarball")
        return false
    end

    return true
end
