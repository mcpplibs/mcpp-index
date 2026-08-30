-- compat.wayland-scanner — the Wayland protocol code generator, built from source.
--
-- Form A: the manifest lives in mcpplibs/wayland-m, a fork of freedesktop's
-- wayland 1.23.1 that adds mcpp build support and patches nothing.
--
-- WHY A FORK RATHER THAN AN INLINE DESCRIPTOR HERE
--
-- wayland's libraries are mostly GENERATED — protocol/wayland.xml describes
-- every interface and wayland-scanner emits ~12,000 lines from it — and the
-- generator is a C program in the same tree, so it must be COMPILED before it
-- can run. An inline descriptor has no build step, and an install() hook cannot
-- do it either: mcpp compiles a package's sources at CONSUMER-BUILD time, so no
-- package binary exists while another package is installing. `build.mcpp` is
-- the mechanism for exactly this, and it only exists for a real mcpp project.
-- Same shape and same reason as mcpplibs/grpc-m.
--
-- The one tarball backs three index entries, each pointing at a different
-- workspace member — the layout grpc/grpcgen/grpc-plugin already use.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "wayland-scanner",
    description = "wayland-scanner — the Wayland protocol code generator, built from source",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/wayland-m",
    type        = "package",

    xpm = {
        linux = {
            ["1.23.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/wayland-m/archive/refs/tags/v1.23.1-1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/wayland/releases/download/1.23.1/wayland-m-1.23.1-1.tar.gz",
                },
                sha256 = "16ac3d6d22eb1973d2c83b47cc0d4518160837a5597298e3799228d155c43c86",
            },
        },
    },

    mcpp = "*/mcpp/scanner/mcpp.toml",
}
