-- compat.opencv — OpenCV built from source into curated static module libs via an
-- install() hook that drives OpenCV's OWN CMake (the compat.openblas pattern, but
-- CMake instead of Make). mcpp's "list the .cpp files" model does NOT fit OpenCV:
-- the build GENERATES numerous per-module, per-version headers/sources that the
-- sources #include and that are NOT in the tarball — SIMD dispatch
-- (*.simd_declarations.hpp + per-ISA .cpp, 16 dispatched units in core alone),
-- OpenCL kernel blobs (opencl_kernels_*.{hpp,cpp}), and config headers
-- (cvconfig.h / opencv_modules.hpp / custom_hal.hpp). Letting CMake produce all of
-- them is the only maintainable path (vcpkg/conan/distros all drive upstream CMake).
-- Full analysis: .agents/docs/2026-07-08-opencv-ecosystem-adoption-research.md and
-- .agents/docs/2026-07-08-opencv-implementation-and-verification.md.
--
-- HOST-FREE / ecosystem-closed: the build uses ONLY ecosystem tools — xim:cmake,
-- xim:ninja + the per-OS compiler (declared build-deps) — never host
-- cmake/ninja/compiler. Zero downloads at build time (gapi's ADE fetch is killed by
-- WITH_ADE=OFF); everything else is compiled from the tarball's bundled 3rdparty/
-- (zlib + libpng + libjpeg-turbo built via BUILD_*=ON).
--
-- MVP module set (this recipe): core + imgproc + imgcodecs (BUILD_LIST). This is a
-- fixed, curated profile — OpenCV's WITH_*/BUILD_opencv_* toggles CANNOT be mcpp
-- `features` (a feature carries only implies/sources/defines/requires/provides/deps,
-- not cflags/include_dirs/generated_files, and cannot parametrise install()). Larger
-- variants (calib3d/dnn/highgui/contrib) are separate follow-up packages, not
-- per-consumer features. See the impl doc §"generic mcpp asks".
--
-- ABI: OpenCV is C++, so its static libs must be linked by the SAME C++ ABI as the
-- consumer. install() therefore builds with the compiler whose ABI matches each
-- platform's mcpp consumer — Linux gcc/libstdc++, macOS clang/libc++ (xim:llvm),
-- Windows clang-cl/msvc-stl — selected in install() by os.host(). See that function
-- for the per-platform toolchain + build-env details.
--
-- All three platforms build → link → run green in CI (workspace linux/macOS/windows):
-- the roundtrip test asserts core (4x4x3 BGR), imgproc (BGR->GRAY, blue luma 29) and
-- imgcodecs (PNG encode/decode round-trip).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.opencv",
    description = "OpenCV — computer vision library (core+imgproc+imgcodecs, built from source via CMake)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/opencv/opencv",
    type        = "package",

    xpm = {
        linux = {
            -- xim:glibc is declared explicitly (though transitively pulled by
            -- cmake/gcc) so install() can resolve its lib dir via pkginfo for the
            -- LINK-time LIBRARY_PATH (crt1.o/crti.o/libm) — see install() below.
            -- NB: kernel headers come from scode:linux-headers (the REAL payload).
            -- xim:linux-headers is a wrapper whose own install_dir is empty (it just
            -- deps on scode:linux-headers), so build_dep("linux-headers") off the
            -- wrapper yields no include/ — declare the real one so glibc's
            -- <linux/limits.h> resolves host-free.
            deps = { "xim:cmake@4.0.2", "xim:ninja@1.12.1", "xim:gcc@16.1.0",
                     "xim:glibc@2.39", "scode:linux-headers@5.11.1" },
            ["4.13.0"] = {
                -- GLOBAL>CN fallback table (the mcpp-index CN-mirror convention).
                -- The CN asset (gitcode mcpp-res/opencv) is the GitHub tag archive
                -- mirrored byte-for-byte via gtc — same sha256 below — so GLOBAL
                -- behaviour is unchanged and CN users get a fast mirror.
                url    = {
                    GLOBAL = "https://github.com/opencv/opencv/archive/refs/tags/4.13.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/4.13.0/opencv-4.13.0.tar.gz",
                },
                sha256 = "1d40ca017ea51c533cf9fd5cbde5b5fe7ae248291ddf2af99d4c17cf8e13017d",
            },
        },
        macosx = {
            -- clang/libc++ (xim:llvm) to match the macOS default consumer's ABI;
            -- gcc/libstdc++ would ABI-clash. clang finds the system SDK itself.
            -- Ninja (not xim:make — it has no macOS build) + clang (xim:llvm,
            -- unpinned: compiler version needn't be fixed; libc++ ABI is stable).
            deps = { "xim:cmake@4.0.2", "xim:ninja@1.12.1", "xim:llvm" },
            ["4.13.0"] = {
                -- GLOBAL>CN fallback table (the mcpp-index CN-mirror convention).
                -- The CN asset (gitcode mcpp-res/opencv) is the GitHub tag archive
                -- mirrored byte-for-byte via gtc — same sha256 below — so GLOBAL
                -- behaviour is unchanged and CN users get a fast mirror.
                url    = {
                    GLOBAL = "https://github.com/opencv/opencv/archive/refs/tags/4.13.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/4.13.0/opencv-4.13.0.tar.gz",
                },
                sha256 = "1d40ca017ea51c533cf9fd5cbde5b5fe7ae248291ddf2af99d4c17cf8e13017d",
            },
        },
        windows = {
            -- clang-cl (xim:llvm) builds OpenCV from source targeting
            -- x86_64-pc-windows-msvc (msvc-stl) to match mcpp's Windows consumer
            -- ABI; Ninja generator (xim:ninja is cross-platform). clang-cl finds the
            -- MSVC toolchain + Windows SDK from the registry, so no glibc-style
            -- build-dep wiring is needed here.
            deps = { "xim:cmake@4.0.2", "xim:ninja@1.12.1", "xim:llvm" },
            ["4.13.0"] = {
                -- GLOBAL>CN fallback table (the mcpp-index CN-mirror convention).
                -- The CN asset (gitcode mcpp-res/opencv) is the GitHub tag archive
                -- mirrored byte-for-byte via gtc — same sha256 below — so GLOBAL
                -- behaviour is unchanged and CN users get a fast mirror.
                url    = {
                    GLOBAL = "https://github.com/opencv/opencv/archive/refs/tags/4.13.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/4.13.0/opencv-4.13.0.tar.gz",
                },
                sha256 = "1d40ca017ea51c533cf9fd5cbde5b5fe7ae248291ddf2af99d4c17cf8e13017d",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        -- The anchor is NOT a generated_files entry: install() writes it, so its
        -- absence after extraction is what makes mcpp run install() (which is what
        -- triggers the CMake build). Same trigger as compat.openblas / compat.xcb.
        sources      = { "mcpp_opencv_anchor.c" },
        targets      = { ["opencv"] = { kind = "lib" } },
        -- install() lays headers at include/opencv4/opencv2/... — users write
        -- `#include <opencv2/core.hpp>` etc.
        include_dirs = { "include/opencv4" },
        deps         = { },

        -- Static link, module libs before their 3rdparty, before system libs.
        -- OpenCV drops bundled 3rdparty archives under lib/opencv4/3rdparty/, so a
        -- second -L is needed. `-Llib` / `-Llib/...` are rewritten to <verdir>/lib.
        linux  = { ldflags = {
            "-Llib", "-Llib/opencv4/3rdparty",
            "-lopencv_imgcodecs", "-lopencv_imgproc", "-lopencv_core",
            "-llibpng", "-llibjpeg-turbo", "-lzlib",
            "-ldl", "-lpthread", "-lm",
        } },
        macosx = { ldflags = {
            "-Llib", "-Llib/opencv4/3rdparty",
            "-lopencv_imgcodecs", "-lopencv_imgproc", "-lopencv_core",
            "-llibpng", "-llibjpeg-turbo", "-lzlib",
        } },
        windows = { ldflags = {
            -- clang-cl (MSVC driver) maps `-lfoo` → foo.lib and `-Llib` →
            -- /LIBPATH:<verdir>/lib (the compat.openblas Windows precedent). Names
            -- match the normalised install layout: version suffix dropped
            -- (opencv_core.lib) and 3rdparty under lib/opencv4/3rdparty. No anchor
            -- generated_files here: install() builds from source and emits the
            -- anchor itself (its absence is what triggers the build), same as
            -- linux/macOS.
            "-Llib", "-Llib/opencv4/3rdparty",
            "-lopencv_imgcodecs", "-lopencv_imgproc", "-lopencv_core",
            "-llibpng", "-llibjpeg-turbo", "-lzlib",
            -- Win32 system import libs OpenCV core pulls (resolved off the Windows
            -- SDK lib path clang-cl adds): ole32 for CoCreateGuid (cv::tempfile).
            "-lole32",
        } },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

-- Tools are invoked by BARE name, resolved off the install() PATH that xim sets up
-- from the declared build-deps (the compat.openblas `CC=gcc` approach). This is
-- deliberate: xim:cmake is glibc-dynamic, so exec'ing its raw binary by absolute
-- path fails ("cannot execute: required file not found" — its ELF interpreter /
-- xim:glibc loader is only wired on the build-dep PATH). Bare names get the
-- xim-provided launchers with the correct loader env. Still host-free: these are
-- the ecosystem build-deps on PATH, never host tools.

-- Locate the extracted OpenCV source tree (GitHub archives wrap in opencv-<ver>/).
local function find_srcroot(version)
    local ifile = pkginfo.install_file()
    local candidates = {
        ifile and tostring(ifile):replace(".tar.gz", "") or nil,
        "opencv-" .. version,
    }
    for _, c in ipairs(candidates) do
        if c and os.isdir(c) then return c end
    end
    return "opencv-" .. version
end

local function _install_impl()
    local version = pkginfo.version()
    local prefix  = pkginfo.install_dir()
    local srcroot = find_srcroot(version)

    local jobs = (os.default_njob and os.default_njob()) or 4

    -- Invoke build tools by BARE name (NOT absolute paths to the raw binaries).
    -- xim puts loader-wired LAUNCHERS for the declared build-deps on the install()
    -- PATH; bare names hit those. xim:cmake is glibc-DYNAMIC — its raw binary's
    -- ELF interpreter points at xim:glibc's loader, which is only wired through
    -- the launcher. Calling the raw binary by ABSOLUTE path works on a warm host
    -- (glibc already materialised at the patched interpreter path) but fails on a
    -- cold CI runner with "cannot execute: required file not found" — which is
    -- exactly what silently broke the install() build in CI. (xim:make is
    -- musl-static so it'd tolerate an absolute path; bare names are uniform +
    -- correct for all four.) This matches the header-comment strategy above.
    -- Per-platform compiler: Linux uses gcc (matches the gcc/libstdc++ default
    -- consumer); macOS uses clang/clang++ (matches the macOS libc++ default) —
    -- building OpenCV with gcc there would produce a libstdc++ .a that ABI-clashes
    -- with a libc++ consumer.
    local isMac = (os.host() == "macosx")
    local isWin = (os.host() == "windows")
    -- Ninja generator on ALL platforms (cross-platform via xim:ninja; xim:make has
    -- no macOS build). `cmake --build` drives it uniformly.
    local cmake, make = "cmake", "ninja"
    -- Per-platform compiler: Linux gcc (gcc/libstdc++ default consumer); macOS
    -- clang/clang++ (libc++ default); Windows clang-cl for BOTH C and C++ — it
    -- targets x86_64-pc-windows-msvc (msvc-stl), matching mcpp's own Windows
    -- consumer ABI, and autodetects the installed MSVC toolchain + Windows SDK from
    -- the registry (no vcvars/Developer-prompt needed).
    local gcc = isMac and "clang"   or (isWin and "clang-cl" or "gcc")
    local gxx = isMac and "clang++" or (isWin and "clang-cl" or "g++")

    -- xim:gcc's specs wire xim:glibc only for RUNTIME (rpath / dynamic-linker),
    -- NOT the LINK-time startfile + library search. mcpp's own build provides that
    -- via LIBRARY_PATH; an install() subprocess does NOT inherit it, so cmake's
    -- compiler check fails to LINK a test exe with
    --   ld: cannot find crt1.o / crti.o / -lm   (all in <xim:glibc>/lib).
    -- On a dev host it silently fell back to the host's /usr/lib crt/libc (works,
    -- but NOT host-free); a minimal CI runner has no libc-dev, so it hard-fails.
    -- Point gcc at xim:glibc/lib (+ xim:gcc/lib64 for libgcc_s) via LIBRARY_PATH so
    -- the build resolves the ecosystem glibc and stays host-free. (openblas never
    -- hit this: it only compiles + archives a .a, it never LINKS an executable.)
    -- Same gap on the HEADER side: gcc's own limits.h does `#include_next
    -- <limits.h>` and the C sources pull <stdlib.h> etc., all from xim:glibc's
    -- include dir (+ the kernel uapi headers from xim:linux-headers). gcc's specs
    -- do NOT add these to the header search path; mcpp's build supplies them via
    -- CPATH, which an install() subprocess doesn't inherit -> "stdlib.h / limits.h:
    -- No such file". Point CPATH at both so the build is host-free.
    -- Resolve each build-dep's dir via pkginfo.build_dep — the version is already
    -- resolved by xlings from the build_deps DECLARATION (via XLINGS_BUILDDEP_*_PATH),
    -- so NO version is hardcoded in this install() code. Returns {path,bin,include,lib}.
    -- NOTE: distinct var names (…_bd) so they don't shadow the `gcc`/`gxx` tool
    -- strings used for -DCMAKE_C_COMPILER above.
    -- LINUX ONLY: gcc's specs don't wire the build-time glibc/kernel-header search;
    -- provide it host-free via LIBRARY_PATH + -idirafter. macOS clang locates the
    -- system SDK on its own (via the default -isysroot), so no such wiring there.
    local libenv = ""
    if isMac then
        -- macOS: xim:llvm's clang is a slim, relocatable toolchain that does NOT
        -- bake in a default sysroot the way Xcode's /usr/bin/clang does. Point it at
        -- the active SDK so <stdio.h>/frameworks resolve. xcrun is present on the
        -- runner; the command substitution runs inside the build's bash.
        --
        -- Build OpenCV against the SDK's APPLE libc++ headers, not xim:llvm's
        -- bundled LLVM-20 ones. The skew: xim:llvm's clang uses its own LLVM-20
        -- libc++ headers (found toolchain-relative at <llvm>/include/c++/v1, even
        -- without the cfg's -isystem) where std::__1::__hash_memory is UNCONDITIONAL,
        -- but the final link resolves libc++ against the runner's Apple system
        -- libc++ dylib, which lacks that symbol -> undefined at the consumer link
        -- (OpenCV's unordered_map<string,…> in persistence.cpp/logtagmanager.cpp).
        --   --no-default-config  drop the cfg's -isystem <llvm libc++> (+ --sysroot;
        --                        SDKROOT below re-supplies the sysroot),
        --   -nostdinc++          drop clang's toolchain-relative libc++ headers,
        --   -isystem $SDKROOT/usr/include/c++/v1  use Apple's libc++ headers, which
        --                        DO carry availability guards; paired with the
        --                        CMAKE_OSX_DEPLOYMENT_TARGET=14.0 pin (< 14.4, where
        --                        Apple added out-of-line __hash_memory) the guard
        --                        selects the inline hash path -> no external symbol.
        -- -nostdinc++ is C++-only (CXXFLAGS); C HAL files use the SDK libc as usual.
        libenv = "export SDKROOT=\"$(xcrun --show-sdk-path)\" && "
               .. "export CFLAGS=\"--no-default-config\" "
               .. "CXXFLAGS=\"--no-default-config -nostdinc++ "
               .. "-isystem $SDKROOT/usr/include/c++/v1\" && "
    elseif isWin then
        -- Windows: clang-cl autodetects the MSVC toolchain + Windows SDK from the
        -- registry, so no build-time env wiring is needed (libenv stays empty). The
        -- cmake build is driven through cmd, not bash (see the exec branch below).
        libenv = ""
    else
        local glibc_bd = pkginfo.build_dep("glibc")
        local gcc_bd   = pkginfo.build_dep("gcc")
        local kern_bd  = pkginfo.build_dep("linux-headers")
        local libpaths, incpaths = {}, {}
        if glibc_bd then
            if os.isdir(glibc_bd.lib)     then table.insert(libpaths, glibc_bd.lib) end
            if os.isdir(glibc_bd.include) then table.insert(incpaths, glibc_bd.include) end
        end
        if gcc_bd then  -- libgcc_s lives in gcc's lib64
            local gcc_lib64 = path.join(gcc_bd.path, "lib64")
            if os.isdir(gcc_lib64) then table.insert(libpaths, gcc_lib64) end
        end
        if kern_bd and os.isdir(kern_bd.include) then table.insert(incpaths, kern_bd.include) end
        if #libpaths == 0 or #incpaths == 0 then
            error("compat.opencv: cannot resolve xim:glibc / xim:gcc / xim:linux-headers dirs for the build env")
        end
        -- Headers via -idirafter, NOT CPATH: gcc's C++ headers do
        -- `#include_next <stdlib.h>` which searches dirs AFTER gcc's own include dir;
        -- CPATH injects them early (like -I) so #include_next skips right past them.
        -- -idirafter appends at the END of the search — where system headers belong.
        local idflags = {}
        for _, d in ipairs(incpaths) do table.insert(idflags, "-idirafter " .. d) end
        local incflags = table.concat(idflags, " ")
        libenv = "export LIBRARY_PATH=" .. sh_quote(table.concat(libpaths, ":"))
               .. " CFLAGS="   .. sh_quote(incflags)
               .. " CXXFLAGS=" .. sh_quote(incflags) .. " && "
    end

    -- Move the extracted tree INTO the install dir (this CREATES prefix — xim's
    -- restricted Lua has no os.mkdir; os.cd is the only dir primitive, same as
    -- compat.openblas). Then build out-of-source into ./_bld and install
    -- headers+libs back into prefix, which is now the cwd.
    os.tryrm(prefix)
    os.mv(srcroot, prefix)
    os.cd(prefix)

    local logf = path.join(prefix, "mcpp_opencv_build.log")

    -- Value quoting differs by driver: the linux/macOS build runs through bash
    -- (sh_quote), Windows through cmd (see the exec branch) where single quotes
    -- would reach cmake LITERALLY — so pass values bare there. Runner paths carry
    -- no spaces, so bare is safe. cmake also wants forward slashes in -D paths on
    -- Windows (a trailing backslash escapes the closing quote in the cache).
    local function q(v) return isWin and tostring(v) or sh_quote(v) end
    local cmake_prefix = isWin and tostring(prefix):gsub("\\", "/") or prefix

    -- Curated, fully-offline profile: core+imgproc+imgcodecs, bundled zlib/png/jpeg,
    -- everything downloadable or host-dependent OFF (WITH_ADE=OFF kills the only
    -- configure-time fetch). Ninja generator + the resolved build-dep tools.
    -- CMAKE_POLICY_VERSION_MINIMUM=3.5 lets CMake 4.x parse OpenCV's (and its
    -- 3rdparty's) old cmake_minimum_required.
    local dflags = table.concat({
        "-G", q("Ninja"),
        "-DCMAKE_MAKE_PROGRAM=" .. q(make),
        "-DCMAKE_C_COMPILER=" .. q(gcc),
        "-DCMAKE_CXX_COMPILER=" .. q(gxx),
        "-DCMAKE_BUILD_TYPE=Release",
        "-DCMAKE_INSTALL_PREFIX=" .. q(cmake_prefix),
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
        "-DBUILD_LIST=core,imgproc,imgcodecs",
        "-DBUILD_SHARED_LIBS=OFF -DENABLE_PIC=ON",
        "-DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_EXAMPLES=OFF",
        "-DBUILD_opencv_apps=OFF -DBUILD_opencv_python3=OFF -DBUILD_JAVA=OFF",
        "-DBUILD_opencv_python_bindings_generator=OFF -DBUILD_opencv_js=OFF",
        -- Skip Python detection entirely (we build no bindings). Without this,
        -- OpenCVDetectPython finds xlings' python3 shim, reads an EMPTY version
        -- string, and calls find_package with an invalid "OFF" argument -> a hard
        -- CMake configure error. OPENCV_PYTHON_SKIP_DETECTION makes the module
        -- return() before any find_python.
        "-DOPENCV_PYTHON_SKIP_DETECTION=ON",
        "-DBUILD_ZLIB=ON -DBUILD_PNG=ON -DBUILD_JPEG=ON",
        "-DWITH_PNG=ON -DWITH_JPEG=ON",
        -- Disable the arm64 NEON HALs (both default-ON on Apple Silicon): carotene
        -- (libtegra_hal.a, carotene_o4t::*) and KleidiCV (kleidicv::hal::*). OpenCV's
        -- core/imgproc emit direct calls into whichever HAL is enabled, but those
        -- static HAL archives aren't in our curated link set, so the consumer link
        -- fails with undefined HAL symbols. Off => baseline C++ path, no extra
        -- platform-specific static lib to carry.
        "-DWITH_CAROTENE=OFF -DWITH_KLEIDICV=OFF",
        "-DWITH_ADE=OFF -DWITH_IPP=OFF -DWITH_ITT=OFF -DWITH_TBB=OFF -DWITH_OPENMP=OFF",
        -- WITH_LAPACK=OFF: on macOS OpenCV auto-finds the Accelerate framework and
        -- emits cblas_*/sgesv_/… calls into it; core's built-in fallback is used
        -- instead, so the consumer needn't link Accelerate (host-free, minimal set).
        "-DWITH_LAPACK=OFF",
        "-DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_EIGEN=OFF -DWITH_PROTOBUF=OFF",
        "-DWITH_FFMPEG=OFF -DWITH_GTK=OFF -DWITH_QT=OFF -DWITH_GSTREAMER=OFF",
        "-DWITH_V4L=OFF -DWITH_1394=OFF -DWITH_TIFF=OFF -DWITH_WEBP=OFF",
        "-DWITH_OPENJPEG=OFF -DWITH_JASPER=OFF -DWITH_OPENEXR=OFF -DWITH_GDAL=OFF",
        "-DWITH_GDCM=OFF -DBUILD_opencv_world=OFF",
        "-DOPENCV_GENERATE_PKGCONFIG=OFF -DINSTALL_CREATE_DISTRIB=OFF",
        -- macOS: pin the deployment target to the consumer's (14.0). Apple's libc++
        -- added the out-of-line std::__1::__hash_memory at macOS 14.4; building at
        -- the SDK's default (15.0) makes its availability-guarded headers EMIT it,
        -- but the runtime libc++ linked at the consumer's min (14.0) lacks it ->
        -- undefined symbol. Targeting 14.0 (< 14.4) makes the guard pick the INLINE
        -- hash path, so no external symbol is emitted; also silences the "object
        -- version 15.0 newer than target minimum 14.0" link warnings. Empty on
        -- Linux (this var expands to nothing there).
        isMac and "-DCMAKE_OSX_DEPLOYMENT_TARGET=14.0" or "",
        -- Windows: normalise OpenCV's install layout to the linux/macOS shape so the
        -- one set of ldflags (`-Llib …`) + artifact checks work everywhere — drop
        -- the default x64/vc17 binaries prefix and the version suffix on lib names
        -- (opencv_core.lib, not opencv_core4130.lib), and put static libs under lib/
        -- + 3rdparty under lib/opencv4/3rdparty + headers under include/opencv4.
        -- BUILD_WITH_STATIC_CRT=ON builds against the STATIC CRT (/MT) — mcpp's
        -- clang-cl consumer compiles its objects /MT (roundtrip.o = MT_StaticRelease),
        -- so OpenCV must match or the link fails LNK2038 (MD vs MT RuntimeLibrary
        -- mismatch). /MT is also OpenCV's Windows default. Expands to nothing off
        -- Windows.
        isWin and ("-DOPENCV_INSTALL_BINARIES_PREFIX= "
                .. "-DOPENCV_LIB_INSTALL_PATH=lib "
                .. "-DOPENCV_3P_LIB_INSTALL_PATH=lib/opencv4/3rdparty "
                .. "-DOPENCV_INCLUDE_INSTALL_PATH=include/opencv4 "
                .. "-DOPENCV_DLLVERSION= "
                .. "-DBUILD_WITH_STATIC_CRT=ON") or "",
    }, " ")

    if isWin then
        -- No bash on a bare Windows runner; drive cmake through cmd, which also
        -- gives the `>` redirect for the on-disk log. cwd is already `prefix`
        -- (os.cd above), so `-S .` resolves here. clang-cl finds MSVC + the Windows
        -- SDK itself, so no toolchain env (libenv is empty). Values in dflags are
        -- bare (see q()), so the whole cmake line sits inside one cmd `"..."` arg.
        os.exec(string.format('cmd /c "%s -S . -B _bld %s > %s 2>&1"',
            cmake, dflags, logf))
        os.exec(string.format('cmd /c "%s --build _bld -j%d >> %s 2>&1"',
            cmake, jobs, logf))
        os.exec(string.format('cmd /c "%s --install _bld >> %s 2>&1"',
            cmake, logf))
    else
        os.exec(string.format("bash -c %s", sh_quote(string.format(
            "cd %s && %s%s -S . -B _bld %s > %s 2>&1",
            sh_quote(prefix), libenv, sh_quote(cmake), dflags, sh_quote(logf)))))
        os.exec(string.format("bash -c %s", sh_quote(string.format(
            "cd %s && %s%s --build _bld -j%d >> %s 2>&1",
            sh_quote(prefix), libenv, sh_quote(cmake), jobs, sh_quote(logf)))))
        os.exec(string.format("bash -c %s", sh_quote(string.format(
            "cd %s && %s%s --install _bld >> %s 2>&1",
            sh_quote(prefix), libenv, sh_quote(cmake), sh_quote(logf)))))
    end

    -- Verify BOTH the static libs AND the installed public headers materialised
    -- (exit-0 != correct; and a partial install that lays libs but not headers at
    -- include/opencv4 would slip past a libs-only check, then fail the consumer
    -- compile with a bare "opencv2/core.hpp: No such file").
    -- Static-lib file names differ: linux/macOS `libopencv_core.a`, Windows (MSVC
    -- clang-cl, version suffix dropped above) `opencv_core.lib`.
    local function slib(n) return isWin and (n .. ".lib") or ("lib" .. n .. ".a") end
    local must = {
        path.join(prefix, "lib", slib("opencv_core")),
        path.join(prefix, "lib", slib("opencv_imgproc")),
        path.join(prefix, "lib", slib("opencv_imgcodecs")),
        path.join(prefix, "include", "opencv4", "opencv2", "core.hpp"),
        path.join(prefix, "include", "opencv4", "opencv2", "imgproc.hpp"),
        path.join(prefix, "include", "opencv4", "opencv2", "imgcodecs.hpp"),
    }
    for _, m in ipairs(must) do
        if not os.isfile(m) then
            log.error("compat.opencv: expected artifact missing: %s (see %s)", m, logf)
            return false
        end
    end

    os.tryrm(path.join(prefix, "_bld"))  -- discard the (large) build tree
    -- Emit the anchor TU mcpp compiles; its absence is what triggered this build.
    io.writefile(path.join(prefix, "mcpp_opencv_anchor.c"),
                 "int mcpp_compat_opencv_anchor(void) { return 0; }\n")
    return true
end

function install()
    local ok, ret = pcall(_install_impl)
    if not ok or ret == false then
        -- Point at the on-disk build log: xim's interface mode suppresses the
        -- cmake subprocess stdout, so the log is the only record of a failed
        -- source build (the compat.openblas pattern).
        local logf = path.join(pkginfo.install_dir(), "mcpp_opencv_build.log")
        log.error("compat.opencv install() failed (%s); see %s",
                  ok and "returned false" or tostring(ret), logf)
        return false
    end
    return true
end
