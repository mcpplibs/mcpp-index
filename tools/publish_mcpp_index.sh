#!/usr/bin/env bash
# Build + publish the mcpp-index *artifact* + rolling pointer to a resource repo
# (default xlings-res/mcpp-index) on GitHub (gh) and GitCode (gtc). Standalone:
# packs pkgs/ into a content-hash-versioned tarball + manifest, uploads the
# artifact as a release asset (rolling 'latest' + archive 'v<ver>'), and pushes
# a combined pointer file (mcpp-index-pointers.json, key "mcpp") for parity with
# xlings-res/xim-index. No mcpp build needed.
#
# Usage:  tools/publish_mcpp_index.sh [src-dir]   (default: .)
# Env:    XLINGS_RES_TOKEN (github push), GITCODE_TOKEN (gitcode), GH_TOKEN (gh),
#         MCPP_INDEX_RES_REPO (default xlings-res/mcpp-index)
set -euo pipefail

SRC="${1:-.}"
REPO="${MCPP_INDEX_RES_REPO:-xlings-res/mcpp-index}"
[ -d "$SRC/pkgs" ] || { echo "[mcpp-index] FAIL: missing $SRC/pkgs" >&2; exit 1; }

VER="$(git -C "$SRC" rev-parse --short HEAD 2>/dev/null || date -u +%Y%m%d%H%M%S)"
SRCCOMMIT="$(git -C "$SRC" rev-parse HEAD 2>/dev/null || echo unknown)"
BASE="mcpp-index-${VER}"
OUT="$(mktemp -d)"; trap 'rm -rf "$OUT"' EXIT
info() { echo "[mcpp-index] $*"; }

# ── 1. pack the index tree (pkgs/ + README), deterministic, .git-free ──
TREE="$OUT/tree"; mkdir -p "$TREE"
cp -a "$SRC/pkgs" "$TREE/"
[ -f "$SRC/README.md" ] && cp "$SRC/README.md" "$TREE/" || true
# The zh translation ships alongside it — README.md links to it, so leaving it
# out would give the unpacked artifact a dangling language switch.
[ -f "$SRC/README.zh-CN.md" ] && cp "$SRC/README.zh-CN.md" "$TREE/" || true
# index.toml carries the index→client version contract (min_mcpp floor);
# it must travel with the tree so unpacked snapshots enforce it offline.
[ -f "$SRC/index.toml" ] && cp "$SRC/index.toml" "$TREE/" || true
# THE BYTES FOR AN INDEX COMMIT ARE DECIDED ONCE.
#
# The artifact name carries the index commit, and the nightly cron reruns this
# script on an unchanged HEAD. The pack was not byte-reproducible (entry times
# came from the checkout), so a rerun built different bytes under the same name:
# GitHub's `--clobber` replaced its asset, GitCode cannot replace one and kept
# the first, and both pointers moved to the second digest. Measured 2026-09-16
# on v7649883: GitHub 78535f36... (553573 bytes, entries dated 04:41), GitCode
# d89135a3... (553557 bytes, entries dated 03:00), identical trees. A CN client
# rejected GitCode's bytes and fell back to GitHub (mcpp-community/mcpp#648).
# xim-pkgindex settled the same defect on 2026-09-05
# (tools/build_xim_index_artifact.sh); this script is the copy it did not reach.
#
# Two measures, each sufficient for the case the other cannot cover:
#   1. an already published copy of this version IS the artifact. GitCode is
#      asked first, because it is the forge that cannot replace an asset, so a
#      republish converges on the bytes that are already immovable there;
#   2. a fresh pack is reproducible: sorted names, fixed owner, mode and entry
#      time (the source commit's), and a gzip header without a name or time.
# MCPP_INDEX_NO_REUSE=1 forces a fresh pack.
SRCTIME="$(git -C "$SRC" log -1 --format=%ct 2>/dev/null || echo 0)"
reused=""
if [ "${MCPP_INDEX_NO_REUSE:-0}" != 1 ]; then
  for base_url in "https://gitcode.com/${REPO}/releases/download" \
                  "https://github.com/${REPO}/releases/download"; do
    if curl -fsSL --retry 3 --retry-all-errors -o "$OUT/$BASE.tar.gz.reuse" \
         "${base_url}/v${VER}/${BASE}.tar.gz" 2>/dev/null \
       && gzip -t "$OUT/$BASE.tar.gz.reuse" 2>/dev/null \
       && tar -tzf "$OUT/$BASE.tar.gz.reuse" ./pkgs >/dev/null 2>&1; then
      mv -f "$OUT/$BASE.tar.gz.reuse" "$OUT/$BASE.tar.gz"
      reused="$base_url"
      break
    fi
    rm -f "$OUT/$BASE.tar.gz.reuse"
  done
fi
if [ -n "$reused" ]; then
  info "reusing the published artifact for $VER from $reused"
else
  tar --sort=name --owner=0 --group=0 --numeric-owner --mode='u+rwX,go+rX,go-w' \
      --mtime="@${SRCTIME}" --format=gnu -cf - -C "$TREE" . \
    | gzip -n -9 > "$OUT/$BASE.tar.gz"
