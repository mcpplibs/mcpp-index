# mcpp-index: GL Runtime Packages Plan

> 状态: active
> 分支: `codex/gl-runtime-closure-index`
> PR: pending
> Last updated: 2026-06-03
> 目标: 让 GLFW/OpenGL 相关包描述表达标准运行时需求,而不是依赖 smoke 脚本里的临时 `LD_LIBRARY_PATH` shim。

## Scope

This repository owns package metadata and package-level smoke tests. It should
model OpenGL headers, GL dispatch/runtime libraries, and system GPU/display
requirements as separate concepts.

## Package Boundary

- `compat.opengl`
  - Keep as Khronos OpenGL registry/header provider.
  - Do not turn it into a host driver wrapper.
- `compat.glfw`
  - Owns GLFW source build and X11/GLX backend selection.
  - Should declare runtime requirements for the GLX libraries it loads through
    GLFW's upstream `dlopen` behavior.
- `compat.glvnd` or `compat.libglvnd`
  - New standard runtime package candidate for GL dispatch libraries:
    `libOpenGL.so`, `libGL.so`, `libGLX.so`, `libGLdispatch.so`.
- `compat.mesa-llvmpipe`
  - Optional follow-up for self-contained software rendering and CI/headless
    validation. This is larger and should not block the first metadata path.
- Host GPU/OpenGL driver
  - Model as a system capability such as `opengl.glx.driver`.
  - Do not silently pretend vendor drivers are normal redistributable packages.

## Implementation Plan

- [x] Create this repository-level plan checkpoint.
- [ ] Keep `compat.opengl` header-only and update docs if needed.
  - Candidate file: `pkgs/c/compat.opengl.lua`.
- [ ] Add a GL runtime provider package.
  - Candidate file: `pkgs/c/compat.glvnd.lua`.
  - The first version may expose libglvnd runtime/headers if the source build
    is practical in current mcpp package descriptors.
  - If libglvnd source packaging is not yet practical, keep this task open and
    document the exact blocker rather than replacing it with a host shim.
- [x] Update `compat.glfw` runtime metadata.
  - Candidate file: `pkgs/c/compat.glfw.lua`.
  - Declare `dlopen_libs = {"libGLX.so.0", "libGL.so.1", "libGL.so"}`.
  - Declare `capabilities = {"x11.display", "opengl.glx.driver"}` for Linux
    X11/GLX window execution.
  - Keep X11 link/runtime packages as normal dependencies.
- [ ] Replace script-only GL runtime behavior in the window smoke.
  - Candidate file: `tests/smoke_compat_imgui_window.sh`.
  - The target behavior is `mcpp run` with package-declared runtime metadata.
  - The existing host shim may remain only as diagnostic evidence until the
    mcpp runtime metadata support lands.
- [x] Add README package semantics.
  - Candidate file: `README.md`.
  - Document the difference between OpenGL headers, GL runtime dispatch, and
    host display/GPU capabilities.

## Verification

- [x] `lua5.4 -e "assert(loadfile('pkgs/c/compat.glfw.lua', 't'))"`
- [x] `lua5.4 -e "assert(loadfile('pkgs/c/compat.opengl.lua', 't'))"`
- [x] Lua syntax check for all `pkgs/**/*.lua`
- [x] `bash -n tests/smoke_compat_imgui_window.sh`
- [x] Static metadata check: `compat.glfw` contains `dlopen_libs`,
      `libGLX.so.0`, and `opengl.glx.driver`.
- [ ] `MCPP=<mcpp> tests/smoke_compat_imgui.sh`
- [ ] `MCPP=<mcpp> tests/smoke_compat_imgui_window.sh`
  - Attempted locally on 2026-06-03; the run was stopped after the temporary
    sandbox stalled in dependency installation. This remains unchecked until a
    full smoke completes.
- [ ] `MCPP=<mcpp> MCPP_INDEX_RUN_WINDOW_SMOKE=1 tests/smoke_compat_imgui_window.sh`
- [ ] A focused GLFW/OpenGL smoke that uses `mcpp run` without script-local
      `LD_LIBRARY_PATH` once mcpp runtime metadata support is available.

## PR / CI / Merge Notes

- [x] Commit this plan as the first checkpoint.
- [ ] Open a PR with sanitized paths and no local machine details.
- [ ] Include a test plan and note which runtime checks require a display.
- [ ] Wait for repository validation CI.
- [ ] Squash merge after required checks pass.

## Cross-Repository Dependencies

- Depends on `mcpp` runtime metadata support for the final no-shim run smoke.
- Feeds `imgui-m` validation by making its window example runnable through
  standard package metadata.
- Does not require `xim-pkgindex` until a released mcpp or package-index update
  needs to be mirrored or distributed through xlings.
