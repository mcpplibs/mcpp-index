#!/bin/sh
# fetch_upstream.sh — download + extract the pinned official FFmpeg tarball
# for maintainer-time regeneration (gen_config/gen_exports/gen_descriptor).
# Consumers never need this: they get FFmpeg via the compat.ffmpeg package.
#
# Prints the extracted source root on stdout.
set -eu

version="${FFMPEG_VERSION:-8.1.2}"
sha256="${FFMPEG_SHA256:-32faba5ef67340d54724941eae1425580791195312a4fd13bf6f820a2818bf22}"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/ffmpeg-m"
tarball="$cache/ffmpeg-$version.tar.gz"
srcdir="$cache/ffmpeg-$version"

mkdir -p "$cache"
if [ ! -f "$tarball" ]; then
    curl -L -fsS -o "$tarball" "https://ffmpeg.org/releases/ffmpeg-$version.tar.gz" >&2
fi
echo "$sha256  $tarball" | sha256sum -c - >&2
if [ ! -d "$srcdir" ]; then
    tar -xzf "$tarball" -C "$cache"
fi
echo "$srcdir"
