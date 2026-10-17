# GLFW Windows package closure

The existing gui-stack and imgui-window members gate GLFW behind Linux, leaving
Windows package compilation/linkage untested. Add a standalone glfw workspace
member with a local compat index and no other direct dependencies. Test Null
windows everywhere and require native Win32 initialization and hidden window
behavior on Windows; use GLFW_NO_API and GLFW_INCLUDE_NONE.

PR #538's initial Windows run (39048720103, job 117442681476) reproduced
undefined LoadCursorW, CreateWindowExW, RegisterClassExW and DragAcceptFiles.
All references originate in GLFW's own win32 sources, not the consumer.

Declare user32 (window/input), gdi32 (pixel formats), and shell32 (drag/drop) in
windows.runtime.libraries. Upstream CMake gets user32/shell32 from CMake's default
Windows standard libraries; the direct clang driver does not. Retain the existing
dialect-neutral form rather than raw linker flags. GLFW dynamically loads its
OpenGL, XInput, DirectInput and DWM functions; no new import libraries are needed
for those. Application calls to OpenGL/Vulkan remain the consumer's responsibility.

Publish index revision 3.4.0.2 on all three platforms (same upstream 3.4 archive,
URLs, SHA and install hook), so existing installed metadata can be refreshed by
selecting the new version. Upstream source version remains 3.4.0. Retain historical
versions and existing consumers' pins. The new test consumes 3.4.0.2.

Validation: CI uses mcpp 2026.10.1.2. Initial Windows failure is the regression
proof; final PR checks must cover the fix, including execution of the Win32 test.
