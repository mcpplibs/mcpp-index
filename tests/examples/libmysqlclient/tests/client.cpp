#ifdef HAVE_LIBMYSQLCLIENT
#include <mysql.h>

int main() {
    static_assert(MYSQL_VERSION_ID == 80406);
    if (mysql_get_client_version() != 80406) return 1;

    MYSQL* client = mysql_init(nullptr);
    if (client == nullptr) return 2;
    mysql_close(client);
    return 0;
}
#else
int main() { return 0; }
#endif
