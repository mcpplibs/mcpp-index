#include <cmath>
#include <cstdio>
#include <filesystem>
#include <fstream>
#include <string>

#include <iniparser.h>

static_assert(INIPARSER_VERSION_MAJOR == 4, "expected iniparser 4.x version.h");
static_assert(INIPARSER_VERSION_MINOR >= 3, "expected iniparser 4.3+ version.h");

int main() {
    bool ok = true;

    const std::filesystem::path tmp_ini =
        std::filesystem::temp_directory_path() / "mcpp_iniparser_test.ini";
    {
        std::ofstream ofs(tmp_ini);
        ofs << "[server]\n"
            << "host = localhost\n"
            << "port = 8080\n"
            << "ratio = 0.75\n"
            << "tls = true\n";
    }

    dictionary *ini = iniparser_load(tmp_ini.string().c_str());
    std::error_code ec;
    std::filesystem::remove(tmp_ini, ec);

    if (!ini) {
        std::fprintf(stderr, "iniparser_load failed\n");
        return 1;
    }

    const char *host = iniparser_getstring(ini, "server:host", nullptr);
    ok = ok && host != nullptr && std::string(host) == "localhost";
    ok = ok && iniparser_getint(ini, "server:port", -1) == 8080;
    ok = ok && std::fabs(iniparser_getdouble(ini, "server:ratio", 0.0) - 0.75) < 1e-9;
    ok = ok && iniparser_getboolean(ini, "server:tls", 0) == 1;
    ok = ok && iniparser_find_entry(ini, "server:port") == 1;
    ok = ok && iniparser_find_entry(ini, "server:missing") == 0;

    ok = ok && iniparser_set(ini, "server:mode", "fast") == 0;
    const char *mode = iniparser_getstring(ini, "server:mode", nullptr);
    ok = ok && mode != nullptr && std::string(mode) == "fast";

    iniparser_freedict(ini);
    return ok ? 0 : 1;
}
