-- freedesktop.wayland-scanner — the Wayland protocol code generator.
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
package = {
    spec        = "1",
    namespace   = "freedesktop",
    name        = "wayland-scanner",
    description = "wayland-scanner — the Wayland protocol code generator, built from source",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/wayland",
    type        = "package",

    xpm = {
        linux = {
            ["1.26.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/wayland/releases/download/v1.26.0/wayland-1.26.0-mcpp2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/wayland/releases/download/1.26.0/wayland-1.26.0-mcpp2.tar.gz",
                },
                sha256 = "bcf388cc1dd6617fdce5cb595defbe2aa1fae8db292ca5d7fd84afda2811be32",
            },
        },
    },

    mcpp = "*/mcpp/scanner/mcpp.toml",
}
