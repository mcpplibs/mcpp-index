-- freedesktop.wayland-server — libwayland-server, plus `import freedesktop.wayland.server;`.
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
-- ⭐ wl_signal_* 在 mcpp4 之前够不着(已修复)
--
-- `wayland-server-core.h` 把 wl_signal_init / _add / _get / _emit 定义成
-- `static inline` —— 内部链接,C++ 禁止从模块导出。于是走**模块路线**的消费者
-- 一个都拿不到。
--
-- 这不是边角:每一次 wlroots 监听注册都是
-- `wl_signal_add(&thing->events.x, &listener)`,所以**用模块写不了合成器**。
--
-- ⚠️ 一直没发现,是因为这个包的测试从没调用过其中任何一个。缺口是从**外面**
-- 被问出来的 —— 一个最小 wlroots 合成器编不过。同一类问题在
-- `freedesktop.cairo`(少 cairo_t)和 `displayinfo`(少 295 个枚举量)上都出现
-- 过,发现方式也一样:**自己的测试问不出来,别的包在真实用途里能。**
package = {
    spec        = "1",
    namespace   = "freedesktop",
    name        = "wayland-server",
    description = "libwayland-server — the compositor side of the Wayland protocol, with a C++23 module wrapper",
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

    mcpp = "*/mcpp/server/mcpp.toml",
}
