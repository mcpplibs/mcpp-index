# Standalone GLFW smoke test

From the repository root, run `mcpp test -p glfw` (including on Windows).
The manifest redirects `compat` to this checkout so the test checks the PR's
package descriptor rather than the published index.

The test checks the upstream version and creates a Null-platform window on every
platform. On Windows it also requires the Win32 backend, creates a hidden native
window, checks its size and user pointer, polls events, and closes it. A failed
initialization or window creation fails the test. No visible window or graphics
context is required.

The only direct dependency is `compat.glfw`. `GLFW_INCLUDE_NONE` and
`GLFW_NO_API` keep graphics API headers and context creation out of this test.
GLFW's own native system-library references belong in the package descriptor;
libraries used directly by an application (for example OpenGL entry points or a
Vulkan loader) belong to that application. GLFW dynamically loads several
optional Windows APIs, so their DLL names alone are not a reason to add import
libraries. Keep dialect-neutral native link requirements in `runtime.libraries`.
