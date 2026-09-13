# 2026-09-13 — add `compat.vulkan-validation-layers`

## Why

A debug build of a Vulkan program asks the loader for `VK_LAYER_KHRONOS_validation`.
On a machine with the layer installed, the loader finds the host manifest under
`/usr/share/vulkan/explicit_layer.d` and then dlopens the library it names by bare
soname. An mcpp-built program runs on the ecosystem's glibc, whose dynamic linker
searches the payloads on the RPATH and never `/usr/lib`, so the dlopen fails and
`vkCreateInstance` errors out (measured on xrgui's showcase: `failed to create
vulkan instance!` after the loader logged the layer as found). `LD_LIBRARY_PATH`
pointing at the host works and is exactly what the closed loop forbids.

Drivers are bridged from the host (`compat.vulkan-runtime`) because a driver can only
come from the machine. A layer is ordinary software, so it is packaged.

## Shape

Shape I (ecosystem-stack binding), the `compat.libgbm` pattern: the library lives in
`xim:vulkan-validation-layers` (xim-pkgindex), built in the `gfxbuild` subos from the
`vulkan-sdk-1.4.357.0` tag with `-static-libstdc++ -static-libgcc`, so its NEEDED set is
glibc's alone and it loads into any process. This descriptor compiles an anchor and
declares the runtime dependency; the anchor download is upstream's `LICENSE.txt` at the
tag, mirrored to `mcpp-res/vulkan-validation-layers` byte for byte.

## Discovery

Two declarations the xim recipe makes and a consumer inherits through the runtime
dependency:

- the manifest is placed in the subos's `share/vulkan/explicit_layer.d`
  (`graphics.declare_vulkan_layer`, the ICD helper one directory over), with its
  `library_path` rewritten to the absolute payload path in `install()`;
- the subos `share` goes on `XDG_DATA_DIRS` (`graphics.declare_subos_env`, one row).

mcpp carries subos declarations into `mcpp run` / `mcpp test` (mcpp#352), so no
environment is set by hand and no engine change was needed.

## Feature

None. The layer is one library; nothing is gated.

## Test

`tests/examples/vulkan-validation-layers`: the loader enumerates the layer, and
`vkEnumerateInstanceExtensionProperties` with the layer's name makes the loader load the
library and asks it for `VK_EXT_debug_utils`. Both hold on a runner with no GPU; no
instance is created. Linux only; a no-op `main` elsewhere.

## Order

xim-pkgindex first (recipe + helper, PR there), then this package, then the consumer
(`[dev-dependencies] compat.vulkan-validation-layers`).
