#!/usr/bin/env bash
# Build the godot-cpp source archive this index points at.
#
# WHY a repack at all: godot-cpp's GDExtension bindings (~1000 classes,
# gen/include + gen/src) are not in any upstream tag archive -- they are
# produced by upstream's own binding_generator.py from
# gdextension/extension_api.json at build time, which would make every
# consumer of the package need a Python toolchain. So the generator runs
# ONCE, here, and the result is published alongside the untouched upstream
# tree. Same idea as the frozen configure snapshots in the opencv/ffmpeg
# packages: no code generation on the consumer side.
#
# The archive is exactly:
#   * the upstream tag tarball, byte-for-byte (verified below), plus
#   * gen/, produced by running upstream's unmodified binding_generator.py.
#
# WHICH engine: up to 10.0.0-rc1 a tag carried exactly one API
# (gdextension/extension_api.json). 10.0.0-stable is multi-API -- one tag ships
# extension_api-<major>-<minor>.json for every engine minor it supports
# (4.3..4.7) and the build picks one (scons `api_version=`, cmake
# `GODOTCPP_DEFAULT_API_VERSION`). So one godot-cpp release no longer means one
# engine, and the package version alone no longer says which bindings are
# inside: resolve the file the way the tag itself declares, and pass the engine
# explicitly when a package has to bake something other than the tag default.
#
# Reproduce:
#   tools/godot-cpp/repack.sh godot-4.5-stable 4.5.0 /tmp/out
#   tools/godot-cpp/repack.sh 10.0.0-stable 10.0.0-stable /tmp/out        # 4.7 (tag default)
#   tools/godot-cpp/repack.sh 10.0.0-stable 10.0.0-stable-4.6 /tmp/out 4.6
# then publish /tmp/out/godot-cpp-<version>.tar.gz to
# github.com/xlings-res/godot-cpp (GLOBAL) and gitcode.com/mcpp-res/godot-cpp
# (CN), both under the bare-version tag.
set -euo pipefail

TAG="${1:?usage: repack.sh <upstream-tag> <bare-version> <outdir> [engine-api]}"
VERSION="${2:?}"
OUTDIR="${3:?}"
ENGINE_API="${4:-${ENGINE_API:-}}"   # e.g. 4.7; ignored by single-API tags

# umask 002 is load-bearing for reproducibility, not a preference. gen/ is
# created here, at repack time, so its mode bits come from THIS process's umask
# (0o777&~umask for dirs, 0o666&~umask for files) and ride into the archive:
# 002 -> 775/664, 022 -> 755/644. Same content, different sha256 -- the two
# already-published archives (4.5.0 = b0c36e77..., 10.0.0-rc1 = aaafbf50...)
# are the 002 spelling, and an earlier revision of this script only reproduced
# under an English locale and a 002 umask. Pin it here rather than document it.
umask 002

PYTHON="${PYTHON:-python3}"
WRAP="godot-cpp-${TAG}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$OUTDIR"

echo "==> fetching upstream ${TAG}"
curl -L -fsS -o "$WORK/upstream.tar.gz" \
    "https://github.com/godotengine/godot-cpp/archive/refs/tags/${TAG}.tar.gz"
echo "    upstream sha256: $(sha256sum "$WORK/upstream.tar.gz" | cut -d' ' -f1)"

# -p (--preserve-permissions) is load-bearing: GitHub's tag tarballs carry
# 775/664 (group-writable), and extracting as a non-root user WITHOUT -p makes
# tar apply the extractor's umask (022 -> 755/644). The modes then ride into the
# packed archive, so two hosts with different umasks produce different sha256s
# for identical content -- the published 4.5.0 archive is 0000775 and does not
# reproduce under umask 022 without -p. Take the modes from upstream's archive,
# not from whoever happens to be packing.
tar -xzpf "$WORK/upstream.tar.gz" -C "$WORK"
test -d "$WORK/$WRAP" || { echo "unexpected wrap dir in archive" >&2; exit 1; }

