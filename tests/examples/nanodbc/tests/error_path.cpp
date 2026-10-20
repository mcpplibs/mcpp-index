// compat.nanodbc — connect to a DSN that does not exist and assert nanodbc
// reports the driver manager's own diagnostics as a nanodbc::database_error.
//
// Deliberately DATABASE-FREE. A CI runner has no database server and no ODBC
// driver, so a successful connect asserts nothing that can hold everywhere.
// What IS guaranteed is the driver manager (unixODBC), which is the layer
// nanodbc wraps: the failed connect still walks handle allocation, the DSN
// lookup and the diagnostic formatting, and every one of those symbols comes
// from the compiled nanodbc.cpp — a half-linked package fails here.
#ifdef HAVE_NANODBC

#include <nanodbc/nanodbc.h>
import std;

int main() {
    bool ok = true;
    auto check = [&](bool cond, std::string_view what) {
        if (!cond) {
            std::println("FAIL: {}", what);
            ok = false;
        }
    };

    bool thrown = false;
    try {
        // A DSN that cannot exist anywhere; SQL_DRIVER_NOPROMPT keeps the DM
        // from trying to raise a UI prompt on a headless runner.
        nanodbc::connection conn(
            NANODBC_TEXT("DSN=mcpp-definitely-missing"), NANODBC_TEXT(""),
            NANODBC_TEXT(""), 1 /* timeout */);
        check(false, "connecting to a nonexistent DSN must not succeed");
    } catch (const nanodbc::database_error& e) {
        thrown = true;
        std::println("caught database_error: state={} what={}", e.state(),
                     e.what());
        // IM002, "[Driver Manager]Data source name not found", is the proof
        // the diagnostics came out of the real driver manager, not a stub.
        //
        // nanodbc 2.14.0 itself drops the LAST state character (recent_error
        // in nanodbc.cpp loops to size(sql_state) - 1), so state() reads
        // "IM00" where the DM said "IM002". Frozen upstream, so assert the
        // prefix relationship rather than equality.
        check(!e.state().empty() && std::string_view("IM002").starts_with(e.state()),
              "SQL state must be a non-empty prefix of IM002");
        check(std::string_view(e.what()).find("Data source name not found") !=
                  std::string_view::npos,
              "what() must carry the driver manager's own message");
    } catch (const std::exception& e) {
        check(false, std::format("wrong exception type: {}", e.what()));
    }
    check(thrown, "nanodbc::database_error must be thrown for a bogus DSN");

    if (ok) std::println("nanodbc error-path test passed");
    return ok ? 0 : 1;
}

#else

#include <nanodbc/nanodbc.h>

// Also exercise real allocation, linking and destruction on macOS/Windows.
// No database driver or running database is needed for an idle connection.
int main() {
    nanodbc::connection connection;
    return connection.connected() ? 1 : 0;
}

#endif
