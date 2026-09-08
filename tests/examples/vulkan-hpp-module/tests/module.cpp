// Behavioral test — consume Vulkan-Hpp through the C++23 named module
// `vulkan`, and assert the things a module build can get wrong quietly.
//
// There is not a single `#include` here, on purpose. `import vulkan;` has to
// deliver the whole surface by itself: a package that resolved, downloaded and
// linked but never compiled its module unit fails at the FIRST line of this
// file rather than passing with an empty build.
//
// The three groups below are chosen so that each of Vulkan-Hpp's four header
// layers is answered by something only that layer provides, and none of them
// needs a GPU, a driver, or an ICD manifest:
//
//   * vulkan.hpp                     — enums, structs, the `sType` defaults
//   * vulkan_format_traits.hpp       — constexpr format arithmetic
//   * vulkan_extension_inspection.hpp— the extension registry tables
//   * vulkan_raii.hpp                — the RAII wrappers, asserted by TYPE
//
// `vk::to_string` is asserted below for a reason worth stating: it lives in
// `vulkan_to_string.hpp`, which is NOT in the list of headers `vulkan.cppm`
// names — reading that list as exhaustive gets this wrong. `vulkan.hpp`
// includes it itself, guarded only by `VULKAN_HPP_NO_TO_STRING`, which nothing
// defines here, so it rides into the module purview and is exported. The check
// exists so that stops being a matter of reading and stays true.
//
// The rule the module DOES impose: `import vulkan;` and
// `#include <vulkan/vulkan.hpp>` are two roads and a TU takes exactly one of
// them — the header would arrive a second time, textually, as a different set
// of entities from the ones the module already owns.
//
// Macros do not travel through a named module either, which is why the
// extension names below are written as string literals rather than as
// `VK_KHR_SURFACE_EXTENSION_NAME`. Nor do the C API's own names: upstream's
// module unit exports the `vk::` surface plus the `PFN_vk*` function-pointer
// typedefs, and nothing else from the C headers — so `VkInstance` and
// `VkApplicationInfo` cannot be named here, only reached through
// `vk::Instance` and friends.
import std;
import vulkan;

