-- Form B inline descriptor for unixODBC — the ODBC driver manager (libodbc,
-- with libodbcinst folded in), built from source on linux.
--
-- WHY THIS PACKAGE EXISTS: compat.nanodbc (and any other ODBC client) needs
-- <sql.h>/<sqlext.h> to compile and a driver manager to link and run. On
-- Windows the SDK supplies odbc32; on macOS iODBC is part of the OS. On linux
-- the manager is a third-party library, and mcpp's runtime-closure check
-- rejects a binary whose NEEDED libodbc.so.2 can only come from the host
-- (its PT_INTERP is a private loader; the host's /usr/lib is not consulted).
-- Linking the manager STATICALLY from source removes the NEEDED entry
-- entirely, which is what makes an ODBC client runnable under mcpp at all.
-- This is the same conclusion conan (odbc/2.3.x) and vcpkg (unixodbc) reach:
-- linux ODBC gets built, not assumed.
--
-- SHAPE: E over A — plain C sources plus a frozen configure snapshot, the
-- compat.curl / compat.sdl2 treatment. The one upstream tarball builds with
-- ZERO configure/make at consume time:
--
--   * DriverManager/*.c, odbcinst/*.c, ini/*.c, log/*.c, lst/*.c compile
--     verbatim (their dir contents match the Makefile.am lists exactly).
--   * mcpp_generated/include/config.h is the frozen top-level configure
--     output, MERGED with the macros from libltdl/config.h that the top-level
--     one lacks (name clashes excluded -- ltdl sources never read them). One
--     config.h for everything: ltdl's LT_CONFIG_H override mechanism would
--     need a quoted define that does not survive the descriptor -> command-
--     line pipeline, and merging makes it unnecessary.
--   * mcpp_generated/include/unixodbc.h is the frozen unixodbc.h.in output.
--     It is a PUBLIC header (include/sqltypes.h includes it), which is why
--     the generated dir is on the public include path at all.
--   * -D_GNU_SOURCE: upstream relies on configure's default gnu dialect;
--     under strict -std=c11 strdup/strlcpy/intptr_t disappear.
--
-- THE LIBLTDL PART IS THE ONE NON-OBVIOUS PIECE. The DM dlopen()s drivers
-- through libltdl, and libtool normally wires the dlopen loader in with
-- -dlpreopen. Without libtool, two things reproduce that wiring exactly:
--
--   1. -DLTDLOPEN=libltdlc makes ltdl.c preload the symbol table named
--      lt_libltdlc_LTX_preloaded_symbols.
--   2. mcpp_generated/ltdl_preload.c provides that table — byte-identical in
--      effect to the one libtool generates (reconstructed from the .o's
--      relocations), registering the dlopen loader's get_vtable.
--
--   Verified against the libtool-built static libodbc.a from the same
--   tarball: identical behaviour on handle alloc, driver enumeration, the
--   IM002 error path, AND lt_dlopen of a real .so through the registered
--   dlopen loader.
--
-- ONE TARGET, NOT TWO. Upstream ships libodbc and libodbcinst separately;
-- here everything (DM + odbcinst + ini/log/lst + ltdl) lands in the single
-- `odbc` target, which is exactly the symbol set upstream's libodbc.a already
-- carries (it absorbs the convenience libs). Driver installers that want
-- SQLInstallDriverEx find it in the same archive.
--
-- PATHS: the frozen config keeps configure's /usr/local defaults
-- (SYSTEM_FILE_PATH=/usr/local/etc for odbc.ini). ODBCSYSINI / ODBCINI env
-- vars override at runtime, same as any vanilla unixODBC build.
--
-- LINUX ONLY: windows uses the SDK's odbc32, macOS has iODBC in the OS; only
-- linux lacks a system driver manager. Declared for linux alone rather than
-- pretending otherwise (the compat.glx-runtime shape).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "unixodbc",
    description = "unixODBC driver manager (libodbc with libodbcinst folded in), full source build",
    licenses    = {"LGPL-2.1-or-later"},
    repo        = "https://www.unixodbc.org",
    type        = "package",

    xpm = {
        linux = {
            ["2.3.14"] = {
                -- The dist tarball (not the github archive) is required: only
                -- it carries the pre-bootstrapped libltdl/. Upstream publishes
                -- the same bytes on www.unixodbc.org and as the asset of its
                -- GitHub release; the GitHub asset is the GLOBAL source, and
                -- mcpp-res/unixodbc on GitCode mirrors it for CN. The first
                -- form named only www.unixodbc.org, which stopped answering on
                -- 2026-09-15 and failed nanodbc on both Linux legs of the full
                -- sweep.
                url    = {
                    GLOBAL = "https://github.com/lurcher/unixODBC/releases/download/v2.3.14/unixODBC-2.3.14.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/unixodbc/releases/download/2.3.14/unixODBC-2.3.14.tar.gz",
                },
                sha256 = "4e2814de3e01fc30b0b9f75e83bb5aba91ab0384ee951286504bb70205524771",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {
            "*/include",          -- sql.h, sqlext.h, sqltypes.h, sqlucode.h, odbcinst.h
            "*/libltdl",          -- <ltdl.h> and <libltdl/lt_system.h>
            "*/libltdl/libltdl",  -- lt__private.h and friends (build-internal)
            "mcpp_generated/include",
        },
        cflags = {
            "-D_GNU_SOURCE",
            -- libltdl wiring, see the header comment.
            "-DLTDL",
            "-DLTDLOPEN=libltdlc",
        },
        sources = {
            "*/DriverManager/*.c",
            "*/odbcinst/*.c",
            "*/ini/*.c",
            "*/log/*.c",
            "*/lst/*.c",
            "*/libltdl/ltdl.c",
            "*/libltdl/lt__alloc.c",
            "*/libltdl/lt_dlloader.c",
            "*/libltdl/lt_error.c",
            "*/libltdl/slist.c",
            "*/libltdl/loaders/preopen.c",
            "*/libltdl/loaders/dlopen.c",
            "mcpp_generated/ltdl_preload.c",
        },
        targets      = { ["odbc"] = { kind = "lib" } },
        deps         = { },
        generated_files = {
            ["mcpp_generated/ltdl_preload.c"] = [==[
#include <ltdl.h>
extern lt_dlvtable *dlopen_LTX_get_vtable (lt_user_data loader_data);
const lt_dlsymlist lt_libltdlc_LTX_preloaded_symbols[] = {
    { "libltdlc", (void *) 0 },
    { "dlopen.a", (void *) 0 },
    { "dlopen_LTX_get_vtable", (void *) &dlopen_LTX_get_vtable },
    { 0, (void *) 0 }
};
]==],
            ["mcpp_generated/include/unixodbc.h"] = [==[
/* unixodbc.h.  Generated from unixodbc.h.in by configure.  */
/* Preprocessor constants for unixODBC */

/* Define to 1 if `long long' is available */
#define HAVE_LONG_LONG 1

/* Define to 1 if the <pwd.h> header file is present */
#define HAVE_PWD_H 1

/* Define to 1 if the <sys/types.h> header file is present */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if the <unistd.h> header file is present */
#define HAVE_UNISTD_H 1

/* Define to the value of sizeof(long) */
#define SIZEOF_LONG_INT 8
]==],
            ["mcpp_generated/include/config.h"] = [==[
/* config.h.  Generated from config.h.in by configure.  */
/* config.h.in.  Generated from configure.ac by autoheader.  */

/* Encoding to use for CHAR */
#define ASCII_ENCODING "auto-search"

/* Install bindir */
#define BIN_PREFIX "/usr/local/bin"

/* Use a semaphore to allow ODBCConfig to display running counts */
/* #undef COLLECT_STATS */

/* Define to one of `_getb67', `GETB67', `getb67' for Cray-2 and Cray-YMP
   systems. This function is required for `alloca.c' support on those systems.
   */
/* #undef CRAY_STACKSEG_END */

/* Define to 1 if using `alloca.c'. */
/* #undef C_ALLOCA */

/* Enable versioned cursor library */
/* #undef DEFINE_CURSOR_LIB_VER */

/* Lib directory */
#define DEFLIB_PATH "/usr/local/lib"

/* Using perdriver iconv */
/* #undef ENABLE_DRIVER_ICONV */

/* Using ini cacheing */
#define ENABLE_INI_CACHING /**/

/* Install exec_prefix */
#define EXEC_PREFIX "/usr/local"

/* Disable the precise but slow checking of the validity of handles */
/* #undef FAST_HANDLE_VALIDATE */

/* Define to 1 if you have `alloca', as a function or macro. */
#define HAVE_ALLOCA 1

/* Define to 1 if you have <alloca.h> and it should be used (not on Ultrix).
   */
#define HAVE_ALLOCA_H 1

/* Define to 1 if you have the `argz_add' function. */
#define HAVE_ARGZ_ADD 1

/* Define to 1 if you have the `argz_append' function. */
#define HAVE_ARGZ_APPEND 1

/* Define to 1 if you have the `argz_count' function. */
#define HAVE_ARGZ_COUNT 1

/* Define to 1 if you have the `argz_create_sep' function. */
#define HAVE_ARGZ_CREATE_SEP 1

/* Define to 1 if you have the <argz.h> header file. */
#define HAVE_ARGZ_H 1

/* Define to 1 if you have the `argz_insert' function. */
#define HAVE_ARGZ_INSERT 1

/* Define to 1 if you have the `argz_next' function. */
#define HAVE_ARGZ_NEXT 1

/* Define to 1 if you have the `argz_stringify' function. */
#define HAVE_ARGZ_STRINGIFY 1

/* Define to 1 if you have the `atoll' function. */
#define HAVE_ATOLL 1

/* Define to 1 if you have the `clock_gettime' function. */
#define HAVE_CLOCK_GETTIME 1

/* Define to 1 if you have the `closedir' function. */
#define HAVE_CLOSEDIR 1

/* Define to 1 if you have the <crypt.h> header file. */
#define HAVE_CRYPT_H 1

/* Define to 1 if you have the declaration of `cygwin_conv_path', and to 0 if
   you don't. */
/* #undef HAVE_DECL_CYGWIN_CONV_PATH */

/* Define to 1 if you have the <dirent.h> header file, and it defines `DIR'.
   */
#define HAVE_DIRENT_H 1

/* Define if you have the GNU dld library. */
/* #undef HAVE_DLD */

/* Define to 1 if you have the <dld.h> header file. */
/* #undef HAVE_DLD_H */

/* Define to 1 if you have the `dlerror' function. */
#define HAVE_DLERROR 1

/* Define to 1 if you have the <dlfcn.h> header file. */
#define HAVE_DLFCN_H 1

/* Define to 1 if you have the <dl.h> header file. */
/* #undef HAVE_DL_H */

/* Define to 1 if you don't have `vprintf' but do have `_doprnt.' */
/* #undef HAVE_DOPRNT */

/* Define if you have the _dyld_func_lookup function. */
/* #undef HAVE_DYLD */

/* Add editline support */
/* #undef HAVE_EDITLINE */

/* Define to 1 if you have the <editline/readline.h> header file. */
/* #undef HAVE_EDITLINE_READLINE_H */

/* Define to 1 if you have the `endpwent' function. */
#define HAVE_ENDPWENT 1

/* Define to 1 if the system has the type `error_t'. */
#define HAVE_ERROR_T 1

/* Define to 1 if you have the `fseeko' function. */
#define HAVE_FSEEKO 1

/* Define to 1 if you have the `ftime' function. */
#define HAVE_FTIME 1

/* Define to 1 if you have the `ftok' function. */
/* #undef HAVE_FTOK */

/* Define to 1 if you have the four-argument form of getpwuid_r(). */
/* #undef HAVE_FUNC_GETPWUID_R_4 */

/* Define to 1 if you have the five-argument form of getpwuid_r(). */
/* #undef HAVE_FUNC_GETPWUID_R_5 */

/* Define to 1 if you have the `getpid' function. */
#define HAVE_GETPID 1

/* Define to 1 if you have the `getpwuid' function. */
#define HAVE_GETPWUID 1

/* Define to 1 if you have some form of getpwuid_r(). */
/* #undef HAVE_GETPWUID_R */

/* Define to 1 if you have the `gettimeofday' function. */
#define HAVE_GETTIMEOFDAY 1

/* Define to 1 if you have the `getuid' function. */
#define HAVE_GETUID 1

/* Define if you have the iconv() function. */
#define HAVE_ICONV 1

/* Define to 1 if the system has the type `intptr_t'. */
#define HAVE_INTPTR_T 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Define if you have <langinfo.h> and nl_langinfo(CODESET). */
#define HAVE_LANGINFO_CODESET 1

/* Define to 1 if you have the <langinfo.h> header file. */
#define HAVE_LANGINFO_H 1

/* Add -lcrypt to lib list */
#define HAVE_LIBCRYPT /**/

/* Define if you have the libdl library or equivalent. */
#define HAVE_LIBDL 1

/* Define if libdlloader will be built on this platform */
#define HAVE_LIBDLLOADER 1

/* Use the -lpth thread library */
/* #undef HAVE_LIBPTH */

/* Use -lpthread threading lib */
#define HAVE_LIBPTHREAD 1

/* Use the -lthread threading lib */
/* #undef HAVE_LIBTHREAD */

/* Define to 1 if you have the <limits.h> header file. */
#define HAVE_LIMITS_H 1

/* Define to 1 if you have the <locale.h> header file. */
#define HAVE_LOCALE_H 1

/* Use rentrant version of localtime */
#define HAVE_LOCALTIME_R 1

/* Define if you have long long */
#define HAVE_LONG_LONG 1

/* Define this if a modern libltdl is already installed */
/* #undef HAVE_LTDL */

/* Define to 1 if you have the <mach-o/dyld.h> header file. */
/* #undef HAVE_MACH_O_DYLD_H */

/* Define to 1 if you have the <malloc.h> header file. */
#define HAVE_MALLOC_H 1

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define to 1 if you have the <msql.h> header file. */
/* #undef HAVE_MSQL_H */

/* Define to 1 if you have the <ndir.h> header file, and it defines `DIR'. */
/* #undef HAVE_NDIR_H */

/* Define to 1 if you have the `nl_langinfo' function. */
#define HAVE_NL_LANGINFO 1

/* Define to 1 if you have the `opendir' function. */
#define HAVE_OPENDIR 1

/* Define if libtool can extract symbol lists from object files. */
#define HAVE_PRELOADED_SYMBOLS 1

/* Define to 1 if the system has the type `ptrdiff_t'. */
#define HAVE_PTRDIFF_T 1

/* Define to 1 if you have the `putenv' function. */
#define HAVE_PUTENV 1

/* Define to 1 if you have the <pwd.h> header file. */
#define HAVE_PWD_H 1

/* Define to 1 if you have the `readdir' function. */
#define HAVE_READDIR 1

/* Add readline support */
/* #undef HAVE_READLINE */

/* Define to 1 if you have the <readline/history.h> header file. */
/* #undef HAVE_READLINE_HISTORY_H */

/* Use the scandir lib */
/* #undef HAVE_SCANDIR */

/* Define to 1 if you have the `semget' function. */
/* #undef HAVE_SEMGET */

/* Define to 1 if you have the `semop' function. */
/* #undef HAVE_SEMOP */

/* Define to 1 if you have the `setenv' function. */
#define HAVE_SETENV 1

/* Define to 1 if you have the `setlocale' function. */
#define HAVE_SETLOCALE 1

/* Define to 1 if you have the `setvbuf' function. */
#define HAVE_SETVBUF 1

/* Define if you have the shl_load function. */
/* #undef HAVE_SHL_LOAD */

/* Define to 1 if you have the `shmget' function. */
/* #undef HAVE_SHMGET */

/* Define to 1 if you have the `snprintf' function. */
#define HAVE_SNPRINTF 1

/* Define to 1 if you have the `socket' function. */
#define HAVE_SOCKET 1

/* Define to 1 if you have the <stdarg.h> header file. */
#define HAVE_STDARG_H 1

/* Define to 1 if you have the <stddef.h> header file. */
#define HAVE_STDDEF_H 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the `strcasecmp' function. */
#define HAVE_STRCASECMP 1

/* Define to 1 if you have the `strchr' function. */
#define HAVE_STRCHR 1

/* Define to 1 if you have the `strdup' function. */
#define HAVE_STRDUP 1

/* Define to 1 if you have the `stricmp' function. */
/* #undef HAVE_STRICMP */

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the `strlcat' function. */
#define HAVE_STRLCAT 1

/* Define to 1 if you have the `strlcpy' function. */
#define HAVE_STRLCPY 1

/* Define to 1 if you have the `strncasecmp' function. */
#define HAVE_STRNCASECMP 1

/* Define to 1 if you have the `strnicmp' function. */
/* #undef HAVE_STRNICMP */

/* Define to 1 if you have the `strstr' function. */
#define HAVE_STRSTR 1

/* Define to 1 if you have the `strtol' function. */
#define HAVE_STRTOL 1

/* Define to 1 if you have the `strtoll' function. */
#define HAVE_STRTOLL 1

/* Define to 1 if you have the <synch.h> header file. */
/* #undef HAVE_SYNCH_H */

/* Define to 1 if you have the <sys/dir.h> header file, and it defines `DIR'.
   */
/* #undef HAVE_SYS_DIR_H */

/* Define to 1 if you have the <sys/dl.h> header file. */
/* #undef HAVE_SYS_DL_H */

/* Define to 1 if you have the <sys/malloc.h> header file. */
/* #undef HAVE_SYS_MALLOC_H */

/* Define to 1 if you have the <sys/ndir.h> header file, and it defines `DIR'.
   */
/* #undef HAVE_SYS_NDIR_H */

/* Define to 1 if you have the <sys/sem.h> header file. */
#define HAVE_SYS_SEM_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/timeb.h> header file. */
#define HAVE_SYS_TIMEB_H 1

/* Define to 1 if you have the <sys/time.h> header file. */
#define HAVE_SYS_TIME_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the `time' function. */
#define HAVE_TIME 1

/* Define to 1 if you have the <time.h> header file. */
#define HAVE_TIME_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Define to 1 if you have the <varargs.h> header file. */
/* #undef HAVE_VARARGS_H */

/* Define to 1 if you have the `vprintf' function. */
#define HAVE_VPRINTF 1

/* Define to 1 if you have the `vsnprintf' function. */
#define HAVE_VSNPRINTF 1

/* This value is set to 1 to indicate that the system argz facility works */
#define HAVE_WORKING_ARGZ 1

/* Define as const if the declaration of iconv() needs const. */
#define ICONV_CONST 

/* Install includedir */
#define INCLUDE_PREFIX "/usr/local/include"

/* Lib directory */
#define LIB_PREFIX "/usr/local/lib"

/* Define if the OS needs help to load dependent libraries for dlopen(). */
/* #undef LTDL_DLOPEN_DEPLIBS */

/* Define to the system default library search path. */
#define LT_DLSEARCH_PATH "/lib:/usr/lib:/usr/lib/fdk-aac/:/usr/lib64/fdk-aac/:/usr/lib64/llvm21/lib64:/usr/lib64/pipewire-0.3/jack/"

/* The archive extension */
#define LT_LIBEXT "a"

/* The archive prefix */
#define LT_LIBPREFIX "lib"

/* Define to the extension used for runtime loadable modules, say, ".so". */
#define LT_MODULE_EXT ".so"

/* Define to the name of the environment variable that determines the run-time
   module search path. */
#define LT_MODULE_PATH_VAR "LD_LIBRARY_PATH"

/* Define to the sub-directory where libtool stores uninstalled libraries. */
#define LT_OBJDIR ".libs/"

/* Define to the shared library suffix, say, ".dylib". */
/* #undef LT_SHARED_EXT */

/* Define to the shared archive member specification, say "(shr.o)". */
/* #undef LT_SHARED_LIB_MEMBER */

/* ODBC driver search path */
/* #undef MODULEDIR */

/* Define if you need semundo union */
/* #undef NEED_SEMUNDO_UNION */

/* Define if dlsym() requires a leading underscore in symbol names. */
/* #undef NEED_USCORE */

/* Using OSX */
/* #undef OSXHEADER */

/* Name of package */
#define PACKAGE "unixODBC"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT "nick@unixodbc.org"

/* Define to the full name of this package. */
#define PACKAGE_NAME "unixODBC"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "unixODBC 2.3.14"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "unixODBC"

/* Define to the home page for this package. */
#define PACKAGE_URL ""

/* Define to the version of this package. */
#define PACKAGE_VERSION "2.3.14"

/* Platform is 64 bit */
#define PLATFORM64 /**/

/* Install prefix */
#define PREFIX "/usr/local"

/* Using QNX */
/* #undef QNX_LIBLTDL */

/* Shared lib extension */
#define SHLIBEXT ".so"

/* The size of `long', as computed by sizeof. */
#define SIZEOF_LONG 8

/* The size of `long int', as computed by sizeof. */
#define SIZEOF_LONG_INT 8

/* If using the C implementation of alloca, define if you know the
   direction of stack growth for your system; otherwise it will be
   automatically deduced at runtime.
	STACK_DIRECTION > 0 => grows toward higher addresses
	STACK_DIRECTION < 0 => grows toward lower addresses
	STACK_DIRECTION = 0 => direction of growth unknown */
/* #undef STACK_DIRECTION */

/* Filename to use for ftok */
#define STATS_FTOK_NAME "odbc.ini"

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* don't include unixODBC prefix in driver error messages */
#define STRICT_ODBC_ERROR /**/

/* System file path */
#define SYSTEM_FILE_PATH "/usr/local/etc"

/* Lib path */
#define SYSTEM_LIB_PATH "/usr/local/lib"

/* Define to 1 if you can safely include both <sys/time.h> and <time.h>. */
#define TIME_WITH_SYS_TIME 1

/* Define to 1 if your <sys/time.h> declares `struct tm'. */
/* #undef TM_IN_SYS_TIME */

/* Encoding to use for UNICODE */
#define UNICODE_ENCODING "auto-search"

/* Flag that we are not using another DM */
#define UNIXODBC /**/

/* We are building inside the unixODBC source tree */
#define UNIXODBC_SOURCE /**/

/* Version number of package */
#define VERSION "2.3.14"

/* Work with IBM drivers that use 32 bit handles on 64 bit platforms */
/* #undef WITH_HANDLE_REDIRECT */

/* Using shared env handle */
/* #undef WITH_SHARDENV */

/* Using utf8 ini encoding */
/* #undef WITH_UTF8_INI */

/* Define to 1 if `lex' declares `yytext' as a `char *' by default, not a
   `char[]'. */
/* #undef YYTEXT_POINTER */

/* Build flag for AIX */
/* #undef _ALL_SOURCE */

/* Enable large inode numbers on Mac OS X 10.5.  */
#ifndef _DARWIN_USE_64_BIT_INODE
# define _DARWIN_USE_64_BIT_INODE 1
#endif

/* Number of bits in a file offset, on hosts where this is settable. */
/* #undef _FILE_OFFSET_BITS */

/* Define to 1 to make fseeko visible on some hosts (e.g. glibc 2.2). */
/* #undef _LARGEFILE_SOURCE */

/* Define for large files, on AIX-style hosts. */
/* #undef _LARGE_FILES */

/* Build flag for AIX */
/* #undef _LONG_LONG */

/* Build flag for AIX */
/* #undef _THREAD_SAFE */

/* Define so that glibc/gnulib argp.h does not typedef error_t. */
/* #undef __error_t_defined */

/* Define to empty if `const' does not conform to ANSI C. */
/* #undef const */

/* Define to a type to use for 'error_t' if it is not otherwise available. */
/* #undef error_t */

/* Define to `int' if <sys/types.h> doesn't define. */
/* #undef gid_t */

/* Define to the type of a signed integer type wide enough to hold a pointer,
   if such a type exists, and if the system does not define it. */
/* #undef intptr_t */

/* Define to `unsigned int' if <sys/types.h> does not define. */
/* #undef size_t */

/* Define to `int' if <sys/types.h> doesn't define. */
/* #undef uid_t */

/* ---- libltdl additions: macros from ltdl's own configure output that
   the top-level one does not define. Name clashes are excluded; ltdl's
   sources never read the clashing identification macros. ---- */
/* config.h.  Generated from config-h.in by configure.  */
/* config-h.in.  Generated from configure.ac by autoheader.  */

/* Define to 1 if you have the `argz_add' function. */

/* Define to 1 if you have the `argz_append' function. */

/* Define to 1 if you have the `argz_count' function. */

/* Define to 1 if you have the `argz_create_sep' function. */

/* Define to 1 if you have the <argz.h> header file. */

/* Define to 1 if you have the `argz_insert' function. */

/* Define to 1 if you have the `argz_next' function. */

/* Define to 1 if you have the `argz_stringify' function. */

/* Define to 1 if you have the `closedir' function. */

/* Define to 1 if you have the declaration of `cygwin_conv_path', and to 0 if
   you don't. */
/* #undef HAVE_DECL_CYGWIN_CONV_PATH */

/* Define to 1 if you have the <dirent.h> header file. */

/* Define if you have the GNU dld library. */
/* #undef HAVE_DLD */

/* Define to 1 if you have the <dld.h> header file. */
/* #undef HAVE_DLD_H */

/* Define to 1 if you have the `dlerror' function. */

/* Define to 1 if you have the <dlfcn.h> header file. */

/* Define to 1 if you have the <dl.h> header file. */
/* #undef HAVE_DL_H */

/* Define if you have the _dyld_func_lookup function. */
/* #undef HAVE_DYLD */

/* Define to 1 if the system has the type `error_t'. */

/* Define to 1 if you have the <inttypes.h> header file. */

/* Define if you have the libdl library or equivalent. */

/* Define if libdlloader will be built on this platform */

/* Define to 1 if you have the <mach-o/dyld.h> header file. */
/* #undef HAVE_MACH_O_DYLD_H */

/* Define to 1 if you have the <memory.h> header file. */

/* Define to 1 if you have the `opendir' function. */

/* Define if libtool can extract symbol lists from object files. */

/* Define to 1 if you have the `readdir' function. */

/* Define if you have the shl_load function. */
/* #undef HAVE_SHL_LOAD */

/* Define to 1 if you have the <stdint.h> header file. */

/* Define to 1 if you have the <stdlib.h> header file. */

/* Define to 1 if you have the <strings.h> header file. */

/* Define to 1 if you have the <string.h> header file. */

/* Define to 1 if you have the `strlcat' function. */

/* Define to 1 if you have the `strlcpy' function. */

/* Define to 1 if you have the <sys/dl.h> header file. */
/* #undef HAVE_SYS_DL_H */

/* Define to 1 if you have the <sys/stat.h> header file. */

/* Define to 1 if you have the <sys/types.h> header file. */

/* Define to 1 if you have the <unistd.h> header file. */

/* This value is set to 1 to indicate that the system argz facility works */

/* Define if the OS needs help to load dependent libraries for dlopen(). */
/* #undef LTDL_DLOPEN_DEPLIBS */

/* Define to the system default library search path. */

/* The archive extension */

/* The archive prefix */

/* Define to the extension used for runtime loadable modules, say, ".so". */

/* Define to the name of the environment variable that determines the run-time
   module search path. */

/* Define to the sub-directory where libtool stores uninstalled libraries. */

/* Define to the shared library suffix, say, ".dylib". */
/* #undef LT_SHARED_EXT */

/* Define to the shared archive member specification, say "(shr.o)". */
/* #undef LT_SHARED_LIB_MEMBER */

/* Define if dlsym() requires a leading underscore in symbol names. */
/* #undef NEED_USCORE */

/* Name of package */

/* Define to the address where bug reports for this package should be sent. */

/* Define to the full name of this package. */

/* Define to the full name and version of this package. */

/* Define to the one symbol short name of this package. */

/* Define to the home page for this package. */

/* Define to the version of this package. */

/* Define to 1 if you have the ANSI C header files. */

/* Version number of package */

/* Define so that glibc/gnulib argp.h does not typedef error_t. */
/* #undef __error_t_defined */

/* Define to a type to use for 'error_t' if it is not otherwise available. */
/* #undef error_t */
]==],
        },
    },
}
