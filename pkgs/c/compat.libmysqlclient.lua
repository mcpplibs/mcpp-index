-- Form A: 发布归档自带根级 mcpp.toml，消费者直接用 mcpp 构建客户端静态库。
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libmysqlclient",
    description = "MySQL C API client library (static, client-only source)",
    licenses    = {"GPL-2.0-only", "Universal-FOSS-exception-1.0"},
    repo        = "https://github.com/wellwei/libmysqlclient",
    type        = "package",

    xpm = {
        linux = {
            ["8.4.6"] = {
                url = "https://github.com/wellwei/libmysqlclient/archive/refs/tags/8.4.6.tar.gz",
                sha256 = "d5ac8e22b31a3dd7118749e85edee82237ded588eef6c5a2445a542a9d5abe5a",
            },
        },
        macosx = {
            ["8.4.6"] = {
                url = "https://github.com/wellwei/libmysqlclient/archive/refs/tags/8.4.6.tar.gz",
                sha256 = "d5ac8e22b31a3dd7118749e85edee82237ded588eef6c5a2445a542a9d5abe5a",
            },
        },
        windows = {
            ["8.4.6"] = {
                url = "https://github.com/wellwei/libmysqlclient/archive/refs/tags/8.4.6.tar.gz",
                sha256 = "d5ac8e22b31a3dd7118749e85edee82237ded588eef6c5a2445a542a9d5abe5a",
            },
        },
    },

    -- 无 `mcpp` 字段：默认查找会命中归档根目录的 mcpp.toml。
}
