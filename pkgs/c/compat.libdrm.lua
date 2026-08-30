-- compat.libdrm — libdrm, built from source.
--
-- The userspace side of the kernel DRM/KMS interface: `drmModeGetResources`,
-- `drmModeAddFB2`, `drmModeSetCrtc`, `drmPrimeHandleToFD`. It is the layer
-- under compat.libgbm — GBM allocates the buffer, this turns it into a scanout.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: A SOURCE BUILD, BECAUSE THE PROJECT IS SEPARABLE
--
-- The index's rule is "build it from source", and the test is whether upstream
-- ships the thing as a separable unit. libdrm PASSES: it is an independent
-- freedesktop project with its own release tarballs, and Conan carries it as a
-- real recipe rather than a `system` virtual package. So it is built here,
-- like the X11 family (compat.x11, compat.xcb, compat.xext, …) that this
-- index already builds beside the same ecosystem payloads.
--
-- Contrast compat.libgbm, which is NOT separable: GBM is a build target inside
-- Mesa (`src/gbm/meson.build` is `link_with: [libloader]`, and `libloader`
-- pulls `idep_mesautil`), and it is a loader whose backends are Mesa's own.
--
-- Measured surface:
--
--     host          0   no /usr/lib* path, no escape-hatch variable
--     ecosystem     0   nothing — no `xim:*` dependency at all
--     index         0   `deps = {}`
--     transitive    0   the five TUs need only libc; `dep_rt` folds into
--                       glibc and valgrind/udev are compiled out below
--
-- ─────────────────────────────────────────────────────────────────────────
-- 2.4.134 — THE CURRENT UPSTREAM RELEASE, AND NEWER THAN THE PAYLOAD'S
--
-- `xim:mesa` pulls `xim:libdrm` at 2.4.123. Being ahead of it is fine and is
-- what the soname is for: libdrm has kept `libdrm.so.2` since 2012 and is
-- backward compatible within it, so Mesa — built against 2.4.123 — binds to
-- this one and works. That is the direction a distribution upgrade moves too.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY `kind = "shared"` WITH A SONAME IS LOAD-BEARING
--
-- Mesa is normally in the same process — `xim:mesa` declares `xim:libdrm`, and
-- seven libraries in its payload carry DT_NEEDED on `libdrm.so.2`, including
-- the `libgbm.so.1` that compat.libgbm delivers. Those Mesa libraries also
-- carry an ABSOLUTE RUNPATH naming `xim-x-libdrm/<ver>/lib`.
--
-- That RUNPATH does NOT decide the outcome, and the distinction is the whole
-- reason a source build is safe here. A DT_NEEDED soname already present in
-- the link map is REUSED — ld.so never searches for it again, so it never
-- consults Mesa's RUNPATH. The consumer links this library directly, so it is
-- mapped first, and Mesa's libgbm then binds to it. Measured: in a real
-- consumer process `libdrm.so.2` resolves to the consumer's path, while the
-- same libgbm.so.1 examined ALONE resolves to the payload's.
--
-- This only holds if the soname matches. Built `kind = "lib"` — this index's
-- default, objects merged into the consumer — there is no `libdrm.so.2` to
-- reuse: Mesa loads the payload copy and the consumer keeps its own merged
-- one, so libdrm's file-static state (`drmHashTable`, `nr_fds`, `connection`,
-- `drm_server_info` are all OBJECTs in its .bss) exists twice over one set of
-- fds. Shared, with the canonical soname, there is exactly one.
--
-- Same shape and same reason as compat.vulkan's loader and the X11 family.
--
-- ─────────────────────────────────────────────────────────────────────────
-- TWO INCLUDE ROOTS, AND THIS IS THE ONE THING THAT BITES
--
-- libdrm keeps its public headers at the source ROOT (`xf86drm.h`,
-- `xf86drmMode.h`, `libsync.h`) and the uapi headers those include in
-- `include/drm/` (`drm.h`, `drm_mode.h`, `drm_fourcc.h`, …) — upstream installs
-- the second set into `<prefix>/include/libdrm/` and puts BOTH on the pkg-config
-- include path. `xf86drm.h` line 40 is a bare `#include <drm.h>`, so a consumer
-- given only the root cannot compile a single translation unit.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE BUILD, TRANSCRIBED FROM meson.build
--
-- Upstream force-includes a generated `config.h` (`add_project_arguments(
-- '-include', … / 'config.h')`). The five core TUs read exactly five entries
-- from it, so they are passed as `-D` instead of shipping a header — with one
-- trap: `MAJOR_IN_MKDEV` and `MAJOR_IN_SYSMACROS` are tested with `#ifdef`,
-- not `#if`, so the MKDEV one must be ABSENT rather than defined to 0.
-- `HAVE_SYS_SYSCTL_H` and `UDEV` are `#if`, so they must be present and zero.
--
-- The one genuinely generated file is `generated_static_table_fourcc.h`, from
-- `gen_table_fourcc.py` from `include/drm/drm_fourcc.h`. It is not in the
-- release tarball, it is 58 lines of table, and `xf86drm.c` includes it in
-- QUOTE form — so it is inlined below into the source root, where the quoted
-- lookup finds it without adding any include path.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libdrm",
    description = "libdrm — userspace DRM/KMS interface, built from the upstream release",
    licenses    = {"MIT"},
    repo        = "https://gitlab.freedesktop.org/mesa/drm",
    type        = "package",

    xpm = {
        linux = {
            ["2.4.134"] = {
                url = {
                    GLOBAL = "https://dri.freedesktop.org/libdrm/libdrm-2.4.134.tar.xz",
                    CN     = "https://gitcode.com/mcpp-res/libdrm/releases/download/2.4.134/libdrm-2.4.134.tar.xz",
                },
                sha256 = "ac5e74d157830eb8bee44c6a6bf3ad49774ef0dd2a72bdad74a8f20308b52a95",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c11",

        -- `c_standard = "gnu11"` is accepted and silently emits -std=c11, so
        -- _GNU_SOURCE has to be spelled out. Without it O_CLOEXEC, `asprintf`
        -- and `major`/`minor` are hidden and xf86drm.c does not compile.
        -- -fPIC because this becomes a .so; -fvisibility=hidden to match
        -- upstream's `gnu_symbol_visibility : 'hidden'`, so only the symbols
        -- libdrm_macros.h marks drm_public are exported.
        cflags = {
            "-D_GNU_SOURCE",
            "-DHAVE_VISIBILITY=1",
            "-DHAVE_SYS_SYSCTL_H=0",
            "-DMAJOR_IN_SYSMACROS=1",
            "-DUDEV=0",
            "-fPIC",
            "-fvisibility=hidden",
        },

        -- Both roots; see the header comment. `mcpp/include` is the copy
        -- install() makes of the three root headers, mirroring what upstream
        -- puts in `<prefix>/include`; `include/drm` is upstream's
        -- `<prefix>/include/libdrm` and is needed by the BUILD too, because
        -- xf86drm.c includes "drm_fourcc.h" in quote form from the root.
        include_dirs = {
            "mcpp/include",
            "include/drm",
        },

        -- meson.build's `libdrm_files`, verbatim.
        sources = {
            "xf86drm.c",
            "xf86drmHash.c",
            "xf86drmRandom.c",
            "xf86drmSL.c",
            "xf86drmMode.c",
        },

        targets = { ["drm"] = { kind = "shared", soname = "libdrm.so.2" } },
        deps    = {},

        generated_files = {
            ["generated_static_table_fourcc.h"] =
[[
/* AUTOMATICALLY GENERATED by gen_table_fourcc.py. You should modify
   that script instead of adding here entries manually! */
static const struct drmFormatModifierInfo drm_format_modifier_table[] = {
    { DRM_MODIFIER_INVALID(NONE, INVALID) },
    { DRM_MODIFIER_LINEAR(NONE, LINEAR) },
    { DRM_MODIFIER_INTEL(X_TILED, X_TILED) },
    { DRM_MODIFIER_INTEL(Y_TILED, Y_TILED) },
    { DRM_MODIFIER_INTEL(Yf_TILED, Yf_TILED) },
    { DRM_MODIFIER_INTEL(Y_TILED_CCS, Y_TILED_CCS) },
    { DRM_MODIFIER_INTEL(Yf_TILED_CCS, Yf_TILED_CCS) },
    { DRM_MODIFIER_INTEL(Y_TILED_GEN12_RC_CCS, Y_TILED_GEN12_RC_CCS) },
    { DRM_MODIFIER_INTEL(Y_TILED_GEN12_MC_CCS, Y_TILED_GEN12_MC_CCS) },
    { DRM_MODIFIER_INTEL(Y_TILED_GEN12_RC_CCS_CC, Y_TILED_GEN12_RC_CCS_CC) },
    { DRM_MODIFIER_INTEL(4_TILED, 4_TILED) },
    { DRM_MODIFIER_INTEL(4_TILED_DG2_RC_CCS, 4_TILED_DG2_RC_CCS) },
    { DRM_MODIFIER_INTEL(4_TILED_DG2_MC_CCS, 4_TILED_DG2_MC_CCS) },
    { DRM_MODIFIER_INTEL(4_TILED_DG2_RC_CCS_CC, 4_TILED_DG2_RC_CCS_CC) },
    { DRM_MODIFIER_INTEL(4_TILED_MTL_RC_CCS, 4_TILED_MTL_RC_CCS) },
    { DRM_MODIFIER_INTEL(4_TILED_MTL_MC_CCS, 4_TILED_MTL_MC_CCS) },
    { DRM_MODIFIER_INTEL(4_TILED_MTL_RC_CCS_CC, 4_TILED_MTL_RC_CCS_CC) },
    { DRM_MODIFIER_INTEL(4_TILED_LNL_CCS, 4_TILED_LNL_CCS) },
    { DRM_MODIFIER_INTEL(4_TILED_BMG_CCS, 4_TILED_BMG_CCS) },
    { DRM_MODIFIER(SAMSUNG, 64_32_TILE, 64_32_TILE) },
    { DRM_MODIFIER(SAMSUNG, 16_16_TILE, 16_16_TILE) },
    { DRM_MODIFIER(QCOM, COMPRESSED, COMPRESSED) },
    { DRM_MODIFIER(QCOM, TILED3, TILED3) },
    { DRM_MODIFIER(QCOM, TILED2, TILED2) },
    { DRM_MODIFIER(VIVANTE, TILED, TILED) },
    { DRM_MODIFIER(VIVANTE, SUPER_TILED, SUPER_TILED) },
    { DRM_MODIFIER(VIVANTE, SPLIT_TILED, SPLIT_TILED) },
    { DRM_MODIFIER(VIVANTE, SPLIT_SUPER_TILED, SPLIT_SUPER_TILED) },
    { DRM_MODIFIER(NVIDIA, TEGRA_TILED, TEGRA_TILED) },
    { DRM_MODIFIER(NVIDIA, 16BX2_BLOCK_ONE_GOB, 16BX2_BLOCK_ONE_GOB) },
    { DRM_MODIFIER(NVIDIA, 16BX2_BLOCK_TWO_GOB, 16BX2_BLOCK_TWO_GOB) },
    { DRM_MODIFIER(NVIDIA, 16BX2_BLOCK_FOUR_GOB, 16BX2_BLOCK_FOUR_GOB) },
    { DRM_MODIFIER(NVIDIA, 16BX2_BLOCK_EIGHT_GOB, 16BX2_BLOCK_EIGHT_GOB) },
    { DRM_MODIFIER(NVIDIA, 16BX2_BLOCK_SIXTEEN_GOB, 16BX2_BLOCK_SIXTEEN_GOB) },
    { DRM_MODIFIER(NVIDIA, 16BX2_BLOCK_THIRTYTWO_GOB, 16BX2_BLOCK_THIRTYTWO_GOB) },
    { DRM_MODIFIER(BROADCOM, VC4_T_TILED, VC4_T_TILED) },
    { DRM_MODIFIER(BROADCOM, SAND32, SAND32) },
    { DRM_MODIFIER(BROADCOM, SAND64, SAND64) },
    { DRM_MODIFIER(BROADCOM, SAND128, SAND128) },
    { DRM_MODIFIER(BROADCOM, SAND256, SAND256) },
    { DRM_MODIFIER(BROADCOM, UIF, UIF) },
    { DRM_MODIFIER(ARM, 16X16_BLOCK_U_INTERLEAVED, 16X16_BLOCK_U_INTERLEAVED) },
    { DRM_MODIFIER(ARM, INTERLEAVED_64K, INTERLEAVED_64K) },
    { DRM_MODIFIER(ALLWINNER, TILED, TILED) },
    { DRM_MODIFIER(APPLE, GPU_TILED, GPU_TILED) },
    { DRM_MODIFIER(APPLE, GPU_TILED_COMPRESSED, GPU_TILED_COMPRESSED) },
};
static const struct drmFormatModifierVendorInfo drm_format_modifier_vendor_table[] = {
    { DRM_FORMAT_MOD_VENDOR_NONE, "NONE" },
    { DRM_FORMAT_MOD_VENDOR_INTEL, "INTEL" },
    { DRM_FORMAT_MOD_VENDOR_AMD, "AMD" },
    { DRM_FORMAT_MOD_VENDOR_NVIDIA, "NVIDIA" },
    { DRM_FORMAT_MOD_VENDOR_SAMSUNG, "SAMSUNG" },
    { DRM_FORMAT_MOD_VENDOR_QCOM, "QCOM" },
    { DRM_FORMAT_MOD_VENDOR_VIVANTE, "VIVANTE" },
    { DRM_FORMAT_MOD_VENDOR_BROADCOM, "BROADCOM" },
    { DRM_FORMAT_MOD_VENDOR_ARM, "ARM" },
    { DRM_FORMAT_MOD_VENDOR_ALLWINNER, "ALLWINNER" },
    { DRM_FORMAT_MOD_VENDOR_AMLOGIC, "AMLOGIC" },
    { DRM_FORMAT_MOD_VENDOR_MTK, "MTK" },
    { DRM_FORMAT_MOD_VENDOR_APPLE, "APPLE" },
};
]],
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

-- A `.tar.xz` is extracted to a sibling of the install dir rather than into
-- it, so the descriptor has to move it into place — the same three lines
-- compat.xcb, compat.xtrans and compat.xcb-proto open with. Without this the
-- package installs EMPTY: `sources` match nothing, mcpp emits a `c_shared`
-- edge with zero inputs, and the failure surfaces as `/bin/sh: -shared: not
-- found` because the unused `$cc` was never defined.
function install()
    local srcroot = pkginfo.install_file():replace(".tar.xz", "")
    if not os.isdir(srcroot) then
        srcroot = "libdrm-" .. pkginfo.version()
    end
    if not os.isdir(srcroot) then
        log.error("[libdrm] extracted source tree not found (looked for %s)", srcroot)
        return false
    end

    os.tryrm(pkginfo.install_dir())
    os.mv(srcroot, pkginfo.install_dir())

    -- Upstream installs xf86drm.h/xf86drmMode.h/libsync.h into
    -- `<prefix>/include` and include/drm/*.h into `<prefix>/include/libdrm`,
    -- and puts both on the pkg-config include path. The uapi half is already
    -- at `include/drm`; this reproduces the other half so a consumer's
    -- `#include <xf86drm.h>` works without putting the whole source root —
    -- private headers and all — on every consumer's include path.
    local inc = path.join(pkginfo.install_dir(), "mcpp", "include")
    os.mkdir(inc)
    for _, header in ipairs({"xf86drm.h", "xf86drmMode.h", "libsync.h"}) do
        local from = path.join(pkginfo.install_dir(), header)
        if not os.isfile(from) then
            log.error("[libdrm] %s missing from the release tarball", header)
            return false
        end
        os.cp(from, path.join(inc, header))
    end

    return true
end
