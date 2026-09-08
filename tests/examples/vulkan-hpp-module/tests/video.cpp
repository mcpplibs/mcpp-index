// Behavioral test — the package's SECOND module unit, `vulkan_video`.
//
// It gets its own test file for a reason that is not tidiness: upstream's
// `vulkan_video.cppm` says `import vulkan;`, so this module can only build
// after the other one, from a source list that names them in no particular
// order. A build system that compiled the two units independently would fail
// here and nowhere else, and a package that shipped only the first unit would
// fail at the `import` line below while `module.cpp` still passed.
//
// Everything asserted is compile-time video-codec-standard data (the H.264
// numbers are ITU-T H.264's own), so this test needs no GPU and no video
// hardware — only the module.
import std;
import vulkan_video;

int main() {
    // Constants: `constexpr inline` variables at namespace scope inside the
    // module purview. They are the shape most likely to be lost.
    static_assert(vk::video::H264MaxNumListRef == 32);
    static_assert(vk::video::H264ScalingList8X8NumElements == 64);
    static_assert(vk::video::H264MaxChromaPlanes == 2);

    // Enumerators, wrapping the STD_VIDEO_* values from the vk_video/ C
    // headers — which is also proof that those headers, reached through
    // `compat.vulkan-headers`, were on the include path when the module unit
    // was compiled: the enums live behind `#if defined(VULKAN_VIDEO_CODEC_
    // H264STD_H_)`, so a build that missed them would compile an EMPTY
    // namespace rather than fail.
    static_assert(static_cast<unsigned>(vk::video::H264ProfileIdc::eBaseline) == 66u);
    static_assert(static_cast<unsigned>(vk::video::H264ProfileIdc::eHigh) == 100u);
    static_assert(static_cast<unsigned>(vk::video::H264ChromaFormatIdc::e420) == 1u);

    // A struct from the same header set, to show the type layer is there too.
    const vk::video::H264SpsFlags flags{};
    if (flags.direct_8x8_inference_flag != 0u) {
        std::println("vk::video::H264SpsFlags is not value-initialized");
        return 1;
    }

    std::println("khronos.vulkan-hpp: ok (import vulkan_video; H.264 profile idc baseline={}, high={})",
                 static_cast<unsigned>(vk::video::H264ProfileIdc::eBaseline),
                 static_cast<unsigned>(vk::video::H264ProfileIdc::eHigh));
    return 0;
}
