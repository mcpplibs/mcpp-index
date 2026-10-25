// Behavioral test: a real SQLite session driven through SOCI.
//
// SOCI is a thin layer over a backend, so a test that opens no session proves
// almost nothing. Every interesting way this package can be wrong — the backend
// TUs not compiled, the missing upstream git submodule not replaced by the
// compat.sqlite3 edge, the private SOCI_SQLITE3_SOURCE switch mismatched, a
// stale generated soci-config.h — shows up only once a statement runs. So every
// assertion below goes through soci::session against `:memory:`, and four of
// them are chosen to be unfakeable:
//
//   * SOCI_VERSION is asserted EXACTLY: it identifies the pinned upstream
//     release, the same way tests/examples/sqlite3 asserts sqlite3_libversion().
//   * `select sqlite_version()` must return a real SQLite version: the
//     amalgamation can only have come from the compat.sqlite3 dependency, since
//     upstream's own copy is a git submodule the source tarball omits.
//   * the error paths must produce a sqlite3_soci_error carrying the backend's
//     own backend name, error code and error CATEGORY — a real backend raising
//     real errors, not a stub.
//   * NULL round-tripping is asserted through soci::indicator, which is SOCI's
//     own layer (the backend reports the column type, the core maps it).
//
// The backend is reached as a FACTORY OBJECT (soci::sqlite3) rather than through
// session("sqlite3", ...): the name-based overload hands off to SOCI's dynamic
// backend loader, which dlopen()s a backend shared object that this package
// deliberately does not ship, because the backend is compiled into the same lib.
#include <soci/soci.h>
#include <soci/sqlite3/soci-sqlite3.h>
// `soci.h` does not pull in the version macros; the exact-release assertion
// below needs the header upstream says is the only one guaranteed to change
// with every release.
#include <soci/version.h>

#include <cassert>
#include <cstddef>
#include <string>
#include <vector>

int main() {
    // --- the pinned release ---
    static_assert(SOCI_VERSION == 400104, "SOCI_VERSION is not 4.1.4");
    assert(std::string(SOCI_LIB_VERSION) == "4_1_4");

    soci::session sql(soci::sqlite3, ":memory:");

    // --- the dependency edge, and the engine behind it ---
    {
        std::string version;
        sql << "select sqlite_version()", soci::into(version);
        assert(!version.empty() && version[0] == '3');
        assert(version.find('.') != std::string::npos);
    }

    // --- DDL, then one parameter round-trip in both directions ---
    sql << "create table person (id integer primary key, name varchar(64), weight real)";
    {
        int id = 1;
        std::string name = "Maciej";
        double weight = 70.5;
        sql << "insert into person (id, name, weight) values (:id, :name, :weight)",
            soci::use(id), soci::use(name), soci::use(weight);

        // ... read back into DIFFERENT variables, so nothing can be a no-op
        std::string got_name;
        double got_weight = 0.0;
        sql << "select name, weight from person where id = 1",
            soci::into(got_name), soci::into(got_weight);
        assert(got_name == name);
        assert(got_weight == weight);
    }

    // --- one prepared statement, executed repeatedly with rebound variables ---
    {
        int id = 0;
        std::string name;
        double weight = 0.0;
        soci::statement ins = (sql.prepare
                << "insert into person (id, name, weight) values (:id, :name, :weight)",
            soci::use(id), soci::use(name), soci::use(weight));

        const char* names[] = {"Vadim", "David"};
        for (int i = 0; i < 2; ++i) {
            id = i + 2;
            name = names[i];
            weight = 60.0 + i;
            ins.execute(true);
        }
        sql << "select count(*) from person", soci::into(id);
        assert(id == 3);
    }

    // --- iteration over a rowset, with typed column access ---
    {
        soci::rowset<soci::row> rows =
            (sql.prepare << "select id, name, weight from person order by id");
        std::size_t n = 0;
        for (const soci::row& r : rows) {
            assert(r.size() == 3);
            assert(r.get<int>(0) == static_cast<int>(n) + 1);
            assert(!r.get<std::string>(1).empty());
            assert(r.get<double>(2) > 0.0);
            ++n;
        }
        assert(n == 3);
    }

    // --- NULL is not "zero": the indicator is what distinguishes them ---
    {
        sql << "insert into person (id, name, weight) values (4, 'nobody', null)";

        double weight = 123.0;
        soci::indicator ind = soci::i_ok;
        sql << "select weight from person where id = 4", soci::into(weight, ind);
        assert(ind == soci::i_null);

        sql << "select weight from person where id = 1", soci::into(weight, ind);
        assert(ind == soci::i_ok);
        assert(weight == 70.5);
    }

    // --- transactions: rollback (explicit, and by scope exit) and commit ---
    long long count = 0;
    sql << "select count(*) from person", soci::into(count);
    assert(count == 4);

    {
        soci::transaction tr(sql);
        sql << "delete from person";
        tr.rollback();
    }
    sql << "select count(*) from person", soci::into(count);
    assert(count == 4);

    {
        soci::transaction tr(sql);
        sql << "delete from person";  // deliberately NOT committed
        (void)tr;
    }
    sql << "select count(*) from person", soci::into(count);
    assert(count == 4);

    {
        soci::transaction tr(sql);
        sql << "update person set weight = weight + 1";
        tr.commit();
    }
    {
        double weight = 0.0;
        sql << "select weight from person where id = 1", soci::into(weight);
        assert(weight == 71.5);
    }

    // --- the error path: the backend's own type, code and category ---
    {
        bool threw = false;
        try {
            sql << "select * from no_such_table";
        } catch (const soci::sqlite3_soci_error& e) {
            threw = true;
            assert(e.get_backend_name() == "sqlite3");
            assert(e.get_backend_error_code() != 0);
            assert(std::string(e.what()).find("no_such_table") != std::string::npos);
        }
        assert(threw);
    }

    // --- and a constraint violation classified as one, not as a generic error ---
    {
        bool threw = false;
        try {
            sql << "insert into person (id, name) values (1, 'duplicate key')";
        } catch (const soci::sqlite3_soci_error& e) {
            threw = true;
            assert(e.get_error_category() == soci::soci_error::constraint_violation);
        }
        assert(threw);
    }

    // The whole file asserts; this last one is deliberately NOT an assert. The
    // build could in principle be configured with NDEBUG, in which case every
    // assert() above evaporates and a broken package would still exit 0 -- so
    // the one check that makes the exit code itself meaningful is written out
    // longhand.
    sql << "select count(*) from person", soci::into(count);
    return count == 4 ? 0 : 1;
}
