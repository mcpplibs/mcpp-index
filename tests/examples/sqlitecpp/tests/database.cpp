// Behavioral test: a real database session through the RAII wrapper.
//
// The load-bearing question for this package is whether the dependency edge on
// compat.sqlite3 actually replaces upstream's git submodule — and that is a LINK
// question, so every assertion below is chosen to reach sqlite3 symbols: the
// version string, prepared statements with bound parameters, a transaction that
// rolls back, and the exception path (which carries an sqlite3 error code).
#include <SQLiteCpp/SQLiteCpp.h>

#include <cassert>
#include <string>

int main() {
    // The wrapper reports the SQLite it was linked against, which is the
    // cheapest proof that the dependency edge resolved to a real library.
    const std::string version = SQLite::getLibVersion();
    assert(!version.empty() && version[0] == '3');

    SQLite::Database db(":memory:", SQLite::OPEN_READWRITE | SQLite::OPEN_CREATE);

    db.exec("CREATE TABLE note (id INTEGER PRIMARY KEY, title TEXT NOT NULL, size INTEGER)");
    assert(db.tableExists("note"));

    // --- bound parameters through a prepared statement ---
    {
        SQLite::Statement insert(db, "INSERT INTO note (title, size) VALUES (?, ?)");
        for (const auto& [title, size] : {std::pair<const char*, int>{"alpha", 10},
                                          {"beta", 20},
                                          {"gamma", 30}}) {
            insert.bind(1, title);
            insert.bind(2, size);
            assert(insert.exec() == 1);
            insert.reset();
        }
    }
    assert(db.execAndGet("SELECT COUNT(*) FROM note").getInt() == 3);
    assert(db.getLastInsertRowid() == 3);

    // --- iteration, typed columns, and a named parameter ---
    {
        SQLite::Statement query(db, "SELECT id, title, size FROM note WHERE size >= :floor ORDER BY id");
        query.bind(":floor", 20);
        int rows = 0;
        int total = 0;
        while (query.executeStep()) {
            const int id = query.getColumn(0);
            const std::string title = query.getColumn(1).getString();
            total += static_cast<int>(query.getColumn(2).getInt());
            assert(id >= 2 && !title.empty());
            ++rows;
        }
        assert(rows == 2 && total == 50);
    }

    // --- a transaction that is NOT committed must roll back on scope exit ---
    {
        SQLite::Transaction abandoned(db);
        db.exec("DELETE FROM note");
        assert(db.execAndGet("SELECT COUNT(*) FROM note").getInt() == 0);
    }
    assert(db.execAndGet("SELECT COUNT(*) FROM note").getInt() == 3);

    // --- and one that is ---
    {
        SQLite::Transaction kept(db);
        db.exec("UPDATE note SET size = size * 2");
        kept.commit();
    }
    assert(db.execAndGet("SELECT SUM(size) FROM note").getInt() == 120);

    // --- the error path carries an sqlite3 error code, not just a message ---
    bool threw = false;
    try {
        db.exec("INSERT INTO note (title) VALUES (NULL)");   // NOT NULL violation
    } catch (const SQLite::Exception& e) {
        threw = true;
        assert(e.getErrorCode() != 0);
        assert(std::string(e.what()).find("NOT NULL") != std::string::npos);
    }
    assert(threw);

    return 0;
}
