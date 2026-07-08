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
# index.toml carries the index→client version contract (min_mcpp floor);
# it must travel with the tree so unpacked snapshots enforce it offline.
[ -f "$SRC/index.toml" ] && cp "$SRC/index.toml" "$TREE/" || true
tar --sort=name --owner=0 --group=0 --numeric-owner -czf "$OUT/$BASE.tar.gz" -C "$TREE" . 2>/dev/null \
  || tar -czf "$OUT/$BASE.tar.gz" -C "$TREE" .
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

info "published mcpp-index $VER -> $REPO (pointer key 'mcpp')"
