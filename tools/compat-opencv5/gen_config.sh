#!/bin/sh
# gen_config.sh — maintainer-time descriptor pipeline for compat.opencv5.
#
# Fetches the pinned OFFICIAL OpenCV tarball (fetch_upstream.sh alongside),
# runs CMake ONCE with the frozen hermetic profile, runs the reference ninja
# build so the build-time generators (cl2cpp, blob2hdr, dispatch stubs)
# materialize, dumps the full compile-command list (`ninja -t commands` —
# state-independent, unlike `ninja -n`), and emits the mcpp-index descriptor
# via gen_descriptor.py alongside. Consumers never run this: OpenCV reaches
# them as the compat.opencv5 package (frozen config + build.mcpp synthesis).
#
# Usage: tools/compat-opencv5/gen_config.sh [target] [out.lua]
#   target  default: autodetected <os>-<arch>   (only linux-x86_64 supported yet)
#   out.lua default: <this repo>/pkgs/c/compat.opencv5.lua
#
# NOTE: use a real host gcc via CC/CXX if the default `cc` is shimmed to a
# cross toolchain (xlings subos). Host gcc 13 ICEs on two AVX2 bfloat TUs —
# harmless here (ninja -k skips them; only the generators' outputs matter).
set -eu

target="${1:-$(uname -s | tr 'A-Z' 'a-z' | sed s/darwin/macos/)-$(uname -m | sed s/arm64/aarch64/)}"
here="$(cd "$(dirname "$0")" && pwd)"
index_root="$(cd "$here/../.." && pwd)"
version="${OPENCV_VERSION:-5.0.0}"
sha256="${OPENCV_SHA256:-b0528f5a1d379d59d4701cb28c36e22214cc51cf64594e5b56f2d3e6c0233095}"
out="${2:-$index_root/pkgs/c/compat.opencv5.lua}"

src="$(sh "$here/fetch_upstream.sh")"
bld="${OPENCV_CFG_DIR:-$(mktemp -d /tmp/opencv5-cfg.XXXXXX)}"

# Frozen hermetic profile (v0.1 scope): five requested modules (flann and
# geometry join as dependency closure), every external probe OFF, all needed
# 3rdparty built from the vendored tree (zlib, libpng, libjpeg-turbo incl.
# NASM SIMD), headless highgui, V4L2 videoio. WITH_UNIFONT stays OFF: it is
# a configure-time EXTRA download (13 MB CJK font) which would break the
# single-pinned-source model — future `unifont` feature.
cmake -G Ninja -S "$src" -B "$bld" \
  -DCMAKE_BUILD_TYPE=Release \
  ${CC:+-DCMAKE_C_COMPILER=$CC} ${CXX:+-DCMAKE_CXX_COMPILER=$CXX} \
  -DBUILD_LIST=core,imgproc,imgcodecs,highgui,videoio \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_ZLIB=ON -DBUILD_PNG=ON -DBUILD_JPEG=ON \
  -DWITH_TIFF=OFF -DWITH_WEBP=OFF -DWITH_OPENJPEG=OFF -DWITH_JASPER=OFF \
  -DWITH_OPENEXR=OFF -DWITH_AVIF=OFF -DWITH_JPEGXL=OFF -DWITH_IMGCODEC_GIF=OFF \
  -DWITH_OPENCL=OFF -DWITH_IPP=OFF -DWITH_LAPACK=OFF -DWITH_EIGEN=OFF -DWITH_ITT=OFF \
  -DWITH_GTK=OFF -DWITH_QT=OFF -DWITH_WAYLAND=OFF -DWITH_OPENGL=OFF \
  -DWITH_FFMPEG=OFF -DWITH_GSTREAMER=OFF -DWITH_V4L=ON -DWITH_OBSENSOR=OFF \
  -DWITH_PROTOBUF=OFF -DWITH_CAROTENE=OFF -DWITH_FLATBUFFERS=OFF \
  -DWITH_UNIFONT=OFF \
  -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_EXAMPLES=OFF -DBUILD_opencv_apps=OFF

# Reference build: -k because two AVX2 bfloat TUs ICE on host gcc 13 — the
# object files are irrelevant, only generator outputs are harvested.
ninja -C "$bld" -k 9999 || true
ninja -C "$bld" -t commands > "$bld/ninja-cmds.log"

python3 "$here/gen_descriptor.py" "$src" "$bld" "$version" "$sha256" "$out"
echo "descriptor written: $out (configured on: $target)"
