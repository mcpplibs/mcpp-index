# OpenCV WebP provider checkpoint

OpenCV 5.0.0 grfmt_webp.cpp uses encoding/decoding, animation, EXIF/XMP/ICC
containers and therefore requires both upstream WebP mux and demux implementations.
The existing compat.libwebp 1.5.0 source recipe retains ownership of this C library;
no second vendored implementation or module wrapper is introduced.

- `demux` adds src/demux/*.c; `mux` adds src/mux/*.c. Each is independent and additive.
- Default encode/decode/sharpyuv source selection, architecture gates and flags are unchanged.
- All three historical platform version/URL/hash blocks remain byte-identical.
- COPYING, PATENTS and AUTHORS are explicitly deployed under licenses/libwebp.
- The existing workspace consumer now requests both features. Its additional
  standalone test encodes two lossless animation frames, muxes an EXIF chunk,
  demuxes the metadata and checks decoded pixels and timestamps. Checks survive NDEBUG.

Linux verification uses mcpp 2026.10.24.1 and LLVM23.1.3. Strict fresh projects
passed both the original roundtrip and container test (1.28 seconds), then a
separate unchanged-default dependency passed the original test (1.72 seconds).
Actual compile_commands.json includes mux/demux only for the enabled variant.
Logs: /tmp/mwrap-webp-provider-variants-final.log. All work uses the shared
sixteen-core/32 GiB test slice with three build jobs and disk/memory guards.

The direct workspace-root strict command rejects its pre-existing deprecated
index inheritance; isolated projects use the byte-identical compat test view,
without editing the client or suppressing diagnostics. Normal workspace/native
CI remains required on this exact index head. OpenCV imgcodecs-webp integration,
its source matrix and actual archive/deployment consumer are separate gates.

## Archive and deployment acceptance

OpenCV source 16baa03ef4353188c816a6ff5962a5da53998814 was downloaded twice
with SHA256 556df2142b56cac8f635597bcec9bf32a45957cc0203cff0feb5cf9e256b09c1.
The new tests/mwrap/opencv-webp member consumes that actual source archive.
An isolated home with the complete unchanged publication index strictly built
and ran the consumer, then packed a release application and ran the relocated
bundle with an empty home and cleared library/runtime overrides. Lossless alpha
and transparent RGB, two-frame timing/loop count, XMP bytes and WEBP build
information checks passed. ELF dependencies resolve within the bundle. All
fourteen OpenCV/wrapper notices plus three libwebp notices match their original
source bytes. Log: /tmp/mwrap-webp-archive-deployment.log.

The deployment helper is also registered for native default-toolchain workspace
CI when opencv-webp is selected; ordinary member tests cover other compiler legs.
All seventeen pinned-updater regressions pass, and the full audit still covers
91 automatic declarations/two reviewed snapshots with historical versions intact.
The initial local unittest invocation lacked the workflow's pinned-updater
PYTHONPATH; the successful rerun uses /tmp/mwrap-updater-6c0bee/src.
Native CI results are required on the final source/index commits; these local
checks do not certify Windows/macOS/musl behavior by inference.
