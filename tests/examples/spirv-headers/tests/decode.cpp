// Behavioral test -- verify compat.spirv-headers delivers the Khronos include
// layout and definitions a SPIR-V READER needs.
//
// The criterion is deliberately not "the header compiles". A header-only
// package that resolves and exposes the wrong include root compiles nothing
// and fails at the consumer, so this test spells the include the way a
// consumer spells it and then decodes a module built by hand, which is the
// only thing that can tell a real header tree from an empty one.
#include <spirv/unified1/spirv.hpp>

import std;

int main() {
    // A minimal, well-formed SPIR-V module header: magic, version, generator,
    // bound, schema. Written as words rather than read from a file so the test
    // depends on nothing but the package under test.
    const std::uint32_t module_words[] = {
        spv::MagicNumber,
        spv::Version,
        0u,   // generator
        1u,   // bound
        0u,   // schema
    };

    if (module_words[0] != 0x07230203u) {
        std::println("spv::MagicNumber is {:#x}, expected 0x07230203", module_words[0]);
        return 1;
    }

    // The enums a decoder switches on. Their numeric values are part of the
    // SPIR-V specification, so a header that renamed or renumbered them would
    // be a different specification rather than a newer package.
    if (static_cast<unsigned>(spv::OpCapability) != 17u) {
        std::println("spv::OpCapability is {}, expected 17",
                     static_cast<unsigned>(spv::OpCapability));
        return 2;
    }
    if (static_cast<unsigned>(spv::ExecutionModelGLCompute) != 5u) {
        std::println("spv::ExecutionModelGLCompute is {}, expected 5",
                     static_cast<unsigned>(spv::ExecutionModelGLCompute));
        return 3;
    }

    // The version word packs major and minor into the middle two bytes. A
    // consumer that gates on a SPIR-V version reads it exactly this way.
    const std::uint32_t major = (module_words[1] >> 16) & 0xffu;
    const std::uint32_t minor = (module_words[1] >> 8) & 0xffu;
    if (major != 1u) {
        std::println("spv::Version reports major {}, expected 1", major);
        return 4;
    }

    std::println("compat.spirv-headers: SPIR-V {}.{} definitions present", major, minor);
    return 0;
}
