// Behavioral test — verify compat.vulkan builds a working loader and that a
// consumer can link its trampolines.
//
// Everything asserted here is answered by the LOADER itself, before any ICD is
// involved, so it is meaningful on a CI runner with no GPU and no driver.
// That constraint is sharper than it looks: the loader advertises the WSI
// surface extensions only when some ICD supports them, so `VK_KHR_surface` is
// legitimately ABSENT on a driverless machine and asserting on it would just be
// testing the runner's hardware.
//
// HAVE_VULKAN_LOADER is set by THIS project's own [build] cxxflags. A consumer
// that keys its source off a dependency's presence has to declare that itself.
#if defined(HAVE_VULKAN_LOADER)
#include <vulkan/vulkan.h>
#endif
import std;

#if defined(HAVE_VULKAN_LOADER) && defined(_WIN32)
// Declared rather than taken from <windows.h>: two functions are needed, and
// the header's macros and min/max collide with `import std`. Both live in
// kernel32, which every Windows program already links.
extern "C" __declspec(dllimport) void* GetModuleHandleW(const wchar_t* name);
extern "C" __declspec(dllimport) unsigned long GetModuleFileNameW(void* module, wchar_t* path,
                                                                  unsigned long size);
#endif

#if !defined(HAVE_VULKAN_LOADER)
int main() {
    std::println("compat.vulkan: skipped (no windows build — static loader unsupported upstream)");
    return 0;
}
#else
int main() {
    // Only the loader can answer this — it reports the Vulkan version the
    // loader itself implements. A package that failed to compile its
    // trampolines fails at LINK here rather than passing quietly.
    std::uint32_t apiVersion = 0;
    if (vkEnumerateInstanceVersion(&apiVersion) != VK_SUCCESS) {
        std::println("vkEnumerateInstanceVersion failed");
        return 1;
    }
    if (VK_VERSION_MAJOR(apiVersion) < 1) {
        std::println("implausible loader api version: {}", apiVersion);
        return 2;
    }

#if defined(_WIN32)
    // WHERE THE LOADER CAME FROM is the point of compat.vulkan 1.4.357.3 on
    // Windows: the package now ships vulkan-1.dll and mcpp places it beside the
    // executable, so a machine with no GPU driver can still start this program.
    // The loader has just answered, so the DLL is mapped; its directory must be
    // this executable's. That holds on a machine WITH a driver too (the
    // application directory precedes System32), which is what makes this a real
    // check: with an older compat.vulkan the loader came from System32 there,
    // and on a driverless machine the process never reached main.
    {
        std::vector<wchar_t> dll(32768), exe(32768);
        void* module = GetModuleHandleW(L"vulkan-1.dll");
        if (module == nullptr) {
            std::println("vulkan-1.dll answered but is not mapped in this process");
            return 7;
        }
        const auto dllLen = GetModuleFileNameW(module, dll.data(), 32768);
        const auto exeLen = GetModuleFileNameW(nullptr, exe.data(), 32768);
        auto dirOf = [](std::wstring_view p) {
            std::wstring d(p.substr(0, p.find_last_of(L"\\/")));
            for (auto& c : d) c = static_cast<wchar_t>(std::towlower(c));
            return d;
        };
        auto narrow = [](std::wstring_view p) {
            std::string out;
            for (wchar_t c : p) out.push_back(c < 128 ? static_cast<char>(c) : '?');
            return out;
        };
        const std::wstring_view dllPath(dll.data(), dllLen), exePath(exe.data(), exeLen);
        if (dirOf(dllPath) != dirOf(exePath)) {
            std::println("vulkan-1.dll was loaded from {}, not beside {}",
                         narrow(dllPath), narrow(exePath));
            return 8;
        }
        std::println("compat.vulkan: loader deployed beside the executable ({})", narrow(dllPath));
    }
#endif

    std::uint32_t extensionCount = 0;
    if (vkEnumerateInstanceExtensionProperties(nullptr, &extensionCount, nullptr) != VK_SUCCESS) {
        std::println("vkEnumerateInstanceExtensionProperties failed");
        return 3;
    }
    std::vector<VkExtensionProperties> extensions(extensionCount);
    if (extensionCount > 0 &&
        vkEnumerateInstanceExtensionProperties(nullptr, &extensionCount, extensions.data()) != VK_SUCCESS) {
        std::println("vkEnumerateInstanceExtensionProperties (fill) failed");
        return 4;
    }

    // VK_EXT_debug_utils is implemented BY the loader, so it is present with or
    // without a driver — unlike the surface extensions. Its absence would mean
    // the loader's own extension table never made it into the lib.
    const bool haveDebugUtils = std::ranges::any_of(extensions, [](const VkExtensionProperties& e) {
        return std::string_view(e.extensionName) == VK_EXT_DEBUG_UTILS_EXTENSION_NAME;
    });
    if (!haveDebugUtils) {
        std::println("VK_EXT_debug_utils missing from {} loader extension(s)", extensionCount);
        for (const auto& e : extensions) std::println("  {}", e.extensionName);
        return 5;
    }

    // Link-time proof that wsi.c is in the library. vkDestroySurfaceKHR is a
    // WSI trampoline; referencing it makes a build without that translation
    // unit fail to link, which is the check the extension list cannot give us
    // on a driverless machine.
    if (&vkDestroySurfaceKHR == nullptr) {
        std::println("vkDestroySurfaceKHR unexpectedly null");
        return 6;
    }

    std::println("compat.vulkan: ok (loader api {}.{}.{}, {} loader extension(s), WSI trampolines linked)",
                 VK_VERSION_MAJOR(apiVersion), VK_VERSION_MINOR(apiVersion),
                 VK_VERSION_PATCH(apiVersion), extensionCount);
    return 0;
}
#endif
