#!/bin/sh
# fetch_upstream.sh — download + extract the pinned official OpenCV tarball
# for maintainer-time regeneration of the compat.opencv5 descriptor.
# Consumers never need this: they get OpenCV via the compat.opencv5 package.
#
# Prints the extracted source root on stdout.
set -eu

version="${OPENCV_VERSION:-5.0.0}"
sha256="${OPENCV_SHA256:-b0528f5a1d379d59d4701cb28c36e22214cc51cf64594e5b56f2d3e6c0233095}"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/opencv-m"
tarball="$cache/opencv-$version.tar.gz"
srcdir="$cache/opencv-$version"

mkdir -p "$cache"
if [ ! -f "$tarball" ]; then
    curl -L -fsS -o "$tarball" "https://github.com/opencv/opencv/archive/refs/tags/$version.tar.gz" >&2
fi
echo "$sha256  $tarball" | sha256sum -c - >&2
if [ ! -d "$srcdir" ]; then
    tar -xzf "$tarball" -C "$cache"
fi
echo "$srcdir"
