package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.glfw",
    description = "GLFW windowing and input library built from source with the null platform backend",
    licenses    = {"Zlib"},
    repo        = "https://github.com/glfw/glfw",
    type        = "package",

    xpm = {
        linux = {
            ["3.4"] = {
                url    = "https://github.com/glfw/glfw/archive/refs/tags/3.4.tar.gz",
                sha256 = "c038d34200234d071fae9345bc455e4a8f2f544ab60150765d7704e08f3dac01",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        cflags       = { "-D_DEFAULT_SOURCE" },
        include_dirs = {"*/include", "*/src"},
        sources = {
            "*/src/context.c",
            "*/src/init.c",
            "*/src/input.c",
            "*/src/monitor.c",
            "*/src/platform.c",
            "*/src/vulkan.c",
            "*/src/window.c",
            "*/src/egl_context.c",
            "*/src/osmesa_context.c",
            "*/src/null_init.c",
            "*/src/null_monitor.c",
            "*/src/null_window.c",
            "*/src/null_joystick.c",
            "*/src/posix_time.c",
            "*/src/posix_thread.c",
            "*/src/posix_module.c",
        },
        targets = { ["glfw"] = { kind = "lib" } },
        deps    = {
            ["compat.opengl"] = "2026.05.31",
        },
    },
}
