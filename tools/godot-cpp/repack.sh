#!/usr/bin/env bash
# Build the godot-cpp source archive this index points at.
#
# WHY a repack at all: godot-cpp's GDExtension bindings (~1000 classes,
# gen/include + gen/src) are not in any upstream tag archive -- they are
# produced by upstream's own binding_generator.py from the extension_api
# json under gdextension/ at build time, which would make every consumer of
# the package need a Python toolchain. So the generator runs ONCE, here, and
# the result is published alongside the untouched upstream tree. Same idea as
# the frozen configure snapshots in the opencv/ffmpeg packages: no code
# generation on the consumer side.
#
# The archive is exactly:
#   * the upstream tag tarball, byte-for-byte (verified below), plus
#   * gen/, produced by running upstream's unmodified binding_generator.py.
#
# Reproduce:
#   tools/godot-cpp/repack.sh godot-4.5-stable 4.5.0 /tmp/out
# then publish /tmp/out/godot-cpp-<version>.tar.gz to
# github.com/xlings-res/godot-cpp (GLOBAL) and gitcode.com/mcpp-res/godot-cpp
# (CN), both under the bare-version tag.
#
# LC_ALL=C: the byte-for-byte verification greps diff(1) output for the
# English marker "Only in ...: gen"; under a non-C locale diff speaks the
# local language and the filter silently matches nothing (measured on a
# zh_CN host: the repack refused a correct tree).
export LC_ALL=C
set -euo pipefail

TAG="${1:?usage: repack.sh <upstream-tag> <bare-version> <outdir>}"
VERSION="${2:?}"
OUTDIR="${3:?}"

PYTHON="${PYTHON:-python3}"
WRAP="godot-cpp-${TAG}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$OUTDIR"

echo "==> fetching upstream ${TAG}"
curl -L -fsS -o "$WORK/upstream.tar.gz" \
    "https://github.com/godotengine/godot-cpp/archive/refs/tags/${TAG}.tar.gz"
echo "    upstream sha256: $(sha256sum "$WORK/upstream.tar.gz" | cut -d' ' -f1)"

tar -xzf "$WORK/upstream.tar.gz" -C "$WORK"
test -d "$WORK/$WRAP" || { echo "unexpected wrap dir in archive" >&2; exit 1; }

echo "==> generating bindings with upstream binding_generator.py"
(
    cd "$WORK/$WRAP"
    # generate_bindings() grew an `interface_filepath` parameter between
    # godot-4.5-stable and 10.0.0-rc1, where gdextension_interface.h stopped
    # being checked in and became generated from gdextension_interface.json.
    # Dispatch on the actual signature and on which file the tag ships, rather
    # than on the tag itself, so this keeps working across the change in both
    # directions (cmake's GODOTCPP_GDEXTENSION_INTERFACE_FILE does the same).
    "$PYTHON" -c "
import inspect
import os
import binding_generator

# The API JSON moved between 10.0.0-rc1 and 10.0.0-stable: the single
# extension_api.json became per-version extension_api-<major>-<minor>.json
# files (4.3 through 4.7 at stable), selected by the api_version build
# option. cmake defaults that option to 4.7 (CMakeLists.txt sets
# GODOTCPP_DEFAULT_API_VERSION "4.7"), so the repack takes the newest
# shipped file -- same default answer scons users get by passing
# api_version explicitly. Tags still shipping the single json keep it.
api = 'gdextension/extension_api.json'
if not os.path.exists(api):
    apis = sorted('gdextension/' + f for f in os.listdir('gdextension')
                  if f.startswith('extension_api-') and f.endswith('.json'))
    assert apis, 'no extension_api json in gdextension/'
    api = apis[-1]

params = inspect.signature(binding_generator.generate_bindings).parameters
if 'interface_filepath' in params:
    interface = 'gdextension/gdextension_interface.json'
    if not os.path.exists(interface):
        interface = 'gdextension/gdextension_interface.h'
    binding_generator.generate_bindings(
        api, interface,
        True, '64', 'single', '.')
else:
    binding_generator.generate_bindings(
        api, True, '64', 'single', '.')
"
    # generate_bindings() imports the module, which leaves bytecode behind
    find . -name '__pycache__' -type d -prune -exec rm -rf {} +
)

echo "==> verifying the upstream tree is untouched"
tar -xzf "$WORK/upstream.tar.gz" -C "$WORK" --transform "s|^${WRAP}|${WRAP}.orig|"
diff -r --no-dereference "$WORK/${WRAP}.orig" "$WORK/${WRAP}" > "$WORK/diff.txt" || true
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
