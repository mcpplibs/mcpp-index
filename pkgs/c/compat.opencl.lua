-- compat.opencl — the Khronos OpenCL ICD loader, built from source.
--
-- The counterpart of `compat.vulkan`, for the other device API, and it is here
-- for the same reason: `clGetPlatformIDs` and every other entry point is a
-- trampoline the loader owns, which dispatches into whatever ICD (vendor
-- driver) the machine advertises. Headers alone do not link.
--
-- Buildable as a plain source list. Upstream's CMake generates exactly one
-- header, `icd_cmake_config.h`, holding two `#cmakedefine` lines about which
-- spelling of `secure_getenv` the C library has; it is supplied below rather
-- than generated, because the answer for every C library this index targets is
-- the same one.
--
-- THE VENDOR PATH IS COMPILED IN, NOT CONFIGURED. `icd_platform.h` defines
-- `ICD_VENDOR_PATH` as `/etc/OpenCL/vendors` and the loader reads that
-- directory unless `OCL_ICD_VENDORS` names another. So this package finds the
-- HOST's proprietary drivers with no configuration at all, which is the
-- correct default for a driver whose userspace is in ABI lockstep with a
-- kernel module. An open implementation is a payload: `xim:pocl` runs OpenCL
-- on the CPU and needs nothing from the host.
--
-- `OCL_ICD_VENDORS` REPLACES THAT PATH; `OCL_ICD_FILENAMES` ADDS TO IT.
-- `khrIcdOsVendorsEnumerate` (loader/linux/icd_linux.c) first enumerates the
-- colon-separated library list in `OCL_ICD_FILENAMES` and then the vendors
-- directory, so a payload driver announces itself through the list and the
-- machine's own drivers stay visible. `OCL_ICD_VENDORS` is the wrong knob for
-- that: it names ONE directory used INSTEAD of the compiled-in path and would
-- hide the GPU. `xim:pocl` therefore declares `OCL_ICD_FILENAMES` into the
-- subos environment and touches no vendors directory.
--
-- SHARED, with the canonical soname, for the reason `compat.vulkan` records:
-- everything in a process must converge on one loader, and a library that
-- dlopens `libOpenCL.so.1` by name has to land here.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "opencl",
    description = "Khronos OpenCL ICD loader — the library an OpenCL program links",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/KhronosGroup/OpenCL-ICD-Loader",
    type        = "package",

    xpm = {
        linux = {
            ["2026.05.29"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/OpenCL-ICD-Loader/archive/refs/tags/v2026.05.29.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencl/releases/download/2026.05.29/opencl-2026.05.29.tar.gz",
                },
                sha256 = "48fd0c5181db7cd046f4f731d5955694892e10998d49d09ee0d997e7e04fd939",
            },
        },
        macosx = {
            ["2026.05.29"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/OpenCL-ICD-Loader/archive/refs/tags/v2026.05.29.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opencl/releases/download/2026.05.29/opencl-2026.05.29.tar.gz",
                },
                sha256 = "48fd0c5181db7cd046f4f731d5955694892e10998d49d09ee0d997e7e04fd939",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        -- `loader/` for the loader's own headers, `include/` for
        -- `cl_khr_icd2.h`, which upstream keeps beside the public headers it
        -- does not ship (the ICD2 dispatch table is loader-private).
        include_dirs = { "*/loader", "*/include", "mcpp_generated" },

        generated_files = {
            -- Upstream's `icd_cmake_config.h.in` is two `#cmakedefine` lines.
            -- glibc has had `secure_getenv` since 2.17 and musl since 1.1.20;
            -- `__secure_getenv` is the pre-2.17 spelling and is deliberately
            -- absent, so a C library with neither takes the `getenv` fallback
            -- upstream already writes.
            ["mcpp_generated/icd_cmake_config.h"] = [==[
/* Generated in place of upstream's CMake step -- see the descriptor note. */
#pragma once
#define HAVE_SECURE_GETENV
]==],
        },

        sources = {
            "*/loader/icd.c",
            "*/loader/icd_dispatch.c",
            "*/loader/icd_dispatch_generated.c",
            "*/loader/icd_trace.c",
        },

        -- Upstream's OPENCL_COMPILE_DEFINITIONS, minus the layer option.
        -- `CL_ENABLE_LOADER_MANAGED_DISPATCH` is what upstream turns on for a
        -- shared build and off for a static one; this is a shared build.
        cflags = {
            "-DCL_TARGET_OPENCL_VERSION=310",
            "-DCL_NO_NON_ICD_DISPATCH_EXTENSION_PROTOTYPES",
            "-DOPENCL_ICD_LOADER_VERSION_MAJOR=3",
            "-DOPENCL_ICD_LOADER_VERSION_MINOR=1",
            "-DOPENCL_ICD_LOADER_VERSION_REV=0",
            "-DCL_SHARED_BUILD",
            "-DCL_ENABLE_LOADER_MANAGED_DISPATCH",
        },

        targets = { ["opencl"] = { kind = "lib" } },
        deps    = { ["compat.opencl-headers"] = "2026.05.29" },

        linux = {
            targets = { ["opencl"] = { kind = "shared", soname = "libOpenCL.so.1" } },
            sources = {
                "*/loader/linux/icd_linux.c",
                "*/loader/linux/icd_linux_envvars.c",
                "*/loader/linux/icd_linux_library.c",
            },
            cflags = { "-D_GNU_SOURCE" },
            -- Without this the loader reads every vendor manifest and then
            -- fails to dlopen a single driver: an mcpp binary runs under mcpp's
            -- own glibc, whose search path does not include the host's. The
            -- same relation `compat.vulkan` has to `compat.vulkan-runtime`.
            deps = {
                ["compat.opencl-headers"] = "2026.05.29",
                ["compat.opencl-runtime"] = "2026.09.05",
            },
            -- dlopen for the ICDs; pthread for `pthread_once` around the scan.
            ldflags = { "-ldl", "-lpthread" },
            runtime = {
                -- A driver has to match the machine, so it is a capability the
                -- host (or a software payload) provides, not a dependency this
                -- package can express. Same call `compat.vulkan` makes.
                capabilities = { "opencl.icd.driver" },
            },
        },

        macosx = {
            -- The same POSIX sources upstream builds on Apple platforms: the
            -- loader enumerates `/etc/OpenCL/vendors` and `OCL_ICD_FILENAMES`
            -- through dlopen there exactly as on Linux. A macOS runner has no
            -- vendors directory and reports zero platforms, which is the
            -- loader's own answer and what tests/examples/opencl asserts.
            -- Apple's OpenCL framework is not involved: a program that links
            -- this package dispatches through this loader, not the framework.
            -- A STATIC library here, as compat.vulkan is on macOS: a shared
            -- link of a C library under mcpp's macOS toolchain fails on
            -- `std::__1::ios_base::Init::Init()`, and the one-loader-per-
            -- process argument that makes the Linux build shared has no ICD
            -- ecosystem to apply to on this platform.
            sources = {
                "*/loader/linux/icd_linux.c",
                "*/loader/linux/icd_linux_envvars.c",
                "*/loader/linux/icd_linux_library.c",
            },
            ldflags = { "-ldl" },
            runtime = { capabilities = { "opencl.icd.driver" } },
        },
    },
}
