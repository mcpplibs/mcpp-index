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
                sha256 = "8ef7f8a63d21e38b06bfbdb9bd3c4660cc063b535c3f13cdd9451295b0ba9c15",
            },
        },
        macosx = {
            ["8.4.6"] = {
                url = "https://github.com/wellwei/libmysqlclient/archive/refs/tags/8.4.6.tar.gz",
                sha256 = "8ef7f8a63d21e38b06bfbdb9bd3c4660cc063b535c3f13cdd9451295b0ba9c15",
            },
        },
        windows = {
            ["8.4.6"] = {
                url = "https://github.com/wellwei/libmysqlclient/archive/refs/tags/8.4.6.tar.gz",
                sha256 = "8ef7f8a63d21e38b06bfbdb9bd3c4660cc063b535c3f13cdd9451295b0ba9c15",
            },
        },
    },

    -- 无 `mcpp` 字段：默认查找会命中归档根目录的 mcpp.toml。
}
