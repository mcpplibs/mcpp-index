-- compat.apriltag — AprilTag 3.4.5, a visual fiducial detection library.
--
-- Shape A (C-source compat). The upstream CMake target consists of the
-- detector, pose/thresholding code, all common helpers, and every generated
-- tag family (including the ArUco families). Keep the source globs aligned
-- with that target rather than compiling examples or the Python wrapper.
--
-- The same source set builds on Linux, macOS, and Windows. Platform-specific
-- defines and system libraries mirror the upstream CMake target.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "apriltag",
    description = "AprilTag visual fiducial detection library",
    licenses    = {"BSD-2-Clause", "MIT"},
    repo        = "https://github.com/AprilRobotics/apriltag",
    type        = "package",

    xpm = {
        linux = {
            ["3.4.5"] = {
                url    = "https://github.com/AprilRobotics/apriltag/archive/refs/tags/v3.4.5.tar.gz",
                sha256 = "3749f48220db78c29c375a373861f4e1f4138e5dbae3c298584e96cfcc556515",
            },
        },
        macosx = {
            ["3.4.5"] = {
                url    = "https://github.com/AprilRobotics/apriltag/archive/refs/tags/v3.4.5.tar.gz",
                sha256 = "3749f48220db78c29c375a373861f4e1f4138e5dbae3c298584e96cfcc556515",
            },
        },
        windows = {
            ["3.4.5"] = {
                url    = "https://github.com/AprilRobotics/apriltag/archive/refs/tags/v3.4.5.tar.gz",
                sha256 = "3749f48220db78c29c375a373861f4e1f4138e5dbae3c298584e96cfcc556515",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c99",
        include_dirs = { "*" },
        sources      = {
            "*/apriltag.c",
            "*/apriltag_pose.c",
            "*/apriltag_quad_thresh.c",
            "*/common/*.c",
            "*/tag*.c",
            "*/aruco/tag*.c",
        },
        targets = { ["apriltag"] = { kind = "lib" } },
        linux = {
            cflags  = { "-D_GNU_SOURCE" },
            ldflags = { "-lpthread", "-lm" },
        },
        macosx = {
            cflags  = { "-D_DARWIN_C_SOURCE" },
            ldflags = { "-lpthread", "-lm" },
        },
        windows = {
            cflags = {
                "-D_USE_MATH_DEFINES",
                "-DWIN32_LEAN_AND_MEAN",
                "-D_CRT_SECURE_NO_WARNINGS",
                "-D_CRT_NONSTDC_NO_DEPRECATE",
            },
        },
        deps    = { },
    },
}
