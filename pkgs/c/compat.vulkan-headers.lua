-- compat.vulkan-headers — Khronos Vulkan API headers.
--
-- Header-only, the same shape as `compat.opengl`: expose `include/` and carry a
-- trivial anchor TU so the package still produces a buildable lib target.
-- Split out from `compat.vulkan` (the loader) because they are separate
-- upstream repositories on separate release cadences, and because a consumer
-- that only needs the types — a renderer compiled against a loader it does not
-- link, say — should not drag the loader in.
--
-- `vk_video/` ships alongside `vulkan/` and is included by `vulkan_video.h`, so
-- one include root covers both.
--
-- ⚠️ THIS TARBALL ALSO CARRIES VULKAN-HPP. Khronos generates the C++ bindings
-- in KhronosGroup/Vulkan-Hpp and releases them, already generated, inside every
-- Vulkan-Headers tag: `include/vulkan/vulkan.hpp`, `vulkan_raii.hpp`, and the
-- two module interface units `vulkan.cppm` / `vulkan_video.cppm`. This package
-- exposes them all through `include/` but COMPILES none of them — it is the C
-- API package, and `#include <vulkan/vulkan.hpp>` is a consumer's own choice.
-- `khronos.vulkan-hpp` is the package that builds the two `.cppm` units into
-- the `vulkan` / `vulkan_video` modules, from this same URL and sha256.
-- A version bump here therefore has to move that package too: its module unit
-- opens with `VULKAN_HPP_STATIC_ASSERT( VK_HEADER_VERSION == … )`, so a
-- half-done bump fails to compile rather than shipping a skewed pair.
--
-- Versioning follows the Vulkan SDK release the tag belongs to
-- (`vulkan-sdk-1.4.357.0` → `1.4.357.0`), which is how Khronos ties the header,
-- loader and validation-layer repos together.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "vulkan-headers",
    description = "Khronos Vulkan API headers",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/KhronosGroup/Vulkan-Headers",
    type        = "package",

    xpm = {
        linux = {
            ["1.4.357.0"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Headers/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan-headers/releases/download/1.4.357.0/vulkan-headers-1.4.357.0.tar.gz",
                },
                sha256 = "e87dce08116151f6b6d7de6b6faf41498e87e6cf848ff16fa3bd5402190ad4a3",
            },
        },
        macosx = {
            ["1.4.357.0"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Headers/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan-headers/releases/download/1.4.357.0/vulkan-headers-1.4.357.0.tar.gz",
                },
                sha256 = "e87dce08116151f6b6d7de6b6faf41498e87e6cf848ff16fa3bd5402190ad4a3",
            },
        },
        windows = {
            ["1.4.357.0"] = {
                url = {
                    GLOBAL = "https://github.com/KhronosGroup/Vulkan-Headers/archive/refs/tags/vulkan-sdk-1.4.357.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/vulkan-headers/releases/download/1.4.357.0/vulkan-headers-1.4.357.0.tar.gz",
                },
                sha256 = "e87dce08116151f6b6d7de6b6faf41498e87e6cf848ff16fa3bd5402190ad4a3",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/vulkan_headers_anchor.c"] =
                "int mcpp_compat_vulkan_headers_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/vulkan_headers_anchor.c" },
        targets = { ["vulkan-headers"] = { kind = "lib" } },
        deps    = {},
    },
}
