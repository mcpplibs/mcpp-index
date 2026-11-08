import std;
import mcpplibs.mtest.manifest;

int main() {
    const auto cases = mcpplibs::mtest::manifest::scan(
        "E2E cli{\"cli\", resource{\"serial:home\"}, [] {\n"
        "    \"prints its version\"_test[tag{\"fast\"}] = [] {};\n"
        "}};\n");
    if (cases.size() != 2) return 1;
    if (cases[0].id != "cli" || cases[0].kind != "e2e" || cases[0].resources != std::vector<std::string>{"serial:home"}) return 2;
    if (cases[1].id != "cli/prints its version" || cases[1].tags != std::vector<std::string>{"fast"}) return 3;
    std::println("mtest-manifest: {} cases, {} of kind {}", cases.size(), cases[0].id, cases[0].kind);
    return 0;
}
