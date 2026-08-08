#ifdef HAVE_MYSQL_CONNECTOR_CPP
#include <mysqlx/xdevapi.h>
#include <mysql/jdbc.h>

#include <string>

int main() {
    // 同一个 Connector/C++ 包应同时提供 X DevAPI 和 JDBC。
    mysqlx::Value value(std::string("mcpp"));
    if (value.get<std::string>() != "mcpp") return 1;

    sql::mysql::MySQL_Driver* driver = sql::mysql::get_mysql_driver_instance();
    if (driver == nullptr) return 2;
    if (driver->getMajorVersion() != 26) return 3;
    if (driver->getMinorVersion() != 7) return 4;
    return driver->getPatchVersion() == 0 ? 0 : 5;
}
#else
int main() { return 0; }
#endif
