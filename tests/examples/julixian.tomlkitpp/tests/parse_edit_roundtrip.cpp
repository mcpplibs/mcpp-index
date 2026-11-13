// Behavioral test for julixian.tomlkitpp:
// TOML v1.1.0 parsing (optional seconds, multiline inline table, \xHH escape),
// typed lookup, in-place surgical edit, and comment/radix preservation.
import std;
import tomlkitpp;

int main() {
    constexpr std::string_view input =
        "# Header comment\n"
        "mask = 0xff_00\n"
        "\n"
        "[server]\n"
        "endpoint = { host = \"127.0.0.1\", port = 8080, }\n"
        "window = 07:30 # TOML 1.1 optional seconds\n"
        "tag = \"\\x41B\"\n";

    auto doc = tomlkit::tryParse(input);
    if (!doc) return 1;

    if (tomlkit::findOr(*doc, "mask", std::int64_t{0}) != 0xff00) return 2;
    if ((*doc)["server", "endpoint", "host"].get<std::string>() != "127.0.0.1") return 3;
    if ((*doc)["server", "endpoint", "port"].get<int>() != 8080) return 4;
    if ((*doc)["server", "tag"].get<std::string>() != "AB") return 5;

    const auto lt = (*doc)["server", "window"].tryGet<tomlkit::LocalTime>();
    if (!lt || lt->hour != 7 || lt->minute != 30 || lt->hasSeconds) return 6;

    // Surgical edit: modify port while keeping comments, 0xff_00 literal, and optional seconds intact.
    (*doc)["server", "endpoint", "port"] = 9090;
    const std::string emitted = tomlkit::format(*doc);

    if (emitted.find("# Header comment\n") == std::string::npos) return 7;
    if (emitted.find("mask = 0xff_00\n") == std::string::npos) return 8;
    if (emitted.find("# TOML 1.1 optional seconds\n") == std::string::npos) return 9;
    if (emitted.find("window = 07:30") == std::string::npos) return 10;

    auto reparsed = tomlkit::tryParse(emitted);
    if (!reparsed) return 11;
    if ((*reparsed)["server", "endpoint", "port"].get<int>() != 9090) return 12;

    return 0;
}
