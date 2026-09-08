-- compat.sdl3 — SDL3, the cross-platform window/input/audio layer, built from
-- source.
--
-- Shape E (whole-source build over a generated config), and the sibling of
-- `compat.sdl2` rather than its replacement: SDL2 and SDL3 are different APIs
-- with different sonames, and projects migrate on their own schedule.
--
-- Two things are easier here than they were for SDL2, and both were measured:
--
--   * NO REPACKED TARBALL. SDL2's entry has to point at an `xlings-res`
--     re-host because the upstream archive carries symlinks that break the
--     windows runner. SDL3's does not — `tar tvzf | grep -c '^l'` is 0 — so
--     GLOBAL points straight at GitHub.
--   * THE CONFIG DISPATCHER IS UPSTREAM'S. `include/build_config/SDL_build_config.h`
--     already selects `SDL_build_config_windows.h` / `_macos.h` by platform, and
--     both of those are CHECKED IN. Only linux falls through to
--     `SDL_build_config_minimal.h`, which has no video driver at all.
--
-- ── So exactly one config is generated, and only linux uses it ─────────────
--
-- `mcpp_generated/SDL_build_config.h` below is a dispatcher of the same shape
-- as upstream's: on windows and macOS it defers to the checked-in per-platform
-- headers (which is why `*/include/build_config` is on the include path), and
-- on everything else it carries the CMake output inline.
--
-- That output was generated WITH THIS INDEX'S TOOLCHAIN, which is not a
-- formality — it is the reason the file is trustworthy. `compat.curl` records
-- what happens otherwise: a config generated with the host `cc` once asserted
-- that `ssize_t` does not exist. Two details make it reproducible:
--
--     cmake -DCMAKE_C_COMPILER=<xim gcc 16.1.0> \
--           -DCMAKE_C_FLAGS="-I<compat.x11>/include -I<compat.xorgproto>/... " \
--           -DCMAKE_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \
--           -DSDL_X11=ON -DSDL_X11_XSCRNSAVER=OFF -DSDL_X11_XTEST=OFF \\
--           -DSDL_X11_XSYNC=OFF -DSDL_LIBTHAI=OFF -DSDL_HIDAPI_LIBUSB=OFF \\
--           -DSDL_WAYLAND=OFF -DSDL_DBUS=OFF -DSDL_ALSA=OFF ...
--
--   * the X11 headers come from THIS INDEX's packages, not the host's. mcpp's
--     gcc has its own sysroot and cannot see /usr/include, so without them
--     SDL's own check fails outright ("SDL could not find X11 or Wayland
--     development libraries") and the configure aborts.
--   * `CMAKE_LIBRARY_PATH` only lets the probe LINK a libX11 so the check
--     passes. It does not reach the build: the result is `x11(dynamic)`, and a
--     dynamic X11 driver dlopens `libX11.so.6` at runtime, so this package
--     carries no X11 link dependency at all — only the compile-time headers.
--
-- ⚠️ THE CONFIG MAY ONLY CLAIM WHAT THIS INDEX PACKAGES, and that is a rule
-- rather than a preference. CMake probes the machine it runs on, so anything
-- the HOST happens to have gets switched on and then fails to compile here.
-- Three had to be switched off explicitly, each found by a failing build:
--
--     XSCRNSAVER  src/video/x11/SDL_x11dyn.h:69: fatal error:
--                 X11/extensions/scrnsaver.h: No such file or directory
--     LIBTHAI     the Thai line-breaker the X11 message-box toolkit uses
--     HIDAPI_LIBUSB  hidapi's libusb backend
--
-- XTEST and XSYNC are off for the same reason, pre-emptively.
--
-- What remains is checkable rather than hopeful: after configuring, every
-- library the config says it will `dlopen` must have a package here. The list
-- is seven and it does —
--
--     libfribidi.so.0  compat.fribidi        libX11.so.6      compat.x11
--     libXcursor.so.1  compat.xcursor        libXext.so.6     compat.xext
--     libXfixes.so.3   compat.xfixes         libXi.so.6       compat.xi
--     libXrandr.so.2   compat.xrandr
--
-- — which is the same list as `linux.deps` below, plus xcb and xorgproto for
-- headers those pull in. Adding an extension means adding its package first.
--
-- The enabled set matches what `compat.sdl2` settled on, for the same reasons:
-- X11 video, evdev input, disk/dummy audio, no dbus (the IME stack does not
-- self-guard and needs headers this index does not package), no wayland (the
-- scanner is a build-time code generator), no ALSA/PulseAudio.
--
-- ── The source list is CMake's own answer, not a reading of it ─────────────
--
-- After configuring, the objects CMake decided to build were read back out of
-- `CMakeFiles/SDL3-static.dir/build.make` and mapped to directories: 266
-- sources, falling into 73 directories taken WHOLE and exactly one taken in
-- part. That one is `src/core/linux`, where `SDL_dbus.c`, `SDL_fcitx.c`,
-- `SDL_ibus.c`, `SDL_ime.c`, `SDL_progressbar.c` and `SDL_system_theme.c` are
-- the DBus/IME stack — the same files `compat.sdl2` omits, and for the same
-- reason: they are not guarded internally, they simply fail to compile without
-- dbus-1 headers.
--
-- Everything else is a directory glob, which works because SDL compiles the
-- unselected backends into EMPTY translation units — `render/direct3d12` and
-- `render/ps2` are in the common list below and contribute nothing on linux.
--
-- ── macOS and Windows are derived from the CHECKED-IN configs ──────────────
--
-- Those two platforms do not use the generated config, so their source lists
-- must match what upstream's own headers switch on. Read out of them:
--
--   macOS    COREAUDIO, IOKIT joystick+haptic, MFI, VIDEO_COCOA, RENDER_METAL,
--            GPU_METAL, GPU_VULKAN, POWER_MACOSX, FILESYSTEM_COCOA,
--            FSOPS_POSIX, CAMERA_COREMEDIA, PROCESS_POSIX, THREAD_PTHREAD,
--            TIME/TIMER_UNIX, LOADSO_DLOPEN. No X11 (the `X11_*` sub-defines
--            present in that header are inert without the main switch).
--   windows  WASAPI + DSOUND, DINPUT/XINPUT/WGI/RAWINPUT/GAMEINPUT joystick,
--            HAPTIC_DINPUT, VIDEO_WINDOWS, RENDER_D3D/D3D11/D3D12/VULKAN,
--            GPU_D3D11/D3D12/VULKAN, POWER/FILESYSTEM/FSOPS_WINDOWS,
--            CAMERA_MEDIAFOUNDATION, PROCESS/SENSOR/LOADSO/THREAD/TIME/
--            TIMER_WINDOWS.
--
-- The one non-obvious consequence is on windows: `SDL_THREAD_GENERIC_COND_SUFFIX`
-- and `SDL_THREAD_GENERIC_RWLOCK_SUFFIX` mean the windows backend implements
-- condition variables and rwlocks by falling back to the GENERIC ones, so
-- `thread/generic/SDL_syscond.c` and `SDL_sysrwlock.c` have to be linked
-- alongside `thread/windows/*`. Only those two: the other four generic files
-- share basenames with their windows twins, and taking the directory whole
-- would compile two definitions of the same functions.
--
-- ⚠️ Verified on linux (gcc 16.1.0 and llvm) only. macOS and Windows are
-- derived as above and confirmed by CI rather than locally — there is no way
-- to compile either from here.
--
-- CN mirror: `gitcode.com/mcpp-res/sdl3`, the upstream tarball re-hosted
-- BYTE-IDENTICALLY (verified: the mirror's sha256 equals the one declared
-- here). GLOBAL stays the default.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "sdl3",
    description = "SDL3 — cross-platform window, input and audio layer",
    licenses    = {"Zlib"},
    repo        = "https://github.com/libsdl-org/SDL",
    type        = "package",

    xpm = {
        linux = {
            ["3.4.2"] = {
                url = {
                    GLOBAL = "https://github.com/libsdl-org/SDL/archive/refs/tags/release-3.4.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sdl3/releases/download/3.4.2/sdl3-3.4.2.tar.gz",
                },
                sha256 = "515ee4ad6e910e0ad8d8bbccb24ac52dd16c419e23eea3fb83541d20130c7aaa",
            },
        },
        macosx = {
            ["3.4.2"] = {
                url = {
                    GLOBAL = "https://github.com/libsdl-org/SDL/archive/refs/tags/release-3.4.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sdl3/releases/download/3.4.2/sdl3-3.4.2.tar.gz",
                },
                sha256 = "515ee4ad6e910e0ad8d8bbccb24ac52dd16c419e23eea3fb83541d20130c7aaa",
            },
        },
        windows = {
            ["3.4.2"] = {
                url = {
                    GLOBAL = "https://github.com/libsdl-org/SDL/archive/refs/tags/release-3.4.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/sdl3/releases/download/3.4.2/sdl3-3.4.2.tar.gz",
                },
                sha256 = "515ee4ad6e910e0ad8d8bbccb24ac52dd16c419e23eea3fb83541d20130c7aaa",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        -- ORDER MATTERS: mcpp_generated first, so `#include "SDL_build_config.h"`
        -- from src/SDL_internal.h finds the dispatcher below rather than
        -- upstream's. `*/include/build_config` must follow it, because that
        -- dispatcher defers to the checked-in per-platform configs by name.
        -- `*/src` carries the private headers the sources include as
        -- `video/SDL_sysvideo.h` &c; `*/src/video/khronos` carries SDL's
        -- vendored EGL/GLES headers.
        include_dirs = {
            "mcpp_generated",
            "*/include",
            "*/include/build_config",
            "*/src",
            "*/src/video/khronos",
        },

        generated_files = {
            ["mcpp_generated/SDL_build_config.h"] = [==[
#ifndef SDL_build_config_h_
#define SDL_build_config_h_

/* mcpp-index dispatcher, same shape as upstream's
   include/build_config/SDL_build_config.h: windows and macOS have a
   checked-in config, and only linux needs a generated one. */
#include <SDL3/SDL_platform_defines.h>

#if defined(SDL_PLATFORM_WIN32)
#include "SDL_build_config_windows.h"
#elif defined(SDL_PLATFORM_WINGDK)
#include "SDL_build_config_wingdk.h"
#elif defined(SDL_PLATFORM_XBOXONE) || defined(SDL_PLATFORM_XBOXSERIES)
#include "SDL_build_config_xbox.h"
#elif defined(SDL_PLATFORM_MACOS)
#include "SDL_build_config_macos.h"
#elif defined(SDL_PLATFORM_IOS)
#include "SDL_build_config_ios.h"
#else

/* ---- CMake output for linux, generated with this index's toolchain ---- */

/* General platform specific identifiers */
#include <SDL3/SDL_platform_defines.h>

/* #undef SDL_PLATFORM_PRIVATE */

#ifdef SDL_PLATFORM_PRIVATE
#include "SDL_begin_config_private.h"
#endif

#define HAVE_GCC_ATOMICS 1
/* #undef HAVE_GCC_SYNC_LOCK_TEST_AND_SET */

/* #undef SDL_DISABLE_ALLOCA */

/* Useful headers */
#define HAVE_FLOAT_H 1
#define HAVE_STDARG_H 1
#define HAVE_STDDEF_H 1
#define HAVE_STDINT_H 1

/* Comment this if you want to build without any C library requirements */
#define HAVE_LIBC 1
#ifdef HAVE_LIBC

/* Useful headers */
#define HAVE_ALLOCA_H 1
#define HAVE_ICONV_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_LIMITS_H 1
#define HAVE_MALLOC_H 1
#define HAVE_MATH_H 1
#define HAVE_MEMORY_H 1
#define HAVE_SIGNAL_H 1
#define HAVE_STDIO_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRINGS_H 1
#define HAVE_STRING_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_WCHAR_H 1
/* #undef HAVE_PTHREAD_NP_H */

/* C library functions */
#define HAVE_DLOPEN 1
#define HAVE_MALLOC 1
#define HAVE_FDATASYNC 1
#define HAVE_GETENV 1
#define HAVE_GETHOSTNAME 1
#define HAVE_SETENV 1
#define HAVE_PUTENV 1
#define HAVE_UNSETENV 1
#define HAVE_ABS 1
#define HAVE_BCOPY 1
#define HAVE_MEMSET 1
#define HAVE_MEMCPY 1
#define HAVE_MEMMOVE 1
#define HAVE_MEMCMP 1
#define HAVE_WCSLEN 1
#define HAVE_WCSNLEN 1
#define HAVE_WCSLCPY 1
#define HAVE_WCSLCAT 1
#define HAVE_WCSSTR 1
#define HAVE_WCSCMP 1
#define HAVE_WCSNCMP 1
#define HAVE_WCSTOL 1
#define HAVE_STRLEN 1
#define HAVE_STRNLEN 1
#define HAVE_STRLCPY 1
#define HAVE_STRLCAT 1
#define HAVE_STRPBRK 1
/* #undef HAVE__STRREV */
#define HAVE_INDEX 1
#define HAVE_RINDEX 1
#define HAVE_STRCHR 1
#define HAVE_STRRCHR 1
#define HAVE_STRSTR 1
/* #undef HAVE_STRNSTR */
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
#define HAVE_VSSCANF 1
#define HAVE_VSNPRINTF 1
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
/* #undef HAVE__COPYSIGN */
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
#define HAVE_ISINF 1
#define HAVE_ISINFF 1
#define HAVE_ISINF_FLOAT_MACRO 1
#define HAVE_ISNAN 1
#define HAVE_ISNANF 1
#define HAVE_ISNAN_FLOAT_MACRO 1
#define HAVE_LOG 1
#define HAVE_LOGF 1
#define HAVE_LOG10 1
#define HAVE_LOG10F 1
#define HAVE_LROUND 1
#define HAVE_LROUNDF 1
#define HAVE_MODF 1
#define HAVE_MODFF 1
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
/* #undef HAVE__FSEEKI64 */
#define HAVE_FOPEN64 1
#define HAVE_FSEEKO 1
#define HAVE_FSEEKO64 1
#define HAVE_MEMFD_CREATE 1
#define HAVE_POSIX_FALLOCATE 1
#define HAVE_SIGACTION 1
#define HAVE_SIGTIMEDWAIT 1
#define HAVE_SA_SIGACTION 1
#define HAVE_ST_MTIM 1
#define HAVE_SETJMP 1
#define HAVE_NANOSLEEP 1
#define HAVE_GMTIME_R 1
#define HAVE_LOCALTIME_R 1
#define HAVE_NL_LANGINFO 1
#define HAVE_SYSCONF 1
/* #undef HAVE_SYSCTLBYNAME */
#define HAVE_CLOCK_GETTIME 1
#define HAVE_GETPAGESIZE 1
#define HAVE_ICONV 1
/* #undef SDL_USE_LIBICONV */
#define HAVE_PTHREAD_SETNAME_NP 1
/* #undef HAVE_PTHREAD_SET_NAME_NP */
#define HAVE_SEM_TIMEDWAIT 1
#define HAVE_GETAUXVAL 1
/* #undef HAVE_ELF_AUX_INFO */
#define HAVE_PPOLL 1
#define HAVE__EXIT 1
#define HAVE_GETRESUID 1
#define HAVE_GETRESGID 1

#endif /* HAVE_LIBC */

/* #undef HAVE_DBUS_DBUS_H */
/* #undef HAVE_FCITX */
/* #undef HAVE_IBUS_IBUS_H */
#define HAVE_INOTIFY_INIT1 1
#define HAVE_INOTIFY 1
/* #undef HAVE_LIBUSB */
#define HAVE_O_CLOEXEC 1

#define HAVE_LINUX_INPUT_H 1
/* #undef HAVE_LIBUDEV_H */
/* #undef HAVE_LIBDECOR_H */
/* #undef HAVE_LIBURING_H */
#define HAVE_FRIBIDI_H 1
#define SDL_FRIBIDI_DYNAMIC "libfribidi.so.0"
/* #undef HAVE_LIBTHAI_H */
/* #undef SDL_LIBTHAI_DYNAMIC */

/* #undef HAVE_DDRAW_H */
/* #undef HAVE_DSOUND_H */
/* #undef HAVE_DINPUT_H */
/* #undef HAVE_XINPUT_H */
/* #undef HAVE_WINDOWS_GAMING_INPUT_H */
/* #undef HAVE_GAMEINPUT_H */
/* #undef HAVE_DXGI_H */
/* #undef HAVE_DXGI1_5_H */
/* #undef HAVE_DXGI1_6_H */

/* #undef HAVE_MMDEVICEAPI_H */
/* #undef HAVE_TPCSHRD_H */
/* #undef HAVE_ROAPI_H */
/* #undef HAVE_SHELLSCALINGAPI_H */

/* #undef USE_POSIX_SPAWN */
#define HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR 1
#define HAVE_POSIX_SPAWN_FILE_ACTIONS_ADDCHDIR_NP 1

/* #undef SDL_DISABLE_DLOPEN_NOTES */

/* SDL internal assertion support */
/* #undef SDL_DEFAULT_ASSERT_LEVEL_CONFIGURED */
#ifdef SDL_DEFAULT_ASSERT_LEVEL_CONFIGURED
#define SDL_DEFAULT_ASSERT_LEVEL 
#endif

/* Allow disabling of major subsystems */
/* #undef SDL_AUDIO_DISABLED */
/* #undef SDL_VIDEO_DISABLED */
/* #undef SDL_GPU_DISABLED */
/* #undef SDL_RENDER_DISABLED */
#define SDL_CAMERA_DISABLED 1
/* #undef SDL_JOYSTICK_DISABLED */
/* #undef SDL_HAPTIC_DISABLED */
/* #undef SDL_HIDAPI_DISABLED */
/* #undef SDL_POWER_DISABLED */
/* #undef SDL_SENSOR_DISABLED */
/* #undef SDL_DIALOG_DISABLED */
/* #undef SDL_THREADS_DISABLED */

/* Enable various audio drivers */
/* #undef SDL_AUDIO_DRIVER_ALSA */
/* #undef SDL_AUDIO_DRIVER_ALSA_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_OPENSLES */
/* #undef SDL_AUDIO_DRIVER_AAUDIO */
/* #undef SDL_AUDIO_DRIVER_COREAUDIO */
#define SDL_AUDIO_DRIVER_DISK 1
/* #undef SDL_AUDIO_DRIVER_DSOUND */
#define SDL_AUDIO_DRIVER_DUMMY 1
/* #undef SDL_AUDIO_DRIVER_EMSCRIPTEN */
/* #undef SDL_AUDIO_DRIVER_HAIKU */
/* #undef SDL_AUDIO_DRIVER_JACK */
/* #undef SDL_AUDIO_DRIVER_JACK_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_NETBSD */
/* #undef SDL_AUDIO_DRIVER_OSS */
/* #undef SDL_AUDIO_DRIVER_PIPEWIRE */
/* #undef SDL_AUDIO_DRIVER_PIPEWIRE_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_PULSEAUDIO */
/* #undef SDL_AUDIO_DRIVER_PULSEAUDIO_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_SNDIO */
/* #undef SDL_AUDIO_DRIVER_SNDIO_DYNAMIC */
/* #undef SDL_AUDIO_DRIVER_WASAPI */
/* #undef SDL_AUDIO_DRIVER_VITA */
/* #undef SDL_AUDIO_DRIVER_PSP */
/* #undef SDL_AUDIO_DRIVER_PS2 */
/* #undef SDL_AUDIO_DRIVER_N3DS */
/* #undef SDL_AUDIO_DRIVER_NGAGE */
/* #undef SDL_AUDIO_DRIVER_QNX */

/* #undef SDL_AUDIO_DRIVER_PRIVATE */

/* Enable various input drivers */
#define SDL_INPUT_LINUXEV 1
#define SDL_INPUT_LINUXKD 1
/* #undef SDL_INPUT_FBSDKBIO */
/* #undef SDL_INPUT_WSCONS */
/* #undef SDL_HAVE_MACHINE_JOYSTICK_H */
/* #undef SDL_JOYSTICK_ANDROID */
/* #undef SDL_JOYSTICK_DINPUT */
/* #undef SDL_JOYSTICK_DUMMY */
/* #undef SDL_JOYSTICK_EMSCRIPTEN */
/* #undef SDL_JOYSTICK_GAMEINPUT */
/* #undef SDL_JOYSTICK_HAIKU */
#define SDL_JOYSTICK_HIDAPI 1
/* #undef SDL_JOYSTICK_IOKIT */
#define SDL_JOYSTICK_LINUX 1
/* #undef SDL_JOYSTICK_MFI */
/* #undef SDL_JOYSTICK_N3DS */
/* #undef SDL_JOYSTICK_PS2 */
/* #undef SDL_JOYSTICK_PSP */
/* #undef SDL_JOYSTICK_RAWINPUT */
/* #undef SDL_JOYSTICK_USBHID */
#define SDL_JOYSTICK_VIRTUAL 1
/* #undef SDL_JOYSTICK_VITA */
/* #undef SDL_JOYSTICK_WGI */
/* #undef SDL_JOYSTICK_XINPUT */

/* #undef SDL_JOYSTICK_PRIVATE */

/* #undef SDL_HAPTIC_DUMMY */
#define SDL_HAPTIC_LINUX 1
/* #undef SDL_HAPTIC_IOKIT */
/* #undef SDL_HAPTIC_DINPUT */
/* #undef SDL_HAPTIC_ANDROID */

/* #undef SDL_HAPTIC_PRIVATE */

/* #undef SDL_LIBUSB_DYNAMIC */
/* #undef SDL_UDEV_DYNAMIC */

/* Enable various process implementations */
/* #undef SDL_PROCESS_DUMMY */
#define SDL_PROCESS_POSIX 1
/* #undef SDL_PROCESS_WINDOWS */

/* #undef SDL_PROCESS_PRIVATE */

/* Enable various sensor drivers */
/* #undef SDL_SENSOR_ANDROID */
/* #undef SDL_SENSOR_COREMOTION */
/* #undef SDL_SENSOR_WINDOWS */
#define SDL_SENSOR_DUMMY 1
/* #undef SDL_SENSOR_VITA */
/* #undef SDL_SENSOR_N3DS */
/* #undef SDL_SENSOR_EMSCRIPTEN */

/* #undef SDL_SENSOR_PRIVATE */

/* Enable various shared object loading systems */
#define SDL_LOADSO_DLOPEN 1
/* #undef SDL_LOADSO_DUMMY */
/* #undef SDL_LOADSO_WINDOWS */

/* #undef SDL_LOADSO_PRIVATE */

/* Enable various threading systems */
/* #undef SDL_THREAD_GENERIC_COND_SUFFIX */
/* #undef SDL_THREAD_GENERIC_RWLOCK_SUFFIX */
#define SDL_THREAD_PTHREAD 1
#define SDL_THREAD_PTHREAD_RECURSIVE_MUTEX 1
/* #undef SDL_THREAD_PTHREAD_RECURSIVE_MUTEX_NP */
/* #undef SDL_THREAD_WINDOWS */
/* #undef SDL_THREAD_VITA */
/* #undef SDL_THREAD_PSP */
/* #undef SDL_THREAD_PS2 */
/* #undef SDL_THREAD_N3DS */

/* #undef SDL_THREAD_PRIVATE */

/* Enable various RTC systems */
#define SDL_TIME_UNIX 1
/* #undef SDL_TIME_WINDOWS */
/* #undef SDL_TIME_VITA */
/* #undef SDL_TIME_PSP */
/* #undef SDL_TIME_PS2 */
/* #undef SDL_TIME_N3DS */
/* #undef SDL_TIME_NGAGE */

/* #undef SDL_TIME_PRIVATE */

/* Enable various timer systems */
/* #undef SDL_TIMER_HAIKU */
#define SDL_TIMER_UNIX 1
/* #undef SDL_TIMER_WINDOWS */
/* #undef SDL_TIMER_VITA */
/* #undef SDL_TIMER_PSP */
/* #undef SDL_TIMER_PS2 */
/* #undef SDL_TIMER_N3DS */

/* #undef SDL_TIMER_PRIVATE */

/* Enable various video drivers */
/* #undef SDL_VIDEO_DRIVER_ANDROID */
/* #undef SDL_VIDEO_DRIVER_COCOA */
#define SDL_VIDEO_DRIVER_DUMMY 1
/* #undef SDL_VIDEO_DRIVER_EMSCRIPTEN */
/* #undef SDL_VIDEO_DRIVER_HAIKU */
/* #undef SDL_VIDEO_DRIVER_KMSDRM */
/* #undef SDL_VIDEO_DRIVER_KMSDRM_DYNAMIC */
/* #undef SDL_VIDEO_DRIVER_KMSDRM_DYNAMIC_GBM */
/* #undef SDL_VIDEO_DRIVER_N3DS */
/* #undef SDL_VIDEO_DRIVER_NGAGE */
#define SDL_VIDEO_DRIVER_OFFSCREEN 1
/* #undef SDL_VIDEO_DRIVER_PS2 */
/* #undef SDL_VIDEO_DRIVER_PSP */
/* #undef SDL_VIDEO_DRIVER_RISCOS */
/* #undef SDL_VIDEO_DRIVER_ROCKCHIP */
/* #undef SDL_VIDEO_DRIVER_RPI */
/* #undef SDL_VIDEO_DRIVER_UIKIT */
/* #undef SDL_VIDEO_DRIVER_VITA */
/* #undef SDL_VIDEO_DRIVER_VIVANTE */
/* #undef SDL_VIDEO_DRIVER_VIVANTE_VDK */
/* #undef SDL_VIDEO_DRIVER_OPENVR */
/* #undef SDL_VIDEO_DRIVER_WAYLAND */
/* #undef SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC */
/* #undef SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_CURSOR */
/* #undef SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_EGL */
/* #undef SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_LIBDECOR */
/* #undef SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_XKBCOMMON */
/* #undef SDL_VIDEO_DRIVER_WINDOWS */
#define SDL_VIDEO_DRIVER_X11 1
#define SDL_VIDEO_DRIVER_X11_DYNAMIC "libX11.so.6"
#define SDL_VIDEO_DRIVER_X11_DYNAMIC_XCURSOR "libXcursor.so.1"
#define SDL_VIDEO_DRIVER_X11_DYNAMIC_XEXT "libXext.so.6"
#define SDL_VIDEO_DRIVER_X11_DYNAMIC_XFIXES "libXfixes.so.3"
#define SDL_VIDEO_DRIVER_X11_DYNAMIC_XINPUT2 "libXi.so.6"
#define SDL_VIDEO_DRIVER_X11_DYNAMIC_XRANDR "libXrandr.so.2"
/* #undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XSS */
/* #undef SDL_VIDEO_DRIVER_X11_DYNAMIC_XTEST */
#define SDL_VIDEO_DRIVER_X11_HAS_XKBLIB 1
#define SDL_VIDEO_DRIVER_X11_SUPPORTS_GENERIC_EVENTS 1
#define SDL_VIDEO_DRIVER_X11_XCURSOR 1
#define SDL_VIDEO_DRIVER_X11_XDBE 1
#define SDL_VIDEO_DRIVER_X11_XFIXES 1
#define SDL_VIDEO_DRIVER_X11_XINPUT2 1
#define SDL_VIDEO_DRIVER_X11_XINPUT2_SUPPORTS_MULTITOUCH 1
#define SDL_VIDEO_DRIVER_X11_XINPUT2_SUPPORTS_SCROLLINFO 1
#define SDL_VIDEO_DRIVER_X11_XINPUT2_SUPPORTS_GESTURE 1
#define SDL_VIDEO_DRIVER_X11_XRANDR 1
/* #undef SDL_VIDEO_DRIVER_X11_XSCRNSAVER */
#define SDL_VIDEO_DRIVER_X11_XSHAPE 1
/* #undef SDL_VIDEO_DRIVER_X11_XSYNC */
/* #undef SDL_VIDEO_DRIVER_X11_XTEST */
/* #undef SDL_VIDEO_DRIVER_QNX */

/* #undef SDL_VIDEO_DRIVER_PRIVATE */

/* #undef SDL_VIDEO_RENDER_D3D */
/* #undef SDL_VIDEO_RENDER_D3D11 */
/* #undef SDL_VIDEO_RENDER_D3D12 */
#define SDL_VIDEO_RENDER_GPU 1
/* #undef SDL_VIDEO_RENDER_METAL */
#define SDL_VIDEO_RENDER_VULKAN 1
#define SDL_VIDEO_RENDER_OGL 1
#define SDL_VIDEO_RENDER_OGL_ES2 1
/* #undef SDL_VIDEO_RENDER_NGAGE */
/* #undef SDL_VIDEO_RENDER_PS2 */
/* #undef SDL_VIDEO_RENDER_PSP */
/* #undef SDL_VIDEO_RENDER_VITA_GXM */

/* #undef SDL_VIDEO_RENDER_PRIVATE */

/* Enable OpenGL support */
#define SDL_VIDEO_OPENGL 1
/* #undef SDL_VIDEO_OPENGL_ES */
#define SDL_VIDEO_OPENGL_ES2 1
/* #undef SDL_VIDEO_OPENGL_CGL */
#define SDL_VIDEO_OPENGL_GLX 1
/* #undef SDL_VIDEO_OPENGL_WGL */
#define SDL_VIDEO_OPENGL_EGL 1

/* #undef SDL_VIDEO_STATIC_ANGLE */

/* Enable Vulkan support */
#define SDL_VIDEO_VULKAN 1

/* Enable Metal support */
/* #undef SDL_VIDEO_METAL */

/* Enable GPU support */
/* #undef SDL_GPU_D3D11 */
/* #undef SDL_GPU_D3D12 */
#define SDL_GPU_VULKAN 1
/* #undef SDL_GPU_METAL */

/* #undef SDL_GPU_PRIVATE */

/* Enable system power support */
/* #undef SDL_POWER_ANDROID */
#define SDL_POWER_LINUX 1
/* #undef SDL_POWER_WINDOWS */
/* #undef SDL_POWER_MACOSX */
/* #undef SDL_POWER_UIKIT */
/* #undef SDL_POWER_HAIKU */
/* #undef SDL_POWER_EMSCRIPTEN */
/* #undef SDL_POWER_HARDWIRED */
/* #undef SDL_POWER_VITA */
/* #undef SDL_POWER_PSP */
/* #undef SDL_POWER_N3DS */

/* #undef SDL_POWER_PRIVATE */

/* Enable system filesystem support */
/* #undef SDL_FILESYSTEM_ANDROID */
/* #undef SDL_FILESYSTEM_HAIKU */
/* #undef SDL_FILESYSTEM_COCOA */
/* #undef SDL_FILESYSTEM_DUMMY */
/* #undef SDL_FILESYSTEM_RISCOS */
#define SDL_FILESYSTEM_UNIX 1
/* #undef SDL_FILESYSTEM_WINDOWS */
/* #undef SDL_FILESYSTEM_EMSCRIPTEN */
/* #undef SDL_FILESYSTEM_VITA */
/* #undef SDL_FILESYSTEM_PSP */
/* #undef SDL_FILESYSTEM_PS2 */
/* #undef SDL_FILESYSTEM_N3DS */

/* #undef SDL_FILESYSTEM_PRIVATE */

/* Enable system storage support */
#define SDL_STORAGE_STEAM 1

/* #undef SDL_STORAGE_PRIVATE */

/* Enable system FSops support */
#define SDL_FSOPS_POSIX 1
/* #undef SDL_FSOPS_WINDOWS */
/* #undef SDL_FSOPS_DUMMY */

/* #undef SDL_FSOPS_PRIVATE */

/* Enable camera subsystem */
#define SDL_CAMERA_DRIVER_DUMMY 1
/* !!! FIXME: for later cmakedefine SDL_CAMERA_DRIVER_DISK 1 */
/* #undef SDL_CAMERA_DRIVER_V4L2 */
/* #undef SDL_CAMERA_DRIVER_COREMEDIA */
/* #undef SDL_CAMERA_DRIVER_ANDROID */
/* #undef SDL_CAMERA_DRIVER_EMSCRIPTEN */
/* #undef SDL_CAMERA_DRIVER_MEDIAFOUNDATION */
/* #undef SDL_CAMERA_DRIVER_PIPEWIRE */
/* #undef SDL_CAMERA_DRIVER_PIPEWIRE_DYNAMIC */
/* #undef SDL_CAMERA_DRIVER_VITA */

/* #undef SDL_CAMERA_DRIVER_PRIVATE */

/* Enable dialog subsystem */
/* #undef SDL_DIALOG_DUMMY */

/* Enable tray subsystem */
/* #undef SDL_TRAY_DUMMY */

/* Enable assembly routines */
/* #undef SDL_ALTIVEC_BLITTERS */

/* Whether SDL_DYNAMIC_API needs dlopen */
#define DYNAPI_NEEDS_DLOPEN 1

/* Enable ime support */
/* #undef SDL_USE_IME */
/* #undef SDL_DISABLE_WINDOWS_IME */
/* #undef SDL_GDK_TEXTINPUT */

/* Platform specific definitions */
/* #undef SDL_IPHONE_KEYBOARD */
/* #undef SDL_IPHONE_LAUNCHSCREEN */

/* #undef SDL_VIDEO_VITA_PIB */
/* #undef SDL_VIDEO_VITA_PVR */
/* #undef SDL_VIDEO_VITA_PVR_OGL */

/* xkbcommon version info */
#define SDL_XKBCOMMON_VERSION_MAJOR 
#define SDL_XKBCOMMON_VERSION_MINOR 
#define SDL_XKBCOMMON_VERSION_PATCH 

/* Libdecor version info */
#define SDL_LIBDECOR_VERSION_MAJOR 
#define SDL_LIBDECOR_VERSION_MINOR 
#define SDL_LIBDECOR_VERSION_PATCH 

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
#ifdef _WIN64
typedef unsigned __int64 uintptr_t;
#else
typedef unsigned int uintptr_t;
#endif
#endif
#endif /* Visual Studio 2008 */
#endif /* !_STDINT_H_ && !HAVE_STDINT_H */

/* Configure use of intrinsics */
/* #undef SDL_DISABLE_SSE */
/* #undef SDL_DISABLE_SSE2 */
/* #undef SDL_DISABLE_SSE3 */
/* #undef SDL_DISABLE_SSE4_1 */
/* #undef SDL_DISABLE_SSE4_2 */
/* #undef SDL_DISABLE_AVX */
/* #undef SDL_DISABLE_AVX2 */
/* #undef SDL_DISABLE_AVX512F */
/* #undef SDL_DISABLE_MMX */
#define SDL_DISABLE_LSX 1
#define SDL_DISABLE_LASX 1
#define SDL_DISABLE_NEON 1

#ifdef SDL_PLATFORM_PRIVATE
#include "SDL_end_config_private.h"
#endif

#endif /* platform config */

#endif /* SDL_build_config_h_ */
]==],
        },

        -- Backend-independent core plus every backend directory whose files
        -- guard themselves. One list serves all three platforms; the
        -- per-platform blocks below add what does not self-guard.
        sources = {
            "*/src/*.c",
            "*/src/atomic/*.c",
            "*/src/audio/*.c",
            "*/src/audio/disk/*.c",
            "*/src/audio/dummy/*.c",
            "*/src/camera/*.c",
            "*/src/camera/dummy/*.c",
            "*/src/core/*.c",
            "*/src/cpuinfo/*.c",
            "*/src/dialog/*.c",
            "*/src/dynapi/*.c",
            "*/src/events/*.c",
            "*/src/filesystem/*.c",
            "*/src/gpu/*.c",
            "*/src/gpu/vulkan/*.c",
            "*/src/haptic/*.c",
            "*/src/haptic/hidapi/*.c",
            "*/src/hidapi/*.c",
            "*/src/io/*.c",
            "*/src/io/generic/*.c",
            "*/src/joystick/*.c",
            "*/src/joystick/hidapi/*.c",
            "*/src/joystick/virtual/*.c",
            "*/src/libm/*.c",
            "*/src/locale/*.c",
            "*/src/main/*.c",
            "*/src/main/generic/*.c",
            "*/src/misc/*.c",
            "*/src/power/*.c",
            "*/src/process/*.c",
            "*/src/render/*.c",
            "*/src/render/direct3d/*.c",
            "*/src/render/direct3d11/*.c",
            "*/src/render/direct3d12/*.c",
            "*/src/render/gpu/*.c",
            "*/src/render/ngage/*.c",
            "*/src/render/opengl/*.c",
            "*/src/render/opengles2/*.c",
            "*/src/render/ps2/*.c",
            "*/src/render/psp/*.c",
            "*/src/render/software/*.c",
            "*/src/render/vitagxm/*.c",
            "*/src/render/vulkan/*.c",
            "*/src/sensor/*.c",
            "*/src/sensor/dummy/*.c",
            "*/src/stdlib/*.c",
            "*/src/storage/*.c",
            "*/src/storage/generic/*.c",
            "*/src/storage/steam/*.c",
            "*/src/thread/*.c",
            "*/src/time/*.c",
            "*/src/timer/*.c",
            "*/src/tray/*.c",
            "*/src/video/*.c",
            "*/src/video/dummy/*.c",
            "*/src/video/offscreen/*.c",
            "*/src/video/yuv2rgb/*.c",
        },

        targets = { ["sdl3"] = { kind = "lib" } },
        deps    = {},

        linux = {
            sources = {
                "*/src/core/linux/SDL_evdev.c",
                "*/src/core/linux/SDL_evdev_capabilities.c",
                "*/src/core/linux/SDL_evdev_kbd.c",
                "*/src/core/linux/SDL_sandbox.c",
                "*/src/core/linux/SDL_threadprio.c",
                "*/src/core/linux/SDL_udev.c",
                "*/src/core/unix/*.c",
                "*/src/dialog/unix/*.c",
                "*/src/filesystem/posix/*.c",
                "*/src/filesystem/unix/*.c",
                "*/src/haptic/linux/*.c",
                "*/src/joystick/linux/*.c",
                "*/src/loadso/dlopen/*.c",
                "*/src/locale/unix/*.c",
                "*/src/misc/unix/*.c",
                "*/src/power/linux/*.c",
                "*/src/process/posix/*.c",
                "*/src/thread/pthread/*.c",
                "*/src/time/unix/*.c",
                "*/src/timer/unix/*.c",
                "*/src/tray/unix/*.c",
                "*/src/video/x11/*.c",
            },
            -- The X11 set compat.sdl2 already proves out. The driver is
            -- dynamic (it dlopens libX11.so.6), so these are COMPILE-time
            -- headers only — nothing here is linked against.
            deps = {
                ["compat.x11"]       = "1.8.13",
                ["compat.xcb"]       = "1.17.0",
                ["compat.xcursor"]   = "1.2.3",
                ["compat.xext"]      = "1.3.7",
                ["compat.xfixes"]    = "6.0.2",
                ["compat.xi"]        = "1.8.3",
                ["compat.xorgproto"] = "2025.1",
                ["compat.xrandr"]    = "1.5.5",
                -- SDL dlopens libfribidi.so.0 for RTL text in its X11
                -- message-box toolkit, so this is a compile-time header
                -- dependency like the X11 set above.
                ["compat.fribidi"]   = "1.0.16",
            },
            ldflags = { "-ldl", "-lpthread", "-lm", "-lrt" },
        },

        macosx = {
            -- Cocoa, CoreAudio, Metal and the MFI joystick backend are
            -- Objective-C, hence the .m globs alongside the .c ones.
            sources = {
                "*/src/audio/coreaudio/*.m",
                "*/src/camera/coremedia/*.m",
                "*/src/core/unix/*.c",
                "*/src/dialog/cocoa/*.m",
                "*/src/filesystem/cocoa/*.m",
                "*/src/filesystem/posix/*.c",
                "*/src/gpu/metal/*.m",
                "*/src/haptic/darwin/*.c",
                "*/src/joystick/apple/*.m",
                "*/src/joystick/darwin/*.c",
                "*/src/loadso/dlopen/*.c",
                "*/src/locale/macos/*.m",
                "*/src/misc/macos/*.m",
                "*/src/power/macos/*.c",
                "*/src/process/posix/*.c",
                "*/src/render/metal/*.m",
                "*/src/thread/pthread/*.c",
                "*/src/time/unix/*.c",
                "*/src/timer/unix/*.c",
                "*/src/tray/cocoa/*.m",
                "*/src/video/cocoa/*.m",
            },
            -- ARC is not optional on Apple: SDL's cocoa classes declare
            -- __weak ivars, which are rejected outright without it. Upstream's
            -- CMake hard-fails when the compiler cannot do -fobjc-arc.
            cflags = { "-fobjc-arc" },
            ldflags = {
                "-framework", "Cocoa", "-framework", "CoreFoundation",
                "-framework", "CoreAudio", "-framework", "AudioToolbox",
                "-framework", "CoreVideo", "-framework", "CoreMedia",
                "-framework", "AVFoundation", "-framework", "IOKit",
                "-framework", "ForceFeedback", "-framework", "Carbon",
                "-framework", "Metal", "-framework", "QuartzCore",
                "-framework", "CoreHaptics", "-framework", "GameController",
                "-framework", "Foundation", "-framework", "UniformTypeIdentifiers",
                "-lpthread", "-lm",
            },
        },

        windows = {
            sources = {
                "*/src/audio/directsound/*.c",
                "*/src/audio/wasapi/*.c",
                "*/src/camera/mediafoundation/*.c",
                "*/src/core/windows/*.c",
                "*/src/dialog/windows/*.c",
                "*/src/filesystem/windows/*.c",
                "*/src/gpu/d3d11/*.c",
                "*/src/gpu/d3d12/*.c",
                "*/src/haptic/windows/*.c",
                "*/src/io/windows/*.c",
                "*/src/joystick/windows/*.c",
                "*/src/loadso/windows/*.c",
                "*/src/locale/windows/*.c",
                "*/src/main/windows/*.c",
                "*/src/misc/windows/*.c",
                "*/src/power/windows/*.c",
                "*/src/process/windows/*.c",
                "*/src/sensor/windows/*.c",
                "*/src/thread/generic/SDL_syscond.c",
                "*/src/thread/generic/SDL_sysrwlock.c",
                "*/src/thread/windows/*.c",
                "*/src/time/windows/*.c",
                "*/src/timer/windows/*.c",
                "*/src/tray/windows/*.c",
                "*/src/video/windows/*.c",
            },
            ldflags = {
                "-luser32", "-lgdi32", "-lwinmm", "-limm32",
                "-lole32", "-loleaut32", "-lshell32", "-lsetupapi",
                "-lversion", "-luuid", "-ladvapi32", "-lcfgmgr32",
            },
        },
    },
}
