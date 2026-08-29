// Default Galay package surface: both named modules and linked kernel code.
#ifdef HAVE_GALAY

import std;
import galay.utils;
import galay.kernel;

int main() {
    using galay::kernel::Buffer;
    using galay::kernel::Host;
    using galay::kernel::IPType;
    using galay::utils::Base64Util;
    using galay::utils::StringUtils;

    const std::string encoded = Base64Util::Base64Encode("galay");
    if (encoded != "Z2FsYXk=") return 1;
    if (Base64Util::Base64Decode(encoded) != "galay") return 2;

    const auto pieces = StringUtils::split("galay:mcpp:index", ':');
    if (pieces != std::vector<std::string>{"galay", "mcpp", "index"}) return 3;

    Buffer buffer("galay", 5);
    if (buffer.length() != 5 || buffer.toString() != "galay") return 4;
    Buffer copy = buffer.clone();
    buffer.clear();
    if (copy.toString() != "galay" || buffer.length() != 0) return 5;

    const Host host(IPType::IPV4, "127.0.0.1", 9080);
    if (!host.valid() || host.ip() != "127.0.0.1" || host.port() != 9080) return 6;

    return 0;
}

#else

int main() { return 0; }

#endif
