#include "plugin_info.hpp"
import std;

int main() {
    const std::filesystem::path binary(plugin_binary);
    if (!std::filesystem::is_regular_file(binary)) return 1;
    if (std::filesystem::file_size(binary) == 0) return 2;
    std::println("Indexed gRPC host plugin built: {}", binary.string());
    return 0;
}
