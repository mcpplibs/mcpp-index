-- compat.sdl2 — SDL 2.32.10, built from source as a static library.
--
-- Cross-platform window, input and audio layer. Full-source direct build, the
-- `compat.ffmpeg` /
-- `compat.curl` shape: SDL guards every backend it did not select
-- (`src/video/windows/*.c` opens with `#if SDL_VIDEO_DRIVER_WINDOWS`, the
-- direct3d/psp/ps2 renderers likewise), so unselected files compile to EMPTY
-- translation units and the source list can be plain directory globs with the
-- configuration carried entirely by SDL_config.h.
--
-- THE CONFIG HEADER is the only genuinely awkward part, and it is awkward on
-- exactly one platform:
--
--   * windows / macosx — upstream CHECKS IN `include/SDL_config_windows.h` and
--     `include/SDL_config_macosx.h`, and `include/SDL_config.h` is a dispatcher
--     to them. Nothing to generate.
--   * linux — upstream's dispatcher falls through to `SDL_config_minimal.h`,
--     which builds an SDL that can do essentially nothing. This is the gap the
--     generated header below fills.
--
-- So `mcpp_generated/SDL_config.h` shadows upstream's dispatcher and
-- reproduces it for windows/macosx, while carrying CMake's generated Linux
-- configuration inline. X11 is switched on by hand at the end of that block:
-- the CMake probe ran on a host without system X11 development headers and
-- disabled it, but this index supplies X11 through the same packages
-- `compat.glfw` links.
--
-- SOURCE IS A REPACK, not the upstream tag archive. SDL's GitHub archive carries
-- two POSIX symlinks under `android-project-ant/`, and a tag archive containing
-- symlinks fails to extract on Windows — the package then "installs" with
-- nothing in it, publishes no include dirs, and every consumer fails with
-- `'SDL.h' file not found` while the package itself reports success. That is
-- exactly what CI showed before this change. `chriskohlhoff.asio` hit the same
-- wall and set the precedent: host a symlink-free repack on xlings-res
-- (GLOBAL) and mirror the identical bytes to mcpp-res (CN). Only the two
-- symlink entries are removed; everything else is the upstream content.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/` absorbs
-- the tarball's `SDL-release-2.32.10/` wrap layer.
--
-- ONE HEADER LINE IS BACKPORTED in install(). Under an MSVC-ABI clang,
-- `SDL_endian.h` defines `_m_prefetch` as a stand-in for clang's
-- `prfchwintrin.h`; clang 23 makes `_m_prefetch` a builtin, and every consumer
-- TU that includes SDL.h stops at "definition of builtin function
-- '_m_prefetch'" (measured on windows-x86_64 with llvm@23.1.3). Upstream's SDL2
-- branch guards the definition with `!_SDL_HAS_BUILTIN(_m_prefetch)` (commits
-- 9343246616 and 07c3b3fb7c), which no 2.32.x release carries yet. A shim cannot
-- reach it: SDL.h includes SDL_endian.h by a quoted include, found beside it.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "sdl2",
    description = "SDL2 — cross-platform window, input and audio layer",
    licenses    = {"Zlib"},
    repo        = "https://github.com/libsdl-org/SDL",
    type        = "package",

    xpm = {
        linux = {
            ["2.32.10"] = {
                url = {
                    GLOBAL = "https://github.com/xlings-res/sdl2/releases/download/2.32.10/sdl2-2.32.10-nosymlinks.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sdl2/releases/download/2.32.10-nosymlinks/sdl2-2.32.10-nosymlinks.tar.gz",
                },
                sha256 = "8823b81a7ecec5c1785dfd3c1fdb6260899d4eaa07574365dd4b8da9e2830385",
                -- 1: SDL_endian.h defines `_m_prefetch` only where the compiler has no builtin of it (install()).
                revision = 1,
            },
        },
        macosx = {
            ["2.32.10"] = {
                url = {
                    GLOBAL = "https://github.com/xlings-res/sdl2/releases/download/2.32.10/sdl2-2.32.10-nosymlinks.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sdl2/releases/download/2.32.10-nosymlinks/sdl2-2.32.10-nosymlinks.tar.gz",
                },
                sha256 = "8823b81a7ecec5c1785dfd3c1fdb6260899d4eaa07574365dd4b8da9e2830385",
                -- 1: SDL_endian.h defines `_m_prefetch` only where the compiler has no builtin of it (install()).
                revision = 1,
            },
        },
        windows = {
            ["2.32.10"] = {
                url = {
                    GLOBAL = "https://github.com/xlings-res/sdl2/releases/download/2.32.10/sdl2-2.32.10-nosymlinks.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sdl2/releases/download/2.32.10-nosymlinks/sdl2-2.32.10-nosymlinks.tar.gz",
                },
                sha256 = "8823b81a7ecec5c1785dfd3c1fdb6260899d4eaa07574365dd4b8da9e2830385",
                -- 1: SDL_endian.h defines `_m_prefetch` only where the compiler has no builtin of it (install()).
                revision = 1,
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c99",

        -- mcpp_generated FIRST so our SDL_config.h shadows upstream's
        -- dispatcher; */include carries the public SDL headers and the
        -- per-platform configs our header defers to.
        -- */src/video/khronos carries SDL's vendored EGL and GLES headers,
        -- which SDL_VIDEO_OPENGL_EGL / _ES2 reach for.
        include_dirs = { "mcpp_generated", "*/include", "*/src", "*/src/video/khronos" },

        -- Backend-independent core plus every backend directory. SDL's own
        -- guards decide what survives the preprocessor, which is what lets one
        -- list serve all three platforms.
        sources = {
            "*/src/*.c",
            "*/src/atomic/*.c",
            "*/src/audio/*.c",
            "*/src/audio/disk/*.c",
            "*/src/audio/dummy/*.c",
            "*/src/cpuinfo/*.c",
            "*/src/dynapi/*.c",
            "*/src/events/*.c",
            "*/src/file/*.c",
            "*/src/haptic/*.c",
            -- Only the top level: SDL_hidapi.c is SDL's own wrapper and is
            -- always needed (SDL_hid_* is public API). The subdirectories under
            -- it are the vendored hidapi backends, which SDL_HIDAPI gates and
            -- which this build does not use.
            "*/src/hidapi/*.c",
            "*/src/joystick/*.c",
            -- SDL_JOYSTICK_HIDAPI is off in the generated Linux config but ON in
            -- upstream's checked-in macosx/windows ones, and SDL_gamecontroller.c
            -- calls into it unconditionally there
            -- (HIDAPI_GetGameControllerTypeFromGUID). Guarded internally, so it
            -- costs nothing where the config disables it.
            "*/src/joystick/hidapi/*.c",
            "*/src/joystick/steam/*.c",
            "*/src/joystick/virtual/*.c",
            "*/src/libm/*.c",
            "*/src/locale/*.c",
            "*/src/misc/*.c",
            "*/src/power/*.c",
            "*/src/render/*.c",
            "*/src/render/direct3d/*.c",
            "*/src/render/direct3d11/*.c",
            "*/src/render/direct3d12/*.c",
            "*/src/render/opengl/*.c",
            "*/src/render/opengles/*.c",
            "*/src/render/opengles2/*.c",
            "*/src/render/ps2/*.c",
            "*/src/render/psp/*.c",
            "*/src/render/software/*.c",
            "*/src/render/vitagxm/*.c",
            "*/src/sensor/*.c",
            "*/src/sensor/dummy/*.c",
            "*/src/stdlib/*.c",
            "*/src/thread/*.c",
            "*/src/timer/*.c",
            "*/src/video/*.c",
            "*/src/video/dummy/*.c",
            "*/src/video/offscreen/*.c",
            "*/src/video/yuv2rgb/*.c",
        },

        targets = { ["sdl2"] = { kind = "lib" } },
        deps    = {},

        generated_files = {
            ["mcpp_generated/SDL_config.h"] = [==[
/* SDL_config.h — supplied by mcpp-index.
 *
 * Only LINUX needs this. Upstream ships ready-made configs for the other two
 * platforms (include/SDL_config_windows.h, include/SDL_config_macosx.h) and its
 * own include/SDL_config.h is just a dispatcher to them; the branches below
 * reproduce that dispatch. Linux is the gap — upstream's dispatcher falls
 * through to SDL_config_minimal.h there, which builds an SDL that can do
 * essentially nothing.
 *
 * The Linux body is CMake's generated output against this index's gcc
 * toolchain, verbatim, plus the X11 block at the end. */
#ifndef SDL_config_h_
#define SDL_config_h_

#include "SDL_platform.h"

#if defined(__WIN32__)
/* SDL_config_windows.h only turns HAVE_LIBC on for _MSC_VER, and this index
 * builds with clang++ rather than clang-cl. Left off, SDL compiles its own
 * memcpy/memset in src/stdlib/SDL_mslibc.c and the link fails with
 * "memcpy already defined in SDL_mslibc.o" against libvcruntime. */
#define HAVE_LIBC 1
#include "SDL_config_windows.h"
#elif defined(__MACOSX__)
#include "SDL_config_macosx.h"
/* Upstream's macOS config also enables the X11 video driver, dynamically loaded
 * from /opt/X11. That would make src/video/x11 a compile dependency on Apple —
 * X11 headers and all — for a driver nobody reaches on a Mac with Cocoa
 * present. Turned off here; Cocoa and the dummy driver remain. */
#undef SDL_VIDEO_DRIVER_X11
#undef SDL_VIDEO_DRIVER_X11_DYNAMIC
#undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XEXT
#undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XINPUT2
#undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XRANDR
#undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XSS
#undef SDL_VIDEO_DRIVER_X11_XDBE
#undef SDL_VIDEO_DRIVER_X11_XRANDR
#undef SDL_VIDEO_DRIVER_X11_XSCRNSAVER
#undef SDL_VIDEO_DRIVER_X11_XSHAPE
#undef SDL_VIDEO_DRIVER_X11_HAS_XKBKEYCODETOKEYSYM
#undef SDL_VIDEO_DRIVER_X11_XINPUT2
#undef SDL_VIDEO_DRIVER_X11_SUPPORTS_GENERIC_EVENTS
#elif defined(__linux__)


/**
 *  \file SDL_config.h.in
 *
 *  This is a set of defines to configure the SDL features
 */

/* General platform specific identifiers */
#include "SDL_platform.h"

/* C language features */
/* #undef const */
/* #undef inline */
/* #undef volatile */

/* C datatypes */
/* Define SIZEOF_VOIDP for 64/32 architectures */
#if defined(__LP64__) || defined(_LP64) || defined(_WIN64)
#define SIZEOF_VOIDP 8
#else
#define SIZEOF_VOIDP 4
#endif

#define HAVE_GCC_ATOMICS 1
/* #undef HAVE_GCC_SYNC_LOCK_TEST_AND_SET */

/* Comment this if you want to build without any C library requirements */
#define HAVE_LIBC 1
#ifdef HAVE_LIBC

/* Useful headers */
#define STDC_HEADERS 1
#define HAVE_ALLOCA_H 1
#define HAVE_CTYPE_H 1
#define HAVE_FLOAT_H 1
#define HAVE_ICONV_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_LIMITS_H 1
#define HAVE_MALLOC_H 1
#define HAVE_MATH_H 1
#define HAVE_MEMORY_H 1
#define HAVE_SIGNAL_H 1
#define HAVE_STDARG_H 1
#define HAVE_STDDEF_H 1
#define HAVE_STDINT_H 1
#define HAVE_STDIO_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRINGS_H 1
#define HAVE_STRING_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_WCHAR_H 1
#define HAVE_LINUX_INPUT_H 1
/* #undef HAVE_PTHREAD_NP_H */
/* #undef HAVE_LIBUNWIND_H */

/* C library functions */
#define HAVE_DLOPEN 1
#define HAVE_MALLOC 1
#define HAVE_CALLOC 1
#define HAVE_REALLOC 1
#define HAVE_FREE 1
#define HAVE_ALLOCA 1
#ifndef __WIN32__ /* Don't use C runtime versions of these on Windows */
#define HAVE_GETENV 1
#define HAVE_SETENV 1
#define HAVE_PUTENV 1
#define HAVE_UNSETENV 1
#endif
#define HAVE_QSORT 1
#define HAVE_BSEARCH 1
#define HAVE_ABS 1
#define HAVE_BCOPY 1
#define HAVE_MEMSET 1
#define HAVE_MEMCPY 1
#define HAVE_MEMMOVE 1
#define HAVE_MEMCMP 1
#define HAVE_WCSLEN 1
#define HAVE_WCSLCPY 1
#define HAVE_WCSLCAT 1
/* #undef HAVE__WCSDUP */
#define HAVE_WCSDUP 1
#define HAVE_WCSSTR 1
#define HAVE_WCSCMP 1
#define HAVE_WCSNCMP 1
#define HAVE_WCSCASECMP 1
/* #undef HAVE__WCSICMP */
#define HAVE_WCSNCASECMP 1
/* #undef HAVE__WCSNICMP */
#define HAVE_STRLEN 1
#define HAVE_STRLCPY 1
#define HAVE_STRLCAT 1
/* #undef HAVE__STRREV */
/* #undef HAVE__STRUPR */
/* #undef HAVE__STRLWR */
#define HAVE_INDEX 1
#define HAVE_RINDEX 1
#define HAVE_STRCHR 1
#define HAVE_STRRCHR 1
#define HAVE_STRSTR 1
#define HAVE_STRTOK_R 1
/* #undef HAVE_ITOA */
/* #undef HAVE__LTOA */
/* #undef HAVE__UITOA */
/* #undef HAVE__ULTOA */
#define HAVE_STRTOL 1
#define HAVE_STRTOUL 1
/* #undef HAVE__I64TOA */
/* #undef HAVE__UI64TOA */
#define HAVE_STRTOLL 1
#define HAVE_STRTOULL 1
#define HAVE_STRTOD 1
#define HAVE_ATOI 1
#define HAVE_ATOF 1
#define HAVE_STRCMP 1
#define HAVE_STRNCMP 1
/* #undef HAVE__STRICMP */
#define HAVE_STRCASECMP 1
/* #undef HAVE__STRNICMP */
#define HAVE_STRNCASECMP 1
#define HAVE_STRCASESTR 1
#define HAVE_SSCANF 1
#define HAVE_VSSCANF 1
#define HAVE_VSNPRINTF 1
#define HAVE_M_PI 1
#define HAVE_ACOS 1
#define HAVE_ACOSF 1
#define HAVE_ASIN 1
#define HAVE_ASINF 1
#define HAVE_ATAN 1
#define HAVE_ATANF 1
#define HAVE_ATAN2 1
#define HAVE_ATAN2F 1
#define HAVE_CEIL 1
#define HAVE_CEILF 1
#define HAVE_COPYSIGN 1
#define HAVE_COPYSIGNF 1
#define HAVE_COS 1
#define HAVE_COSF 1
#define HAVE_EXP 1
#define HAVE_EXPF 1
#define HAVE_FABS 1
#define HAVE_FABSF 1
#define HAVE_FLOOR 1
#define HAVE_FLOORF 1
#define HAVE_FMOD 1
#define HAVE_FMODF 1
#define HAVE_LOG 1
#define HAVE_LOGF 1
#define HAVE_LOG10 1
#define HAVE_LOG10F 1
#define HAVE_LROUND 1
#define HAVE_LROUNDF 1
#define HAVE_POW 1
#define HAVE_POWF 1
#define HAVE_ROUND 1
#define HAVE_ROUNDF 1
#define HAVE_SCALBN 1
#define HAVE_SCALBNF 1
#define HAVE_SIN 1
#define HAVE_SINF 1
#define HAVE_SQRT 1
#define HAVE_SQRTF 1
#define HAVE_TAN 1
#define HAVE_TANF 1
#define HAVE_TRUNC 1
#define HAVE_TRUNCF 1
#define HAVE_FOPEN64 1
#define HAVE_FSEEKO 1
#define HAVE_FSEEKO64 1
#define HAVE_MEMFD_CREATE 1
#define HAVE_POSIX_FALLOCATE 1
#define HAVE_SIGACTION 1
#define HAVE_SIGTIMEDWAIT 1
#define HAVE_SA_SIGACTION 1
#define HAVE_SETJMP 1
#define HAVE_NANOSLEEP 1
#define HAVE_SYSCONF 1
/* #undef HAVE_SYSCTLBYNAME */
#define HAVE_CLOCK_GETTIME 1
/* #undef HAVE_GETPAGESIZE */
#define HAVE_MPROTECT 1
#define HAVE_ICONV 1
/* #undef SDL_USE_LIBICONV */
#define HAVE_PTHREAD_SETNAME_NP 1
/* #undef HAVE_PTHREAD_SET_NAME_NP */
#define HAVE_SEM_TIMEDWAIT 1
#define HAVE_GETAUXVAL 1
/* #undef HAVE_ELF_AUX_INFO */
#define HAVE_POLL 1
#define HAVE__EXIT 1

#else
#define HAVE_STDARG_H 1
#define HAVE_STDDEF_H 1
#define HAVE_STDINT_H 1
#define HAVE_FLOAT_H 1
#endif /* HAVE_LIBC */

/* #undef HAVE_ALTIVEC_H */
/* #undef HAVE_DBUS_DBUS_H */
/* #undef HAVE_FCITX */
/* #undef HAVE_IBUS_IBUS_H */
#define HAVE_SYS_INOTIFY_H 1
#define HAVE_INOTIFY_INIT 1
#define HAVE_INOTIFY_INIT1 1
#define HAVE_INOTIFY 1
/* #undef HAVE_LIBUSB */
#define HAVE_O_CLOEXEC 1

/* Apple platforms might be building universal binaries, where Intel builds
   can use immintrin.h but other architectures can't. */
#ifdef __APPLE__
#  if defined(__has_include) && (defined(__i386__) || defined(__x86_64))
#    if __has_include(<immintrin.h>)
#       define HAVE_IMMINTRIN_H 1
#    endif
#  endif
#else  /* non-Apple platforms can use the normal CMake check for this. */
#define HAVE_IMMINTRIN_H 1
#endif

/* libudev is deliberately OFF: it is a host system library this index does not
 * package, and SDL only uses it to enumerate input devices. Without it SDL
 * falls back to scanning /dev/input directly, which is the same path it takes
 * on any udev-less system. Leaving the CMake probe's value in would make
 * src/joystick/linux and src/haptic/linux fail on <libudev.h>. */
/* #undef HAVE_LIBUDEV_H */
/* #undef HAVE_LIBSAMPLERATE_H */
/* #undef HAVE_LIBDECOR_H */

/* #undef HAVE_D3D_H */
/* #undef HAVE_D3D11_H */
/* #undef HAVE_D3D12_H */
/* #undef HAVE_DDRAW_H */
/* #undef HAVE_DSOUND_H */
/* #undef HAVE_DINPUT_H */
/* #undef HAVE_XINPUT_H */
/* #undef HAVE_WINDOWS_GAMING_INPUT_H */
/* #undef HAVE_DXGI_H */

/* #undef HAVE_MMDEVICEAPI_H */
/* #undef HAVE_AUDIOCLIENT_H */
/* #undef HAVE_TPCSHRD_H */
/* #undef HAVE_SENSORSAPI_H */
/* #undef HAVE_ROAPI_H */
/* #undef HAVE_SHELLSCALINGAPI_H */

/* #undef USE_POSIX_SPAWN */

/* SDL internal assertion support */
#if 0
/* #undef SDL_DEFAULT_ASSERT_LEVEL */
#endif

/* Allow disabling of core subsystems */
/* #undef SDL_ATOMIC_DISABLED */
/* #undef SDL_AUDIO_DISABLED */
/* #undef SDL_CPUINFO_DISABLED */
/* #undef SDL_EVENTS_DISABLED */
/* #undef SDL_FILE_DISABLED */
/* #undef SDL_JOYSTICK_DISABLED */
/* #undef SDL_HAPTIC_DISABLED */
#define SDL_HIDAPI_DISABLED 1
/* #undef SDL_SENSOR_DISABLED */
/* #undef SDL_LOADSO_DISABLED */
/* #undef SDL_RENDER_DISABLED */
/* #undef SDL_THREADS_DISABLED */
/* #undef SDL_TIMERS_DISABLED */
/* #undef SDL_VIDEO_DISABLED */
/* #undef SDL_POWER_DISABLED */
/* #undef SDL_FILESYSTEM_DISABLED */
/* #undef SDL_LOCALE_DISABLED */
/* #undef SDL_MISC_DISABLED */

/* Enable various audio drivers */
/* #undef SDL_AUDIO_DRIVER_ALSA */
/* #undef SDL_AUDIO_DRIVER_ALSA_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_ANDROID */
/* #undef SDL_AUDIO_DRIVER_OPENSLES */
/* #undef SDL_AUDIO_DRIVER_AAUDIO */
/* #undef SDL_AUDIO_DRIVER_ARTS */
/* #undef SDL_AUDIO_DRIVER_ARTS_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_COREAUDIO */
#define SDL_AUDIO_DRIVER_DISK 1
/* #undef SDL_AUDIO_DRIVER_DSOUND */
#define SDL_AUDIO_DRIVER_DUMMY 1
/* #undef SDL_AUDIO_DRIVER_EMSCRIPTEN */
/* #undef SDL_AUDIO_DRIVER_ESD */
/* #undef SDL_AUDIO_DRIVER_ESD_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_FUSIONSOUND */
/* #undef SDL_AUDIO_DRIVER_FUSIONSOUND_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_HAIKU */
/* #undef SDL_AUDIO_DRIVER_JACK */
/* #undef SDL_AUDIO_DRIVER_JACK_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_NAS */
/* #undef SDL_AUDIO_DRIVER_NAS_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_NETBSD */
/* #undef SDL_AUDIO_DRIVER_OSS */
/* #undef SDL_AUDIO_DRIVER_PAUDIO */
/* #undef SDL_AUDIO_DRIVER_PIPEWIRE */
/* #undef SDL_AUDIO_DRIVER_PIPEWIRE_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_PULSEAUDIO */
/* #undef SDL_AUDIO_DRIVER_PULSEAUDIO_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_QSA */
/* #undef SDL_AUDIO_DRIVER_SNDIO */
/* #undef SDL_AUDIO_DRIVER_SNDIO_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_SUNAUDIO */
/* #undef SDL_AUDIO_DRIVER_WASAPI */
/* #undef SDL_AUDIO_DRIVER_WINMM */
/* #undef SDL_AUDIO_DRIVER_OS2 */
/* #undef SDL_AUDIO_DRIVER_VITA */
/* #undef SDL_AUDIO_DRIVER_PSP */
/* #undef SDL_AUDIO_DRIVER_PS2 */
/* #undef SDL_AUDIO_DRIVER_N3DS */

/* Enable various input drivers */
#define SDL_INPUT_LINUXEV 1
#define SDL_INPUT_LINUXKD 1
/* #undef SDL_INPUT_FBSDKBIO */
/* #undef SDL_INPUT_WSCONS */
/* #undef SDL_JOYSTICK_ANDROID */
/* #undef SDL_JOYSTICK_HAIKU */
/* #undef SDL_JOYSTICK_WGI */
/* #undef SDL_JOYSTICK_DINPUT */
/* #undef SDL_JOYSTICK_XINPUT */
/* #undef SDL_JOYSTICK_DUMMY */
/* #undef SDL_JOYSTICK_IOKIT */
/* #undef SDL_JOYSTICK_MFI */
#define SDL_JOYSTICK_LINUX 1
/* #undef SDL_JOYSTICK_OS2 */
/* #undef SDL_JOYSTICK_USBHID */
/* #undef SDL_HAVE_MACHINE_JOYSTICK_H */
/* #undef SDL_JOYSTICK_HIDAPI */
/* #undef SDL_JOYSTICK_RAWINPUT */
/* #undef SDL_JOYSTICK_EMSCRIPTEN */
/* #undef SDL_JOYSTICK_VIRTUAL */
/* #undef SDL_JOYSTICK_VITA */
/* #undef SDL_JOYSTICK_PSP */
/* #undef SDL_JOYSTICK_PS2 */
/* #undef SDL_JOYSTICK_N3DS */
/* #undef SDL_HAPTIC_DUMMY */
#define SDL_HAPTIC_LINUX 1
/* #undef SDL_HAPTIC_IOKIT */
/* #undef SDL_HAPTIC_DINPUT */
/* #undef SDL_HAPTIC_XINPUT */
/* #undef SDL_HAPTIC_ANDROID */
/* #undef SDL_LIBUSB_DYNAMIC */
/* #undef SDL_UDEV_DYNAMIC */

/* Enable various sensor drivers */
/* #undef SDL_SENSOR_ANDROID */
/* #undef SDL_SENSOR_COREMOTION */
/* #undef SDL_SENSOR_WINDOWS */
#define SDL_SENSOR_DUMMY 1
/* #undef SDL_SENSOR_VITA */
/* #undef SDL_SENSOR_N3DS */

/* Enable various shared object loading systems */
#define SDL_LOADSO_DLOPEN 1
/* #undef SDL_LOADSO_DUMMY */
/* #undef SDL_LOADSO_LDG */
/* #undef SDL_LOADSO_WINDOWS */
/* #undef SDL_LOADSO_OS2 */

/* Enable various threading systems */
/* #undef SDL_THREAD_GENERIC_COND_SUFFIX */
#define SDL_THREAD_PTHREAD 1
#define SDL_THREAD_PTHREAD_RECURSIVE_MUTEX 1
/* #undef SDL_THREAD_PTHREAD_RECURSIVE_MUTEX_NP */
/* #undef SDL_THREAD_WINDOWS */
/* #undef SDL_THREAD_OS2 */
/* #undef SDL_THREAD_VITA */
/* #undef SDL_THREAD_PSP */
/* #undef SDL_THREAD_PS2 */
/* #undef SDL_THREAD_N3DS */

/* Enable various timer systems */
/* #undef SDL_TIMER_HAIKU */
/* #undef SDL_TIMER_DUMMY */
#define SDL_TIMER_UNIX 1
/* #undef SDL_TIMER_WINDOWS */
/* #undef SDL_TIMER_OS2 */
/* #undef SDL_TIMER_VITA */
/* #undef SDL_TIMER_PSP */
/* #undef SDL_TIMER_PS2 */
/* #undef SDL_TIMER_N3DS */

/* Enable various video drivers */
/* #undef SDL_VIDEO_DRIVER_ANDROID */
/* #undef SDL_VIDEO_DRIVER_EMSCRIPTEN */
/* #undef SDL_VIDEO_DRIVER_HAIKU */
/* #undef SDL_VIDEO_DRIVER_COCOA */
/* #undef SDL_VIDEO_DRIVER_UIKIT */
/* #undef SDL_VIDEO_DRIVER_DIRECTFB */
/* #undef SDL_VIDEO_DRIVER_DIRECTFB_DYNAMIC */
#define SDL_VIDEO_DRIVER_DUMMY 1
#define SDL_VIDEO_DRIVER_OFFSCREEN 1
/* #undef SDL_VIDEO_DRIVER_WINDOWS */
/* #undef SDL_VIDEO_DRIVER_WINRT */
/* #undef SDL_VIDEO_DRIVER_WAYLAND */
/* #undef SDL_VIDEO_DRIVER_RPI */
/* #undef SDL_VIDEO_DRIVER_VIVANTE */
/* #undef SDL_VIDEO_DRIVER_VIVANTE_VDK */
/* #undef SDL_VIDEO_DRIVER_OS2 */
/* #undef SDL_VIDEO_DRIVER_QNX */
/* #undef SDL_VIDEO_DRIVER_RISCOS */
/* #undef SDL_VIDEO_DRIVER_PSP */
/* #undef SDL_VIDEO_DRIVER_PS2 */

/* #undef SDL_VIDEO_DRIVER_KMSDRM */
/* #undef SDL_VIDEO_DRIVER_KMSDRM_DYNAMIC */
/* #undef SDL_VIDEO_DRIVER_KMSDRM_DYNAMIC_GBM */

/* #undef SDL_VIDEO_DRIVER_WAYLAND_QT_TOUCH */
/* #undef SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC */
/* #undef SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_EGL */
/* #undef SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_CURSOR */
/* #undef SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_XKBCOMMON */
/* #undef SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_LIBDECOR */

/* #undef SDL_VIDEO_DRIVER_X11 */
/* #undef SDL_VIDEO_DRIVER_X11_DYNAMIC */
/* #undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XEXT */
/* #undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XCURSOR */
/* #undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XINPUT2 */
/* #undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XFIXES */
/* #undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XRANDR */
/* #undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XSS */
/* #undef SDL_VIDEO_DRIVER_X11_XCURSOR */
/* #undef SDL_VIDEO_DRIVER_X11_XDBE */
/* #undef SDL_VIDEO_DRIVER_X11_XINPUT2 */
/* #undef SDL_VIDEO_DRIVER_X11_XINPUT2_SUPPORTS_MULTITOUCH */
/* #undef SDL_VIDEO_DRIVER_X11_XFIXES */
/* #undef SDL_VIDEO_DRIVER_X11_XRANDR */
/* #undef SDL_VIDEO_DRIVER_X11_XSCRNSAVER */
/* #undef SDL_VIDEO_DRIVER_X11_XSHAPE */
/* #undef SDL_VIDEO_DRIVER_X11_SUPPORTS_GENERIC_EVENTS */
/* #undef SDL_VIDEO_DRIVER_X11_HAS_XKBKEYCODETOKEYSYM */
/* #undef SDL_VIDEO_DRIVER_VITA */
/* #undef SDL_VIDEO_DRIVER_N3DS */

/* #undef SDL_VIDEO_RENDER_D3D */
/* #undef SDL_VIDEO_RENDER_D3D11 */
/* #undef SDL_VIDEO_RENDER_D3D12 */
#define SDL_VIDEO_RENDER_OGL 1
#define SDL_VIDEO_RENDER_OGL_ES 1
#define SDL_VIDEO_RENDER_OGL_ES2 1
/* #undef SDL_VIDEO_RENDER_DIRECTFB */
/* #undef SDL_VIDEO_RENDER_METAL */
/* #undef SDL_VIDEO_RENDER_VITA_GXM */
/* #undef SDL_VIDEO_RENDER_PS2 */
/* #undef SDL_VIDEO_RENDER_PSP */

/* Enable OpenGL support */
#define SDL_VIDEO_OPENGL 1
#define SDL_VIDEO_OPENGL_ES 1
#define SDL_VIDEO_OPENGL_ES2 1
/* #undef SDL_VIDEO_OPENGL_BGL */
/* #undef SDL_VIDEO_OPENGL_CGL */
#define SDL_VIDEO_OPENGL_GLX 1
/* #undef SDL_VIDEO_OPENGL_WGL */
#define SDL_VIDEO_OPENGL_EGL 1
/* #undef SDL_VIDEO_OPENGL_OSMESA */
/* #undef SDL_VIDEO_OPENGL_OSMESA_DYNAMIC */

/* Enable Vulkan support */
#define SDL_VIDEO_VULKAN 1

/* Enable Metal support */
/* #undef SDL_VIDEO_METAL */

/* Enable system power support */
/* #undef SDL_POWER_ANDROID */
#define SDL_POWER_LINUX 1
/* #undef SDL_POWER_WINDOWS */
/* #undef SDL_POWER_WINRT */
/* #undef SDL_POWER_MACOSX */
/* #undef SDL_POWER_UIKIT */
/* #undef SDL_POWER_HAIKU */
/* #undef SDL_POWER_EMSCRIPTEN */
/* #undef SDL_POWER_HARDWIRED */
/* #undef SDL_POWER_VITA */
/* #undef SDL_POWER_PSP */
/* #undef SDL_POWER_N3DS */

/* Enable system filesystem support */
/* #undef SDL_FILESYSTEM_ANDROID */
/* #undef SDL_FILESYSTEM_HAIKU */
/* #undef SDL_FILESYSTEM_COCOA */
/* #undef SDL_FILESYSTEM_DUMMY */
/* #undef SDL_FILESYSTEM_RISCOS */
#define SDL_FILESYSTEM_UNIX 1
/* #undef SDL_FILESYSTEM_WINDOWS */
/* #undef SDL_FILESYSTEM_EMSCRIPTEN */
/* #undef SDL_FILESYSTEM_OS2 */
/* #undef SDL_FILESYSTEM_VITA */
/* #undef SDL_FILESYSTEM_PSP */
/* #undef SDL_FILESYSTEM_PS2 */
/* #undef SDL_FILESYSTEM_N3DS */

/* Enable misc subsystem */
/* #undef SDL_MISC_DUMMY */

/* Enable locale subsystem */
/* #undef SDL_LOCALE_DUMMY */

/* Enable assembly routines */
/* #undef SDL_ALTIVEC_BLITTERS */
/* #undef SDL_ARM_SIMD_BLITTERS */
/* #undef SDL_ARM_NEON_BLITTERS */

/* Whether SDL_DYNAMIC_API needs dlopen */
#define DYNAPI_NEEDS_DLOPEN 1

/* Enable dynamic libsamplerate support */
/* #undef SDL_LIBSAMPLERATE_DYNAMIC */

/* Enable ime support */
/* #undef SDL_USE_IME */

/* Platform specific definitions */
/* #undef SDL_IPHONE_KEYBOARD */
/* #undef SDL_IPHONE_LAUNCHSCREEN */

/* #undef SDL_VIDEO_VITA_PIB */
/* #undef SDL_VIDEO_VITA_PVR */
/* #undef SDL_VIDEO_VITA_PVR_OGL */

/* #undef SDL_HAVE_LIBDECOR_GET_MIN_MAX */

#if !defined(HAVE_STDINT_H) && !defined(_STDINT_H_)
/* Most everything except Visual Studio 2008 and earlier has stdint.h now */
#if defined(_MSC_VER) && (_MSC_VER < 1600)
typedef signed __int8 int8_t;
typedef unsigned __int8 uint8_t;
typedef signed __int16 int16_t;
typedef unsigned __int16 uint16_t;
typedef signed __int32 int32_t;
typedef unsigned __int32 uint32_t;
typedef signed __int64 int64_t;
typedef unsigned __int64 uint64_t;
#ifndef _UINTPTR_T_DEFINED
#ifdef  _WIN64
typedef unsigned __int64 uintptr_t;
#else
typedef unsigned int uintptr_t;
#endif
#define _UINTPTR_T_DEFINED
#endif
#endif /* Visual Studio 2008 */
#endif /* !_STDINT_H_ && !HAVE_STDINT_H */
/* ── X11 video, enabled for mcpp-index ───────────────────────────────────────
 * The CMake probe that produced this file ran on a host without system X11
 * development headers, so it disabled X11 and left only the dummy/offscreen
 * drivers. This index does supply X11 — the same set compat.glfw links — so the
 * driver is switched on here explicitly.
 *
 * NOT dynamic: SDL_VIDEO_DRIVER_X11_DYNAMIC would make SDL dlopen libX11.so at
 * runtime, but compat.x11 is a static library, so the symbols must be linked.
 *
 * XSCRNSAVER is absent on purpose — the index has no compat.xscrnsaver. Its
 * only effect is that SDL falls back to its own screensaver inhibition path. */
#define SDL_VIDEO_DRIVER_X11 1
#define SDL_VIDEO_DRIVER_X11_XCURSOR 1
#define SDL_VIDEO_DRIVER_X11_XDBE 1
#define SDL_VIDEO_DRIVER_X11_XFIXES 1
#define SDL_VIDEO_DRIVER_X11_XINPUT2 1
#define SDL_VIDEO_DRIVER_X11_XINPUT2_SUPPORTS_MULTITOUCH 1
#define SDL_VIDEO_DRIVER_X11_XRANDR 1
#define SDL_VIDEO_DRIVER_X11_XSHAPE 1
#define SDL_VIDEO_DRIVER_X11_SUPPORTS_GENERIC_EVENTS 1
#define SDL_VIDEO_DRIVER_X11_HAS_XKBKEYCODETOKEYSYM 1

#else
#error "compat.sdl2: no SDL_config.h branch for this platform"
#endif

#endif /* SDL_config_h_ */
]==],
        },

        linux = {
            sources = {
                -- The ONE directory where a glob over-reaches: SDL_dbus.c,
                -- SDL_ibus.c, SDL_fcitx.c and SDL_ime.c are the DBus-based IME
                -- stack and are NOT guarded by an internal #if — they simply
                -- fail to compile without dbus-1 headers, which this index does
                -- not package. Upstream's CMake omits them under
                -- -DSDL_DBUS=OFF; this list does the same.
                "*/src/core/linux/SDL_evdev.c",
                "*/src/core/linux/SDL_evdev_capabilities.c",
                "*/src/core/linux/SDL_evdev_kbd.c",
                "*/src/core/linux/SDL_sandbox.c",
                "*/src/core/linux/SDL_threadprio.c",
                "*/src/core/linux/SDL_udev.c",
                "*/src/core/unix/*.c",
                "*/src/filesystem/unix/*.c",
                "*/src/haptic/linux/*.c",
                "*/src/joystick/linux/*.c",
                "*/src/loadso/dlopen/*.c",
                "*/src/locale/unix/*.c",
                "*/src/misc/unix/*.c",
                "*/src/power/linux/*.c",
                "*/src/thread/pthread/*.c",
                "*/src/timer/unix/*.c",
                "*/src/video/x11/*.c",
            },
            -- The X11 set compat.glfw already proves out. xorgproto carries
            -- <X11/X.h>; the rest are the extensions the config block above
            -- switches on (XCursor, Xext for XDBE/XShape, XFixes, XInput2,
            -- XRandR) plus Xinerama, which SDL probes for.
            deps = {
                -- glx-headers, not compat.opengl: SDL's X11 driver includes
                -- <GL/glx.h>, which the Khronos registry does not carry. The two
                -- packages overlap on GL/gl.h, so exactly one of them belongs
                -- here — see the note in compat.glx-headers.
                ["compat.glx-headers"] = "1.7.0",
                ["compat.x11"]       = "1.8.13",
                ["compat.xcursor"]   = "1.2.3",
                ["compat.xext"]      = "1.3.7",
                ["compat.xfixes"]    = "6.0.2",
                ["compat.xi"]        = "1.8.3",
                ["compat.xinerama"]  = "1.1.6",
                ["compat.xorgproto"] = "2025.1",
                ["compat.xrandr"]    = "1.5.5",
                ["compat.xrender"]   = "0.9.12",
            },
            ldflags = { "-lpthread", "-ldl", "-lm" },
            runtime = {
                capabilities = { "x11.display" },
            },
        },

        macosx = {
            -- Cocoa, CoreAudio and the IOKit joystick/haptic backends are
            -- Objective-C, hence the .m globs alongside the .c ones.
            sources = {
                "*/src/audio/coreaudio/*.m",
                "*/src/file/cocoa/*.m",
                "*/src/filesystem/cocoa/*.m",
                "*/src/haptic/darwin/*.c",
                "*/src/joystick/darwin/*.c",
                -- SDL_JOYSTICK_MFI is on in upstream's macosx config, and
                -- SDL_gamecontroller.c calls into it (IOS_SupportedHIDDevice,
                -- IOS_GameControllerGetAppleSFSymbolsName*). The directory is
                -- named iphoneos but serves macOS too.
                "*/src/joystick/iphoneos/*.m",
                "*/src/loadso/dlopen/*.c",
                "*/src/locale/macosx/*.m",
                "*/src/misc/macosx/*.m",
                "*/src/power/macosx/*.c",
                "*/src/render/metal/*.m",
                "*/src/thread/pthread/*.c",
                "*/src/timer/unix/*.c",
                "*/src/video/cocoa/*.m",
            },
            -- ARC is not optional on Apple: SDL's cocoa classes declare
            -- `__weak SDL_WindowData *_data`, and a __weak ivar without ARC is
            -- rejected outright ("'_data' is unavailable"). Upstream's CMake
            -- hard-fails when the compiler cannot do -fobjc-arc, for this
            -- reason. It applies to the .m files, which mcpp routes through
            -- cflags along with the .c ones.
            cflags = { "-fobjc-arc" },
            ldflags = {
                "-framework", "Cocoa",
                "-framework", "CoreFoundation",
                "-framework", "CoreAudio",
                "-framework", "AudioToolbox",
                "-framework", "CoreVideo",
                "-framework", "IOKit",
                "-framework", "ForceFeedback",
                "-framework", "Carbon",
                "-framework", "Metal",
                "-framework", "QuartzCore",
                "-framework", "CoreHaptics",
                "-framework", "GameController",
                -- Foundation/CoreFoundation for CF* (CFRelease and friends);
                -- SystemConfiguration for SCDynamicStoreCopyProxies, which
                -- SDL's URL/misc code uses.
                "-framework", "Foundation",
                "-framework", "SystemConfiguration",
                "-lpthread", "-lm",
            },
        },

        windows = {
            sources = {
                "*/src/audio/directsound/*.c",
                "*/src/audio/wasapi/*.c",
                "*/src/audio/winmm/*.c",
                "*/src/core/windows/*.c",
                "*/src/filesystem/windows/*.c",
                "*/src/haptic/windows/*.c",
                "*/src/joystick/windows/*.c",
                "*/src/loadso/windows/*.c",
                "*/src/locale/windows/*.c",
                "*/src/misc/windows/*.c",
                "*/src/power/windows/*.c",
                "*/src/sensor/windows/*.c",
                -- thread/windows, plus exactly one file from thread/generic.
                -- The windows condition-variable backend (SDL_syscond_cv.c)
                -- falls back to the generic implementation, so
                -- SDL_CreateCond_generic & co. have to be linked. Only that one
                -- file: generic's SDL_sysmutex.c / SDL_syssem.c /
                -- SDL_systhread.c / SDL_systls.c share basenames with the
                -- windows set, and mcpp keys objects by basename in one flat
                -- per-link directory (mcpp#233), so pulling the whole directory
                -- would have them silently displace each other. SDL_syscond.c
                -- has no windows twin, so it is safe.
                "*/src/thread/generic/SDL_syscond.c",
                "*/src/thread/windows/*.c",
                "*/src/timer/windows/*.c",
                "*/src/video/windows/*.c",
            },
            -- SDL_audiocvt.c carries runtime-dispatched SSE3 converters, and
            -- clang refuses to inline `_mm_hadd_ps` into a function compiled
            -- without the target feature (gcc is lenient here, which is why
            -- Linux never saw it). Upstream applies the flag per file; so do we,
            -- rather than raising the ISA floor for the whole library.
            flags = {
                { glob = "*/src/audio/SDL_audiocvt.c", cflags = { "-msse3" } },
            },
            ldflags = {
                "-luser32", "-lgdi32", "-lwinmm", "-limm32",
                "-lole32", "-loleaut32", "-lshell32", "-lsetupapi",
                "-lversion", "-luuid", "-ladvapi32",
            },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

-- The upstream SDL2-branch guard of `_m_prefetch` (see the header notes), then
-- the unpacked tree moved into the install dir as its single wrap level so the
-- `*/` globs keep matching (compat.libserial does the same).
function install()
    local wrap = "SDL-release-" .. pkginfo.version()
    local source = path.join(wrap, "include", "SDL_endian.h")
    local content = io.readfile(source)
    if not content then
        log.error("compat.sdl2: cannot read %s", source)
        return false
    end
    local before = "/* As of Clang 11, '_m_prefetchw' is conflicting with the winnt.h's version,\n"
                .. "   so we define the needed '_m_prefetch' here as a pseudo-header, until the issue is fixed. */\n"
                .. "#ifdef __clang__\n"
    local after = "/* As of Clang 11, '_m_prefetchw' is conflicting with the winnt.h's version,\n"
               .. "   so we define the needed '_m_prefetch' here as a pseudo-header, until the issue is fixed. */\n"
               .. "#if defined(__clang__) && !_SDL_HAS_BUILTIN(_m_prefetch)\n"
    local pattern = before:gsub("(%W)", "%%%1")
    local patched, count = content:gsub(pattern, function() return after end)
    if count ~= 1 then
        log.error("compat.sdl2: expected 1 match of the _m_prefetch guard in %s, found %d", source, count)
        return false
    end
    io.writefile(source, patched)

    local prefix = pkginfo.install_dir()
    os.tryrm(prefix)
    os.mkdir(prefix)
    os.mv(wrap, path.join(prefix, wrap))
    return true
end