fi
SHA="$(sha256sum "$OUT/$BASE.tar.gz" | awk '{print $1}')"
SIZE="$(wc -c < "$OUT/$BASE.tar.gz" | tr -d ' ')"
cat > "$OUT/manifest.json" <<JSON
{
  "format_version": 1,
  "index_version": "${VER}",
  "index_name": "mcpp",
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "source_commit": "${SRCCOMMIT}",
  "artifact": { "name": "${BASE}.tar.gz", "sha256": "${SHA}", "size": ${SIZE} },
  "signature": null
}
JSON
python3 -c "import json; m=json.load(open('$OUT/manifest.json')); json.dump({'format_version':1,'indexes':{'mcpp':m}}, open('$OUT/mcpp-index-pointers.json','w'), indent=2)"
info "built $BASE.tar.gz  sha ${SHA:0:12}  ($SIZE bytes)"

# ── 2. artifact -> release asset (rolling 'latest' + archive 'v<ver>') ──
publish_gh() {  # <tag>
  gh release view "$1" -R "$REPO" >/dev/null 2>&1 \
    || gh release create "$1" -R "$REPO" --title "$1" --notes "mcpp package index ($VER)"
  gh release upload "$1" "$OUT/$BASE.tar.gz" -R "$REPO" --clobber
}
publish_gtc() {  # <tag>
  gtc release create "$REPO" --tag "$1" --name "$1" 2>/dev/null || true
  # An asset GitCode already holds under this name cannot be replaced; when its
  # bytes are the artifact's (the reuse above makes that the case), a second
  # upload would only add a duplicate record.
  if curl -fsSL -o "$OUT/gtc.check" "https://gitcode.com/${REPO}/releases/download/$1/$BASE.tar.gz" 2>/dev/null \
     && [ "$(sha256sum "$OUT/gtc.check" | awk '{print $1}')" = "$SHA" ]; then
    info "GitCode $1: $BASE.tar.gz already holds these bytes"
    return 0
  fi
  local try
  for try in 1 2 3; do
    gtc release upload "$REPO" "$OUT/$BASE.tar.gz" --tag "$1" 2>&1 | tail -1 | grep -q uploaded && return 0
    info "gtc upload ($1) try $try failed, retrying..."; sleep 3
  done
}
if [ -n "${GH_TOKEN:-${XLINGS_RES_TOKEN:-}}" ]; then
  info "GitHub $REPO: latest + v$VER"; publish_gh latest; publish_gh "v$VER"
fi
if [ -n "${GITCODE_TOKEN:-}" ] && command -v gtc >/dev/null 2>&1; then
  info "GitCode $REPO: latest + v$VER"; publish_gtc latest; publish_gtc "v$VER"
fi

# ── 3. pointer repo file (overwriteable) on both ends; init if empty repo ──
push_pointer() {  # <auth-url> <label>
  local url="$1" label="$2" tmp; tmp="$(mktemp -d)"
  if ! git clone -q --depth 1 "$url" "$tmp" 2>/dev/null; then
    info "$label: clone failed (skip)"; rm -rf "$tmp"; return 0
  fi
  cp "$OUT/mcpp-index-pointers.json" "$tmp/mcpp-index-pointers.json"
  git -C "$tmp" add -A
  if git -C "$tmp" diff --cached --quiet 2>/dev/null && git -C "$tmp" rev-parse HEAD >/dev/null 2>&1; then
    info "$label: no change"; rm -rf "$tmp"; return 0
  fi
  git -C "$tmp" -c user.email=ci@mcpp.dev -c user.name=mcpp-ci commit -qm "chore: update mcpp index pointer ($VER)"
  if git -C "$tmp" push -q origin HEAD:main 2>/dev/null; then info "$label: pushed"; else info "$label: push failed (non-blocking)"; fi
  rm -rf "$tmp"
}
[ -n "${XLINGS_RES_TOKEN:-}" ] && push_pointer "https://x-access-token:${XLINGS_RES_TOKEN}@github.com/${REPO}.git" github
[ -n "${GITCODE_TOKEN:-}" ]    && push_pointer "https://oauth2:${GITCODE_TOKEN}@gitcode.com/${REPO}.git" gitcode

# ── 4. every forge serves the bytes the pointer names ──
# A pointer that names a digest one forge does not serve is the failure this
# script exists to prevent, and nothing downstream reports it except a client's
# fallback. Read each copy back and compare.
verify_copy() {  # <label> <url>
  # A replaced GitHub asset reaches its CDN after a delay, so a stale read is
  # retried; a copy that stays different after the last attempt is a failure.
  local attempt got=""
  for attempt in 1 2 3 4 5 6; do
    if curl -fsSL --retry 3 --retry-all-errors -o "$OUT/verify.tgz" "$2" 2>/dev/null; then
      got="$(sha256sum "$OUT/verify.tgz" | awk '{print $1}')"
      if [ "$got" = "$SHA" ]; then
        info "$1 serves $BASE.tar.gz with the pointer's digest"
        return 0
      fi
    fi
    sleep 10
  done
  echo "[mcpp-index] FAIL: $1 serves '${got:-nothing}' for $BASE.tar.gz, the pointer names $SHA" >&2
  return 1
}
verify_failed=0
if [ -n "${GH_TOKEN:-${XLINGS_RES_TOKEN:-}}" ]; then
  verify_copy github "https://github.com/${REPO}/releases/download/v${VER}/${BASE}.tar.gz" || verify_failed=1
fi
if [ -n "${GITCODE_TOKEN:-}" ] && command -v gtc >/dev/null 2>&1; then
  verify_copy gitcode "https://gitcode.com/${REPO}/releases/download/v${VER}/${BASE}.tar.gz" || verify_failed=1
fi
[ "$verify_failed" = 0 ] || exit 1

info "published mcpp-index $VER -> $REPO (pointer key 'mcpp')"
