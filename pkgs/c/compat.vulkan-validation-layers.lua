-- compat.vulkan-validation-layers — VK_LAYER_KHRONOS_validation for a program
-- built by mcpp, bound to the ecosystem's `xim:vulkan-validation-layers`.
--
-- WHAT GOES WRONG WITHOUT IT
--
-- A debug build asks the loader for the validation layer. The loader finds the
-- host's manifest under /usr/share/vulkan and then dlopens the library it
-- names -- by bare soname, through the process's dynamic linker. An mcpp-built
-- program runs on this ecosystem's glibc, whose loader searches the payloads
-- on the RPATH and never /usr/lib, so the dlopen fails and vkCreateInstance
-- returns an error after the layer was reported present:
--
--   [Vulkan Loader] ERROR: libVkLayer_khronos_validation.so: cannot open
--                          shared object file
--   ... failed to create vulkan instance!
--
-- Host DRIVERS are bridged into the process because a driver can only come
-- from the machine (compat.vulkan-runtime). A layer is ordinary software, so
-- it is a payload of the ecosystem instead, and this package is the binding
-- (shape I in docs/package-types.md): no source of its own, a runtime
-- dependency on the xim payload, and an anchor so the descriptor has a
-- target.
--
-- HOW THE LAYER IS FOUND
--
-- Two declarations the xim recipe makes, and this package inherits: the
-- manifest is placed in the subos's share/vulkan/explicit_layer.d, and that
-- share is put on XDG_DATA_DIRS -- the directory the Khronos loader reads.
-- mcpp carries subos declarations into the processes it launches (mcpp#352),
-- so `mcpp run` and `mcpp test` see the layer with no environment set by
-- hand. The library itself is named by absolute payload path in the manifest
-- and is self-contained (static libstdc++), so nothing in the consumer's
-- runtime closure decides whether it loads.
--
-- A [dev-dependencies] entry is the intended spelling: the layer is for the
-- developer's runs and must not ship with the artifact.
--
-- Version = the Vulkan SDK tag the layer is built from, the line compat.vulkan
-- (the loader) tracks. The anchor is upstream's LICENSE.txt at that tag.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "vulkan-validation-layers",
    description = "VK_LAYER_KHRONOS_validation for mcpp-built programs, bound to the ecosystem's xim:vulkan-validation-layers — zero host dependency",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/KhronosGroup/Vulkan-ValidationLayers",
    type        = "package",

    xpm = {
        linux = {
            deps = { runtime = { "xim:vulkan-validation-layers@1.4.357.0" } },
            ["1.4.357.0"] = {
                url = {
                    GLOBAL = "https://raw.githubusercontent.com/KhronosGroup/Vulkan-ValidationLayers/vulkan-sdk-1.4.357.0/LICENSE.txt",
                    CN     = "https://gitcode.com/mcpp-res/vulkan-validation-layers/releases/download/1.4.357.0/vulkan-validation-layers-1.4.357.0.txt",
                },
                sha256 = "db3010170b904cb7212ef6abd2336f316bf735060eeeca23f1a737f459cc73e4",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        generated_files = {
            ["mcpp_generated/vulkan_validation_layers_anchor.c"] =
                "int mcpp_compat_vulkan_validation_layers_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/vulkan_validation_layers_anchor.c" },
        targets = { ["vulkan_validation_layers_binding"] = { kind = "lib" } },
        deps = {},
    },
}