echo "==> generating bindings with upstream binding_generator.py"
(
    cd "$WORK/$WRAP"
    # Which extension_api.json (see the header): explicit ENGINE_API wins, else
    # the tag's own declared default (CMakeLists.txt GODOTCPP_DEFAULT_API_VERSION,
    # which is what scons' Makefile/test/SConstruct agree with), else the highest
    # version present. Single-API tags short-circuit on the file existing, so
    # 4.5.0 / 10.0.0-rc1 keep resolving to the same path they always did.
    API_FILE="$(ENGINE_API="$ENGINE_API" "$PYTHON" -c "
import glob, os, re
if os.path.exists('gdextension/extension_api.json'):
    print('gdextension/extension_api.json')
    raise SystemExit
files = sorted(glob.glob('gdextension/extension_api-*.json'),
               key=lambda p: tuple(int(n) for n in re.search(r'-(\d+)-(\d+)\.json$', p).groups()))
if not files:
    raise SystemExit('no extension_api json in the tag')
want = os.environ.get('ENGINE_API', '').strip()
if want:
    target = 'gdextension/extension_api-%s.json' % want.replace('.', '-')
    if target not in files:
        raise SystemExit('this tag has no api file for %s' % want)
    print(target)
    raise SystemExit
try:
    declared = re.search(r'GODOTCPP_DEFAULT_API_VERSION\s+\"([0-9]+\.[0-9]+)\"',
                         open('CMakeLists.txt', encoding='utf-8').read())
except OSError:
    declared = None
if declared:
    target = 'gdextension/extension_api-%s.json' % declared.group(1).replace('.', '-')
    if target in files:
        print(target)
        raise SystemExit
print(files[-1])
")"
    echo "    api json: ${API_FILE}"

    # generate_bindings() grew an `interface_filepath` parameter between
    # godot-4.5-stable and 10.0.0-rc1, where gdextension_interface.h stopped
    # being checked in and became generated from gdextension_interface.json.
    # Dispatch on the actual signature and on which file the tag ships, rather
    # than on the tag itself, so this keeps working across the change in both
    # directions (cmake's GODOTCPP_GDEXTENSION_INTERFACE_FILE does the same).
    API_FILE="$API_FILE" "$PYTHON" -c "
import inspect
import os
import binding_generator

api_file = os.environ['API_FILE']
params = inspect.signature(binding_generator.generate_bindings).parameters
if 'interface_filepath' in params:
    interface = 'gdextension/gdextension_interface.json'
    if not os.path.exists(interface):
        interface = 'gdextension/gdextension_interface.h'
    binding_generator.generate_bindings(
        api_file, interface,
        True, '64', 'single', '.')
else:
    binding_generator.generate_bindings(
        api_file, True, '64', 'single', '.')
"
    # generate_bindings() imports the module, which leaves bytecode behind
    find . -name '__pycache__' -type d -prune -exec rm -rf {} +
)

echo "==> verifying the upstream tree is untouched"
tar -xzpf "$WORK/upstream.tar.gz" -C "$WORK" --transform "s|^${WRAP}|${WRAP}.orig|"
# LC_ALL=C is load-bearing: the filter below matches diff's "Only in <dir>: gen"
# line, and that line is localized -- on a zh_CN host it reads
# "只在 <dir> 中存在：gen", matches nothing, and every archive is refused as
# "upstream files were modified". Force the message language rather than try to
# match a translation.
LC_ALL=C diff -r --no-dereference "$WORK/${WRAP}.orig" "$WORK/${WRAP}" > "$WORK/diff.txt" || true
if grep -v "^Only in $WORK/${WRAP}: gen\$" "$WORK/diff.txt" | grep -q .; then
    echo "upstream files were modified -- refusing:" >&2
    grep -v "^Only in $WORK/${WRAP}: gen\$" "$WORK/diff.txt" >&2
    exit 1
fi
echo "    every upstream file is byte-identical; gen/ is the only addition"
rm -rf "$WORK/${WRAP}.orig"

echo "==> packing (deterministic: sorted, fixed mtime, gzip -n)"
tar --sort=name --mtime='UTC 2026-01-01' --owner=0 --group=0 --numeric-owner \
    -C "$WORK" -cf - "$WRAP" | gzip -n -9 > "$OUTDIR/godot-cpp-${VERSION}.tar.gz"

sha256sum "$OUTDIR/godot-cpp-${VERSION}.tar.gz"
