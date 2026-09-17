// compat.vulkan-validation-layers — behavioral test, no GPU needed.
//
// Two questions, both answered by the loader before any driver is involved:
//
//   1. Is VK_LAYER_KHRONOS_validation enumerated? That is the manifest being
//      found -- the subos share reached XDG_DATA_DIRS and the manifest reached
//      share/vulkan/explicit_layer.d, and mcpp carried the variable into this
//      process.
//   2. Can the layer's library be loaded? vkEnumerateInstanceExtensionProperties
//      with the layer's name makes the loader dlopen the library and call into
//      it. That is the very step that fails against a host copy of the layer
//      (bare soname, no /usr/lib on this loader's path), and it is what the
//      absolute library_path plus a self-contained .so make succeed.
//
// No vkCreateInstance: on a driverless runner that is VK_ERROR_INCOMPATIBLE_DRIVER
// and says nothing about the layer.
#if defined(HAVE_VULKAN_LOADER)
#include <vulkan/vulkan.h>
#endif
import std;

#if !defined(HAVE_VULKAN_LOADER)
int main() {
    std::println("compat.vulkan-validation-layers: skipped (linux only)");
    return 0;
}
#else
int main() {
    constexpr const char* layer = "VK_LAYER_KHRONOS_validation";

    std::uint32_t count = 0;
    if (vkEnumerateInstanceLayerProperties(&count, nullptr) != VK_SUCCESS) {
        std::println("vkEnumerateInstanceLayerProperties failed");
        return 1;
    }
    std::vector<VkLayerProperties> layers(count);
    if (count && vkEnumerateInstanceLayerProperties(&count, layers.data()) != VK_SUCCESS) {
        std::println("vkEnumerateInstanceLayerProperties (fill) failed");
        return 1;
    }
    bool found = false;
    for (const auto& l : layers) {
        std::println("layer: {} ({})", l.layerName, l.description);
        if (std::string_view{l.layerName} == layer) found = true;
    }
    if (!found) {
        std::println("{} is not enumerated: the manifest did not reach the loader", layer);
        return 1;
    }

    // Loads the library. A stale or unreachable library_path fails here with
    // VK_ERROR_LAYER_NOT_PRESENT; a library that cannot resolve its own
    // dependencies fails the same way.
    std::uint32_t ext_count = 0;
    const auto rst = vkEnumerateInstanceExtensionProperties(layer, &ext_count, nullptr);
    if (rst != VK_SUCCESS) {
        std::println("vkEnumerateInstanceExtensionProperties({}) = {}: the layer library did not load", layer, static_cast<int>(rst));
        return 1;
    }
    std::vector<VkExtensionProperties> exts(ext_count);
    if (ext_count && vkEnumerateInstanceExtensionProperties(layer, &ext_count, exts.data()) != VK_SUCCESS) {
        std::println("vkEnumerateInstanceExtensionProperties (fill) failed");
        return 1;
    }
    bool debug_utils = false;
    for (const auto& e : exts) {
        std::println("  {} v{}", e.extensionName, e.specVersion);
        if (std::string_view{e.extensionName} == "VK_EXT_debug_utils") debug_utils = true;
    }
    // The validation layer implements VK_EXT_debug_utils, which is how a
    // program receives its messages; a layer that loaded but lists nothing
    // is not the one asked for.
    if (!debug_utils) {
        std::println("{} loaded but does not provide VK_EXT_debug_utils", layer);
        return 1;
    }
    std::println("ok: {} enumerated and loaded", layer);
    return 0;
}
#endif