int main() {
    // ── vulkan.hpp: enumerators and structs ──────────────────────────────
    //
    // Enumerator VALUES are the classic silent loss in a module wrapper — a
    // wrapper that exports only an enum's type name still compiles, and the
    // enumerators just are not there. These are the Vulkan specification's own
    // numbers (VK_FORMAT_R8G8B8A8_UNORM is 37), so a module that answers them
    // is carrying the real enum.
    static_assert(static_cast<unsigned>(vk::Format::eR8G8B8A8Unorm) == 37u);
    static_assert(static_cast<unsigned>(vk::ImageLayout::ePresentSrcKHR) == 1000001002u);

    // A struct with its generated `sType` default: this is Vulkan-Hpp's whole
    // reason to exist over the C headers, and it is default-member-initializer
    // state that has to survive the module build intact.
    static_assert(vk::ApplicationInfo{}.sType == vk::StructureType::eApplicationInfo);
    static_assert(std::is_standard_layout_v<vk::ApplicationInfo>);

    // ── vulkan_to_string.hpp, which arrives through vulkan.hpp ──────────
    //
    // Not in `vulkan.cppm`'s include list, exported all the same. Both
    // overloads: the enum one and the bitmask one, which is a different
    // generated file section.
    if (vk::to_string(vk::Format::eR8G8B8A8Unorm) != "R8G8B8A8Unorm") {
        std::println("vk::to_string(Format) gave {}", vk::to_string(vk::Format::eR8G8B8A8Unorm));
        return 5;
    }
    if (vk::to_string(vk::ImageUsageFlagBits::eColorAttachment) != "ColorAttachment") {
        std::println("vk::to_string(ImageUsageFlagBits) gave {}",
                     vk::to_string(vk::ImageUsageFlagBits::eColorAttachment));
        return 6;
    }

    // ── vulkan_format_traits.hpp: constexpr, evaluated at compile time ───
    static_assert(vk::blockSize(vk::Format::eR8G8B8A8Unorm) == 4);
    static_assert(vk::componentCount(vk::Format::eR8G8B8A8Unorm) == 4);
    static_assert(vk::blockSize(vk::Format::eBc1RgbUnormBlock) == 8);

    // ── vulkan_raii.hpp: asserted by type, not by construction ───────────
    //
    // Constructing a `vk::raii::Context` would dlopen the loader at RUNTIME,
    // which is a different claim than "the RAII layer is in the module" and is
    // not answerable on every runner (macOS links the loader statically, so
    // there is no library to open). The static members below are compile-time
    // facts of the RAII classes, so they prove the layer is present without
    // asking anything of the machine.
    static_assert(vk::raii::Instance::objectType == vk::ObjectType::eInstance);
    static_assert(vk::raii::Device::objectType == vk::ObjectType::eDevice);
    static_assert(std::is_same_v<vk::raii::Instance::CppType, vk::Instance>);

    // ── The loader, reached through the module's function layer ──────────
    //
    // Vulkan-Hpp defaults to the STATIC dispatcher (VULKAN_HPP_DISPATCH_LOADER_
    // DYNAMIC is 0 unless VK_NO_PROTOTYPES is defined), so these calls become
    // direct references to `vkEnumerateInstanceVersion` and friends. That is
    // the link-time proof that `khronos.vulkan-hpp`'s dependency on
    // `compat.vulkan` reaches a consumer: without it, this file does not link.
    //
    // Both answers come from the loader itself, before any ICD is consulted,
    // so they hold on a runner with no GPU. (The WSI surface extensions do NOT
    // — the loader advertises those only when some driver supports them, which
    // is why nothing here asserts on `VK_KHR_surface` being *reported*.)
    const std::uint32_t apiVersion = vk::enumerateInstanceVersion();
    if (vk::apiVersionMajor(apiVersion) < 1) {
        std::println("implausible loader api version: {}", apiVersion);
        return 1;
    }

    const std::vector<vk::ExtensionProperties> extensions = vk::enumerateInstanceExtensionProperties();

    // VK_EXT_debug_utils is implemented BY the loader, so it is present with or
    // without a driver. Reading it back through `vk::ExtensionProperties`
    // exercises the ArrayWrapper1D<char> member that makes the C struct's
    // `char[256]` a real C++ string type.
    const bool haveDebugUtils = std::ranges::any_of(extensions, [](const vk::ExtensionProperties& e) {
        return std::string_view(e.extensionName) == "VK_EXT_debug_utils";
    });
    if (!haveDebugUtils) {
        std::println("VK_EXT_debug_utils missing from {} loader extension(s)", extensions.size());
        for (const auto& e : extensions) std::println("  {}", std::string_view(e.extensionName));
        return 2;
    }

    // ── vulkan_extension_inspection.hpp: the registry tables ─────────────
    //
    // This is static knowledge compiled from the Vulkan XML registry, not a
    // question about this machine — `VK_KHR_swapchain` is a device extension
    // whether or not anything here implements it. A module missing this header
    // would fail to compile above; a module carrying an EMPTY table would
    // compile and answer false, which is what these check.
    if (!vk::isInstanceExtension("VK_KHR_surface") || vk::isDeviceExtension("VK_KHR_surface")) {
        std::println("extension inspection misclassified VK_KHR_surface");
        return 3;
    }
    if (!vk::isDeviceExtension("VK_KHR_swapchain")) {
        std::println("extension inspection does not know VK_KHR_swapchain is a device extension");
        return 4;
    }

    std::println("khronos.vulkan-hpp: ok (import vulkan; loader api {}.{}.{}, {} instance extension(s))",
                 vk::apiVersionMajor(apiVersion), vk::apiVersionMinor(apiVersion),
                 vk::apiVersionPatch(apiVersion), extensions.size());
    return 0;
}
