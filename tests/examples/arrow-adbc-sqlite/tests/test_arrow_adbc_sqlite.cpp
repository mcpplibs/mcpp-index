#include <arrow-adbc/adbc.h>
#include <arrow-adbc/adbc_driver_manager.h>
#include <arrow-adbc/driver/sqlite.h>

#include <cassert>
#include <cstdint>
#include <cstring>
#include <iostream>
#include <string>
#include <utility>
#include <vector>

namespace {

void CheckStatus(AdbcStatusCode status, struct AdbcError* err, const char* step) {
  if (status != ADBC_STATUS_OK) {
    std::cerr << step << " failed (" << AdbcStatusCodeMessage(status) << "): "
              << (err->message ? err->message : "(no message)") << "\n";
    if (err->release) {
      err->release(err);
    }
    assert(status == ADBC_STATUS_OK);
  }
  if (err->release) {
    err->release(err);
  }
}

void ExecUpdate(struct AdbcConnection* conn, const char* sql) {
  struct AdbcError err = ADBC_ERROR_INIT;
  struct AdbcStatement stmt = {};
  CheckStatus(AdbcStatementNew(conn, &stmt, &err), &err, "AdbcStatementNew");
  CheckStatus(AdbcStatementSetSqlQuery(&stmt, sql, &err), &err, "AdbcStatementSetSqlQuery");
  int64_t rows_affected = -1;
  CheckStatus(AdbcStatementExecuteQuery(&stmt, nullptr, &rows_affected, &err), &err,
              "AdbcStatementExecuteQuery");
  CheckStatus(AdbcStatementRelease(&stmt, &err), &err, "AdbcStatementRelease");
}

}  // namespace

int main() {
  struct AdbcError err = ADBC_ERROR_INIT;
  struct AdbcDatabase db = {};
  struct AdbcConnection conn = {};
  struct AdbcStatement stmt = {};

  CheckStatus(AdbcDatabaseNew(&db, &err), &err, "AdbcDatabaseNew");
  CheckStatus(AdbcDriverManagerDatabaseSetInitFunc(&db, &AdbcDriverSqliteInit, &err), &err,
              "AdbcDriverManagerDatabaseSetInitFunc");
  CheckStatus(AdbcDatabaseSetOption(&db, ADBC_OPTION_URI, ":memory:", &err), &err,
              "AdbcDatabaseSetOption(uri)");
  CheckStatus(AdbcDatabaseInit(&db, &err), &err, "AdbcDatabaseInit");

  CheckStatus(AdbcConnectionNew(&conn, &err), &err, "AdbcConnectionNew");
  CheckStatus(AdbcConnectionInit(&conn, &db, &err), &err, "AdbcConnectionInit");

  ExecUpdate(&conn, "CREATE TABLE items (id INTEGER, label TEXT)");
  ExecUpdate(&conn, "INSERT INTO items VALUES (1, 'alpha'), (2, 'beta'), (3, 'gamma')");

  CheckStatus(AdbcStatementNew(&conn, &stmt, &err), &err, "AdbcStatementNew(select)");
  CheckStatus(AdbcStatementSetSqlQuery(&stmt, "SELECT id, label FROM items ORDER BY id", &err),
              &err, "AdbcStatementSetSqlQuery(select)");

  struct ArrowArrayStream stream = {};
  int64_t rows_affected = 0;
  CheckStatus(AdbcStatementExecuteQuery(&stmt, &stream, &rows_affected, &err), &err,
              "AdbcStatementExecuteQuery(select)");

  struct ArrowSchema schema = {};
  assert(stream.get_schema(&stream, &schema) == 0);
  assert(schema.n_children == 2);
  assert(std::string(schema.children[0]->name) == "id");
  assert(std::string(schema.children[0]->format) == "l");
  assert(std::string(schema.children[1]->name) == "label");
  assert(std::string(schema.children[1]->format) == "u");
  if (schema.release) {
    schema.release(&schema);
  }

  std::vector<std::pair<int64_t, std::string>> rows;
  while (true) {
    struct ArrowArray batch = {};
    assert(stream.get_next(&stream, &batch) == 0);
    if (!batch.release) {
      break;
    }
    assert(batch.n_children == 2);
    const struct ArrowArray* id_col = batch.children[0];
    const struct ArrowArray* label_col = batch.children[1];
    assert(id_col->length == batch.length);
    assert(label_col->length == batch.length);

    const auto* ids = static_cast<const int64_t*>(id_col->buffers[1]);
    const auto* offsets = static_cast<const int32_t*>(label_col->buffers[1]);
    const auto* chars = static_cast<const char*>(label_col->buffers[2]);
    assert(ids != nullptr);
    assert(offsets != nullptr);
    assert(chars != nullptr);

    for (int64_t i = 0; i < batch.length; ++i) {
      const int64_t id_idx = batch.offset + id_col->offset + i;
      const int64_t label_idx = batch.offset + label_col->offset + i;
      const int32_t start = offsets[label_idx];
      const int32_t end = offsets[label_idx + 1];
      rows.emplace_back(ids[id_idx], std::string(chars + start, static_cast<size_t>(end - start)));
    }
    batch.release(&batch);
  }

  if (stream.release) {
    stream.release(&stream);
  }

  assert(rows.size() == 3);
  assert(rows[0].first == 1 && rows[0].second == "alpha");
  assert(rows[1].first == 2 && rows[1].second == "beta");
  assert(rows[2].first == 3 && rows[2].second == "gamma");

  CheckStatus(AdbcStatementRelease(&stmt, &err), &err, "AdbcStatementRelease");
  CheckStatus(AdbcConnectionRelease(&conn, &err), &err, "AdbcConnectionRelease");
  CheckStatus(AdbcDatabaseRelease(&db, &err), &err, "AdbcDatabaseRelease");

  std::cout << "arrow-adbc-sqlite tests passed (" << rows.size() << " rows verified)\n";
  return 0;
}
