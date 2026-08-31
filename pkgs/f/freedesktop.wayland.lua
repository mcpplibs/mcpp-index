-- freedesktop.wayland — libwayland-client, plus `import freedesktop.wayland.client;`.
--
-- Form A: the manifest lives in mcpplibs/wayland, a fork of freedesktop's
-- wayland 1.26.0 that adds mcpp build support and patches no upstream file.
--
-- WHY A FORK RATHER THAN AN INLINE DESCRIPTOR
--
-- wayland's libraries are mostly GENERATED — protocol/wayland.xml describes
-- every interface and wayland-scanner emits ~13,000 lines from it — and the
-- generator is a C program in the same tree, so it has to be COMPILED before it
-- can run. An inline descriptor has no build step, and an install() hook cannot
-- do it either: mcpp compiles a package's sources at CONSUMER-BUILD time, so no
-- package binary exists while another package is installing. `build.mcpp` is
-- the mechanism for exactly this, and it only exists for a real mcpp project.
-- Same shape and same reason as mcpplibs/grpc-m.
--
-- One tarball backs four index entries, each pointing at a different workspace
-- member — the layout grpc/grpcgen/grpc-plugin already use. They are four
-- packages rather than one because `libwayland-client.so.0` and
-- `libwayland-server.so.0` are distinct SONAMEs that Mesa's libEGL_mesa needs
-- BOTH of, and mcpp links every library target in a package against all of its
-- sources — so one package cannot emit two libraries with disjoint contents.
--
-- ─────────────────────────────────────────────────────────────────────────
-- ⭐ wl_fixed_* 在 mcpp4 之前够不着(已修复)
--
-- `wayland-util.h` 把四个定点数转换定义成 `static inline`(内部链接),模块
-- 无法导出。而 `wl_fixed_t` 是协议里**每一个亚像素坐标**的载体 —— wl_pointer
-- 的移动、触摸点、数位板轴 —— 所以走模块路线的客户端**处理不了输入事件**。
--
-- ⚠️ 它们放在**这个**模块而不是 `freedesktop.wayland.util`:那个模块是和头文件
-- **配对**设计的(只出宏和模板,零个 `using ::`),加同名实体会让每次调用在
-- clang 上 `ambiguous`。也没有同时放进 server —— 两个模块各自的实体,对同时
-- import 两者的 TU 一样是二义。三个模块同时 import 已在两条工具链上实测。
package = {
    spec        = "1",
    namespace   = "freedesktop",
    name        = "wayland",
    description = "libwayland-client — the client side of the Wayland protocol, with a C++23 module wrapper",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/wayland",
    type        = "package",

    xpm = {
        linux = {
            ["1.26.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/wayland/releases/download/v1.26.0/wayland-1.26.0-mcpp4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/wayland/releases/download/1.26.0/wayland-1.26.0-mcpp4.tar.gz",
                },
                sha256 = "9bce2cc00c61399a3c2fb15e730b664073694154860bc5e2b4496bcf09e55e52",
            },
        },
    },

    mcpp = "*/mcpp/client/mcpp.toml",
}
