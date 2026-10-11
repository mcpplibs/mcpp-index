# AprilTag 3.4.5 compat package

- Source: [AprilRobotics/apriltag](https://github.com/AprilRobotics/apriltag), release `v3.4.5`.
- Shape: Form B, C-source compat. The descriptor follows the upstream CMake
  library target: detector/pose/thresholding sources, `common/*.c`, all
  generated `tag*.c` families, and the `aruco/tag*.c` families. Examples and
  the optional Python wrapper are not library sources.
- Platform: Linux, macOS, and Windows. The same source set is used on all
  three platforms. The descriptor supplies `_GNU_SOURCE` plus pthread/libm on
  Linux, `_DARWIN_C_SOURCE` plus pthread/libm on macOS, and the Windows
  CRT/math defines used by the upstream CMake build.
- API/build language: `c_standard = "c99"` for the C sources; the package
  manifest remains `language = "c++23"` so it follows mcpp's C++20-and-newer
  consumer contract. Platform-specific defines are supplied to the package's
  C translation units because the upstream CMake build uses platform CRT
  extensions for declarations such as `timespec`, `strdup`, and math constants.
- Archive: `https://github.com/AprilRobotics/apriltag/archive/refs/tags/v3.4.5.tar.gz`.
  SHA-256 is
  `3749f48220db78c29c375a373861f4e1f4138e5dbae3c298584e96cfcc556515`.
  No CN mirror is declared because no mcpp-res upload was available; the
  descriptor uses the permitted plain upstream URL fallback.
- Test: `tests/examples/apriltag` is a cross-platform member that creates a detector and the
  `tagStandard41h12` family, runs detection on a blank image, checks the empty
  result, and destroys every object. This verifies header exposure, all
  required symbols, pthread linkage, and the basic runtime lifecycle.
