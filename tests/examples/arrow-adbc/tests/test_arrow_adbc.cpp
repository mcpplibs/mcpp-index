#include <arrow-adbc/adbc.h>
#include <arrow-adbc/adbc_driver_manager.h>

#include <cassert>
#include <cstring>
#include <iostream>
#include <string>

namespace {

bool g_stub_init_called = false;
bool g_stub_db_released = false;

AdbcStatusCode StubDatabaseNew(struct AdbcDatabase* /*db*/, struct AdbcError* /*error*/) {
  return ADBC_STATUS_OK;
}

AdbcStatusCode StubDatabaseInit(struct AdbcDatabase* /*db*/, struct AdbcError* /*error*/) {
  g_stub_init_called = true;
  return ADBC_STATUS_OK;
}

AdbcStatusCode StubDatabaseRelease(struct AdbcDatabase* /*db*/, struct AdbcError* /*error*/) {
  g_stub_db_released = true;
  return ADBC_STATUS_OK;
}

AdbcStatusCode StubConnectionNew(struct AdbcConnection* /*conn*/, struct AdbcError* /*error*/) {
  return ADBC_STATUS_OK;
}

AdbcStatusCode StubConnectionInit(struct AdbcConnection* /*conn*/, struct AdbcDatabase* /*db*/,
                                  struct AdbcError* /*error*/) {
  return ADBC_STATUS_OK;
}

AdbcStatusCode StubConnectionRelease(struct AdbcConnection* /*conn*/, struct AdbcError* /*error*/) {
  return ADBC_STATUS_OK;
}

AdbcStatusCode StubStatementNew(struct AdbcConnection* /*conn*/, struct AdbcStatement* /*stmt*/,
                                 struct AdbcError* /*error*/) {
  return ADBC_STATUS_OK;
}

AdbcStatusCode StubStatementExecuteQuery(struct AdbcStatement* /*stmt*/,
                                         struct ArrowArrayStream* /*out*/,
                                         int64_t* /*rows_affected*/,
                                         struct AdbcError* /*error*/) {
  return ADBC_STATUS_NOT_IMPLEMENTED;
}

AdbcStatusCode StubStatementRelease(struct AdbcStatement* /*stmt*/, struct AdbcError* /*error*/) {
  return ADBC_STATUS_OK;
}

AdbcStatusCode StubDriverInit(int version, void* raw_driver, struct AdbcError* /*error*/) {
  if (version != ADBC_VERSION_1_0_0 && version != ADBC_VERSION_1_1_0) {
    return ADBC_STATUS_NOT_IMPLEMENTED;
  }
  auto* driver = static_cast<struct AdbcDriver*>(raw_driver);
  driver->DatabaseNew = &StubDatabaseNew;
  driver->DatabaseInit = &StubDatabaseInit;
  driver->DatabaseRelease = &StubDatabaseRelease;
  driver->ConnectionNew = &StubConnectionNew;
  driver->ConnectionInit = &StubConnectionInit;
  driver->ConnectionRelease = &StubConnectionRelease;
  driver->StatementNew = &StubStatementNew;
  driver->StatementExecuteQuery = &StubStatementExecuteQuery;
  driver->StatementRelease = &StubStatementRelease;
  return ADBC_STATUS_OK;
}

void ReleaseError(struct AdbcError* err) {
  if (err->release) {
    err->release(err);
  }
}

void TestMissingDriverDatabaseInit() {
  struct AdbcError err = ADBC_ERROR_INIT;
  struct AdbcDatabase db = {};

  assert(AdbcDatabaseNew(&db, &err) == ADBC_STATUS_OK);
  assert(AdbcDriverManagerDatabaseSetLoadFlags(&db, ADBC_LOAD_FLAG_DEFAULT, &err) ==
         ADBC_STATUS_OK);
  assert(AdbcDatabaseSetOption(&db, "driver", "nonexistent_adbc_driver_for_mcpp_test", &err) ==
         ADBC_STATUS_OK);

  const AdbcStatusCode rc = AdbcDatabaseInit(&db, &err);
  assert(rc != ADBC_STATUS_OK);
  assert(err.message != nullptr);
  assert(std::strlen(err.message) > 0);
  std::cout << "Missing driver DatabaseInit error: " << err.message << "\n";
  ReleaseError(&err);

  assert(AdbcDatabaseRelease(&db, &err) == ADBC_STATUS_OK);
  ReleaseError(&err);
}

void TestMissingDriverLoadDriver() {
  struct AdbcError err = ADBC_ERROR_INIT;
  struct AdbcDriver driver = {};

  const AdbcStatusCode rc =
      AdbcLoadDriver("nonexistent_adbc_driver_for_mcpp_test", nullptr,
                     ADBC_VERSION_1_1_0, &driver, &err);
  assert(rc != ADBC_STATUS_OK);
  assert(err.message != nullptr);
  assert(std::strlen(err.message) > 0);
  std::cout << "Missing driver LoadDriver error: " << err.message << "\n";
  ReleaseError(&err);
}

void TestInProcessInitFunc() {
  g_stub_init_called = false;
  g_stub_db_released = false;

  struct AdbcError err = ADBC_ERROR_INIT;
  struct AdbcDatabase db = {};

  assert(AdbcDatabaseNew(&db, &err) == ADBC_STATUS_OK);
  assert(AdbcDriverManagerDatabaseSetInitFunc(&db, &StubDriverInit, &err) == ADBC_STATUS_OK);
  assert(AdbcDatabaseInit(&db, &err) == ADBC_STATUS_OK);
  assert(g_stub_init_called);

  assert(AdbcDatabaseRelease(&db, &err) == ADBC_STATUS_OK);
  assert(g_stub_db_released);
  ReleaseError(&err);
}

}  // namespace

int main() {
  assert(AdbcStatusCodeMessage(ADBC_STATUS_OK) != nullptr);
  TestMissingDriverDatabaseInit();
  TestMissingDriverLoadDriver();
  TestInProcessInitFunc();
  std::cout << "arrow-adbc driver manager tests passed\n";
  return 0;
}
