-- compat.spirv-headers — Khronos SPIR-V headers (the `spirv/unified1` tree).
--
-- Header-only, the same shape as `compat.vulkan-headers`: expose `include/` and
-- carry a trivial anchor TU so the package still produces a buildable lib
-- target.
--
-- WHO NEEDS IT. A program that only submits SPIR-V to a driver does not: the
-- module is opaque data and `vulkan_core.h` describes the API that takes it.
-- A program that READS a SPIR-V module needs the opcode and enum definitions,
-- and llama.cpp's Vulkan backend is one -- it inspects the modules its own
-- shader generator produced. Splitting this out of `compat.vulkan-headers`
-- follows Khronos: they are separate repositories, and a renderer that never
-- decodes SPIR-V should not acquire the decoder's headers.
--
-- THE INCLUDE PATH IS PART OF THE CONTRACT. Consumers spell it
-- `<spirv/unified1/spirv.hpp>`, which is the Khronos layout and what
-- `include/` yields directly. Distributions that flatten it to
-- `<spirv-headers/spirv.hpp>` exist and consumers probe for both with
-- `__has_include`; this package provides the first, so the probe's first arm
-- wins and no consumer needs a second spelling.
--
-- Versioning follows the Vulkan SDK release the tag belongs to
-- (`vulkan-sdk-1.4.357.0` → `1.4.357.0`), which is how Khronos ties the
-- SPIR-V, Vulkan header and loader repositories together.
--
-- LICENCE IS A SET. The bulk is MIT; upstream's own `LICENSE` calls out files
-- under CC-BY-4.0 and ships `LICENSES/` carrying both texts. Naming only the
-- headline would be a statement about the package that its own tree
-- contradicts.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "spirv-headers",
    description = "Khronos SPIR-V headers (spirv/unified1)",
    licenses    = {"MIT", "CC-BY-4.0"},
    repo        = "https://github.com/KhronosGroup/SPIRV-Headers",
    type        = "package",

    xpm = {
        linux = {
            ["1.4.357.0"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/SPIRV-Headers/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/spirv-headers/releases/download/1.4.357.0/spirv-headers-1.4.357.0.tar.gz",
                },
                sha256 = "4d703067a7e06331ccb37bdfed3f9b7879cc61969a2689ae95c95db34a47ff07",
            },
        },
        macosx = {
            ["1.4.357.0"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/SPIRV-Headers/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/spirv-headers/releases/download/1.4.357.0/spirv-headers-1.4.357.0.tar.gz",
                },
                sha256 = "4d703067a7e06331ccb37bdfed3f9b7879cc61969a2689ae95c95db34a47ff07",
            },
        },
        windows = {
            ["1.4.357.0"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/SPIRV-Headers/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/spirv-headers/releases/download/1.4.357.0/spirv-headers-1.4.357.0.tar.gz",
                },
                sha256 = "4d703067a7e06331ccb37bdfed3f9b7879cc61969a2689ae95c95db34a47ff07",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/spirv_headers_anchor.c"] =
                "int mcpp_compat_spirv_headers_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/spirv_headers_anchor.c" },
        targets = { ["spirv-headers"] = { kind = "lib" } },
        deps    = {},
    },
}
