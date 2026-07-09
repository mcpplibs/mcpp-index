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
-- xim:make, xim:gcc (declared build-deps) — never host cmake/make/gcc. Verified
-- offline under a network-isolated namespace (unshare -rn): zero downloads (gapi's
-- ADE fetch is killed by WITH_ADE=OFF); everything else is compiled from the
-- tarball's bundled 3rdparty/ (zlib + libpng + libjpeg-turbo built via BUILD_*=ON).
--
-- MVP module set (this recipe): core + imgproc + imgcodecs (BUILD_LIST). This is a
-- fixed, curated profile — OpenCV's WITH_*/BUILD_opencv_* toggles CANNOT be mcpp
-- `features` (a feature carries only implies/sources/defines/requires/provides/deps,
-- not cflags/include_dirs/generated_files, and cannot parametrise install()). Larger
-- variants (calib3d/dnn/highgui/contrib) are separate follow-up packages, not
-- per-consumer features. See the impl doc §"generic mcpp asks".
--
-- ABI: OpenCV is C++, so its .a must be linked by the SAME C++ ABI (libstdc++) as
-- the consumer. install() builds with xim:gcc (gcc/libstdc++); the consumer must use
-- a gcc toolchain (the test project pins gcc@16.1.0). A clang/libc++ consumer would
-- ABI-clash — this is the toolchain-handshake gap noted in the impl doc.
--
-- Verified locally (mcpp 0.0.85, linux x86_64): build → link → run green
-- (opencv ok=1 core=4x4x3 gray(blue)=29 png_bytes=82 decoded=4x4). macOS follows the
-- same source-CMake path but is NOT yet verified — its default toolchain is clang
-- (libc++), which would ABI-clash with the gcc/libstdc++ .a this recipe builds
-- (the toolchain-handshake gap); making macOS use gcc, or building with the
-- consumer's compiler, is a follow-up. Windows (MSVC-ABI clang vs OpenCV CMake) is
-- likewise a follow-up. The test project is therefore LINUX-GATED for now
-- (gui-stack precedent): off-linux it is a clean no-op.
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
            deps = { "xim:cmake@4.0.2", "xim:make@latest", "xim:gcc@16.1.0",
                     "xim:glibc@2.39", "xim:linux-headers@5.11.1" },
            ["4.13.0"] = {
                -- Plain-string GLOBAL url (no CN mirror table): this session lacks
                -- mcpp-res write access. Per the add-package skill, CN users fall
                -- back to GLOBAL and a maintainer adds the gitcode mirror later
                -- (repo `mcpp-res/opencv`, asset `opencv-4.13.0.tar.gz`).
                url    = "https://github.com/opencv/opencv/archive/refs/tags/4.13.0.tar.gz",
                sha256 = "1d40ca017ea51c533cf9fd5cbde5b5fe7ae248291ddf2af99d4c17cf8e13017d",
            },
        },
        macosx = {
            deps = { "xim:cmake@4.0.2", "xim:make@latest", "xim:gcc@16.1.0" },
            ["4.13.0"] = {
                -- Plain-string GLOBAL url (no CN mirror table): this session lacks
                -- mcpp-res write access. Per the add-package skill, CN users fall
                -- back to GLOBAL and a maintainer adds the gitcode mirror later
                -- (repo `mcpp-res/opencv`, asset `opencv-4.13.0.tar.gz`).
                url    = "https://github.com/opencv/opencv/archive/refs/tags/4.13.0.tar.gz",
                sha256 = "1d40ca017ea51c533cf9fd5cbde5b5fe7ae248291ddf2af99d4c17cf8e13017d",
            },
        },
        windows = {
            -- Source tarball declared for index completeness + CN mirror coverage.
            -- The install() CMake build on Windows (MSVC-ABI clang mcpp links with)
            -- is a documented follow-up; the test project excludes Windows for now.
            ["4.13.0"] = {
                -- Plain-string GLOBAL url (no CN mirror table): this session lacks
                -- mcpp-res write access. Per the add-package skill, CN users fall
                -- back to GLOBAL and a maintainer adds the gitcode mirror later
                -- (repo `mcpp-res/opencv`, asset `opencv-4.13.0.tar.gz`).
                url    = "https://github.com/opencv/opencv/archive/refs/tags/4.13.0.tar.gz",
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
        windows = {
            -- No source build wired on Windows yet; provide the anchor directly so
            -- mcpp is self-sufficient here and never triggers the (unimplemented)
            -- Windows install() build. Consumers target non-Windows for now.
            generated_files = {
                ["mcpp_opencv_anchor.c"] = "int mcpp_compat_opencv_anchor(void) { return 0; }\n",
            },
        },
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
    local cmake, make, gcc, gxx = "cmake", "make", "gcc", "g++"

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
    local glibc_dir = pkginfo.install_dir("xim:glibc", "2.39")
                   or pkginfo.install_dir("glibc", "2.39")
    local gcc_dir   = pkginfo.install_dir("xim:gcc", "16.1.0")
                   or pkginfo.install_dir("gcc", "16.1.0")
    local kern_dir  = pkginfo.install_dir("xim:linux-headers", "5.11.1")
                   or pkginfo.install_dir("scode:linux-headers", "5.11.1")
                   or pkginfo.install_dir("linux-headers", "5.11.1")
    local libpaths, incpaths = {}, {}
    if glibc_dir then table.insert(libpaths, path.join(glibc_dir, "lib"))
                      table.insert(incpaths, path.join(glibc_dir, "include")) end
    if gcc_dir   then table.insert(libpaths, path.join(gcc_dir, "lib64")) end
    if kern_dir  then table.insert(incpaths, path.join(kern_dir, "include")) end
    if #libpaths == 0 or #incpaths == 0 then
        error("compat.opencv: cannot resolve xim:glibc / xim:gcc / xim:linux-headers dirs for the build env")
    end
    local libenv = "export LIBRARY_PATH=" .. sh_quote(table.concat(libpaths, ":"))
                 .. " CPATH=" .. sh_quote(table.concat(incpaths, ":")) .. " && "

    -- Move the extracted tree INTO the install dir (this CREATES prefix — xim's
    -- restricted Lua has no os.mkdir; os.cd is the only dir primitive, same as
    -- compat.openblas). Then build out-of-source into ./_bld and install
    -- headers+libs back into prefix, which is now the cwd.
    os.tryrm(prefix)
    os.mv(srcroot, prefix)
    os.cd(prefix)

    local logf = path.join(prefix, "mcpp_opencv_build.log")

    -- Curated, fully-offline profile: core+imgproc+imgcodecs, bundled zlib/png/jpeg,
    -- everything downloadable or host-dependent OFF (WITH_ADE=OFF kills the only
    -- configure-time fetch). Unix Makefiles generator + the resolved build-dep
    -- tools. CMAKE_POLICY_VERSION_MINIMUM=3.5 lets CMake 4.x parse OpenCV's (and
    -- its 3rdparty's) old cmake_minimum_required.
    local dflags = table.concat({
        "-G", sh_quote("Unix Makefiles"),
        "-DCMAKE_MAKE_PROGRAM=" .. sh_quote(make),
        "-DCMAKE_C_COMPILER=" .. sh_quote(gcc),
        "-DCMAKE_CXX_COMPILER=" .. sh_quote(gxx),
        "-DCMAKE_BUILD_TYPE=Release",
        "-DCMAKE_INSTALL_PREFIX=" .. sh_quote(prefix),
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
        "-DWITH_ADE=OFF -DWITH_IPP=OFF -DWITH_ITT=OFF -DWITH_TBB=OFF -DWITH_OPENMP=OFF",
        "-DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_EIGEN=OFF -DWITH_PROTOBUF=OFF",
        "-DWITH_FFMPEG=OFF -DWITH_GTK=OFF -DWITH_QT=OFF -DWITH_GSTREAMER=OFF",
        "-DWITH_V4L=OFF -DWITH_1394=OFF -DWITH_TIFF=OFF -DWITH_WEBP=OFF",
        "-DWITH_OPENJPEG=OFF -DWITH_JASPER=OFF -DWITH_OPENEXR=OFF -DWITH_GDAL=OFF",
        "-DWITH_GDCM=OFF -DBUILD_opencv_world=OFF",
        "-DOPENCV_GENERATE_PKGCONFIG=OFF -DINSTALL_CREATE_DISTRIB=OFF",
    }, " ")

    os.exec(string.format("bash -c %s", sh_quote(string.format(
        "cd %s && %s%s -S . -B _bld %s > %s 2>&1",
        sh_quote(prefix), libenv, sh_quote(cmake), dflags, sh_quote(logf)))))
    os.exec(string.format("bash -c %s", sh_quote(string.format(
        "cd %s && %s%s --build _bld -j%d >> %s 2>&1",
        sh_quote(prefix), libenv, sh_quote(cmake), jobs, sh_quote(logf)))))
    os.exec(string.format("bash -c %s", sh_quote(string.format(
        "cd %s && %s%s --install _bld >> %s 2>&1",
        sh_quote(prefix), libenv, sh_quote(cmake), sh_quote(logf)))))

    -- Verify BOTH the static libs AND the installed public headers materialised
    -- (exit-0 != correct; and a partial install that lays libs but not headers at
    -- include/opencv4 would slip past a libs-only check, then fail the consumer
    -- compile with a bare "opencv2/core.hpp: No such file").
    local must = {
        path.join(prefix, "lib", "libopencv_core.a"),
        path.join(prefix, "lib", "libopencv_imgproc.a"),
        path.join(prefix, "lib", "libopencv_imgcodecs.a"),
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

-- Surface the on-disk build log to the console on ANY failure. xim's interface
-- mode suppresses the cmake/make subprocess stdout, so without this a failed CI
-- build is invisible (the only symptom is the downstream "opencv2/core.hpp: No
-- such file"). Fires whether _install_impl raised or returned false.
local function _dump_diagnostics(raised, err)
    if raised then
        log.error("compat.opencv install() raised: %s", tostring(err))
    end
    local logf = path.join(pkginfo.install_dir(), "mcpp_opencv_build.log")
    if os.isfile(logf) then
        log.error("---- mcpp_opencv_build.log ----\n%s", tostring(io.readfile(logf)))
    else
        log.error("compat.opencv: no build log at %s", logf)
        log.error("compat.opencv: PATH=%s", tostring(os.getenv("PATH")))
    end
end

function install()
    if os.host() == "windows" then
        -- Windows uses the generated_files anchor; source build is a follow-up.
        return true
    end
    local ok, ret = pcall(_install_impl)
    if not ok or ret == false then
        _dump_diagnostics(not ok, ret)
        return false
    end
    return true
end
