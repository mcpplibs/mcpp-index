#ifdef HAVE_LIBMYSQLCLIENT
#include <mysql.h>

// 断言客户端 ABI 版本，并确认初始化得到可用的运行时句柄。
int main() {
    static_assert(MYSQL_VERSION_ID == 80406);
    if (mysql_get_client_version() != 80406) return 1;

    MYSQL* client = mysql_init(nullptr);
    if (client == nullptr) return 2;
    mysql_close(client);
    return 0;
}
#else
#error "HAVE_LIBMYSQLCLIENT must be enabled for every declared libmysqlclient test platform"
#endif
