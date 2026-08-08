// Behavioral test for compat.sqlite3 (SQLite 3.45.3, C API): assert the
// resolved library version, then open an in-memory database, create a table,
// insert a row, and read it back through both sqlite3_exec and a prepared
// statement.
#include <sqlite3.h>
#include <cassert>
#include <cstring>

int main() {
    // The index pins 3.45.3; prove the resolved package is that version.
    assert(std::strcmp(sqlite3_libversion(), "3.45.3") == 0);

    sqlite3* db = nullptr;
    assert(sqlite3_open(":memory:", &db) == SQLITE_OK);
    assert(db != nullptr);

    // DDL + DML through the convenience API.
    char* errmsg = nullptr;
    int rc = sqlite3_exec(db,
        "CREATE TABLE t(id INTEGER PRIMARY KEY, name TEXT NOT NULL);"
        "INSERT INTO t(name) VALUES ('mcpp');",
        nullptr, nullptr, &errmsg);
    assert(rc == SQLITE_OK);
    if (errmsg != nullptr) { sqlite3_free(errmsg); errmsg = nullptr; }

    // Read back through a prepared statement.
    sqlite3_stmt* stmt = nullptr;
    rc = sqlite3_prepare_v2(db, "SELECT id, name FROM t;", -1, &stmt, nullptr);
    assert(rc == SQLITE_OK);
    assert(stmt != nullptr);
    assert(sqlite3_step(stmt) == SQLITE_ROW);
    assert(sqlite3_column_int(stmt, 0) == 1);
    assert(std::strcmp(reinterpret_cast<const char*>(sqlite3_column_text(stmt, 1)), "mcpp") == 0);
    assert(sqlite3_step(stmt) == SQLITE_DONE);
    sqlite3_finalize(stmt);

    assert(sqlite3_close(db) == SQLITE_OK);
    return 0;
}
