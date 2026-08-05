#!/usr/bin/env bash
# run_members.sh — run workspace members one by one, timing each.
#
# The same script CI runs and you run locally, on purpose: a timing table that
# only exists in CI cannot be used while deciding what to optimise, and a local
# harness that differs from CI measures something else.
#
#   bash tests/run_members.sh --all
#   bash tests/run_members.sh opencv-module protobuf
#   bash tests/run_members.sh --all --shard 3/8
#   bash tests/run_members.sh --all --cache local     # bypass the package cache
#
# Env:
#   MCPP              path to the mcpp binary (default: `mcpp` on PATH)
#   MCPP_TIMINGS      where to append `<seconds>\t<member>\t<ok|FAIL>` rows
#
# Exit status is non-zero if any member failed. The timing table is printed
# regardless — a slow run is worth measuring even when it breaks.
set -u

MCPP="${MCPP:-mcpp}"
timings="${MCPP_TIMINGS:-}"
cache=""
shard=""
members=()
all=0

while [ $# -gt 0 ]; do
    case "$1" in
        --all)      all=1; shift ;;
        --shard)    shard="$2"; shift 2 ;;
        --cache)    cache="$2"; shift 2 ;;
        --timings)  timings="$2"; shift 2 ;;
        -h|--help)  sed -n '2,20p' "$0"; exit 0 ;;
        -*)         echo "unknown option: $1" >&2; exit 2 ;;
        *)          members+=("$1"); shift ;;
    esac
done

# `--all` reads the workspace manifest rather than the directory, so a member
# that exists on disk but is not registered is not silently tested.
#
# Both filters below are load-bearing. mcpp.toml's PROSE mentions the path too
# — line 3 says "tests/examples/ — each consumes this repo's own packages",
# which this grep matches with an empty tail, and `mcpp test -p ""` is not a
# useful thing to run. Requiring a real directory also means a name that only
# appears in a comment (`tests/examples/asio-ssl` is discussed in one) cannot
# turn into a phantom member.
if [ "$all" = 1 ]; then
    while IFS= read -r m; do
        [ -n "$m" ] || continue
        [ -d "tests/examples/$m" ] || continue
        members+=("$m")
    done < <(grep -o 'tests/examples/[A-Za-z0-9._-]*' mcpp.toml \
             | sed 's|tests/examples/||' | sort -u)
fi

if [ "${#members[@]}" -eq 0 ]; then
    echo "no members selected — pass names or --all" >&2
    exit 2
fi

# --shard N/M keeps every M-th member starting at N. Round-robin by position,
# which is what separates adjacent expensive members (opencv-module,
# -dnn, -unifont) onto different runners.
if [ -n "$shard" ]; then
    idx=${shard%%/*}
    cnt=${shard##*/}
    picked=()
    i=0
    for m in "${members[@]}"; do
        [ $((i % cnt)) -eq "$idx" ] && picked+=("$m")
        i=$((i + 1))
    done
    members=("${picked[@]+"${picked[@]}"}")
    echo "shard $idx/$cnt -> ${#members[@]} member(s)"
fi

[ -n "$cache" ] && export MCPP_BUILD_CACHE="$cache"
echo "cache mode: ${MCPP_BUILD_CACHE:-global (default)}"

rows=$(mktemp)
trap 'rm -f "$rows"' EXIT
rc=0

for m in "${members[@]}"; do
    echo "::group::mcpp test -p $m"
    t0=$(date +%s)
    if "$MCPP" test -p "$m"; then status=ok; else status=FAIL; rc=1; fi
    t1=$(date +%s)
    echo "::endgroup::"
    printf '%s\t%s\t%s\n' "$((t1 - t0))" "$m" "$status" >> "$rows"
    printf '  %-34s %5ss  %s\n' "$m" "$((t1 - t0))" "$status"
done

[ -n "$timings" ] && cat "$rows" >> "$timings"

echo
echo "── slowest members ──────────────────────────────────────────"
total=$(awk -F'\t' '{s += $1} END {print s+0}' "$rows")
sort -rn "$rows" | head -15 | awk -F'\t' -v tot="$total" '
    { pct = tot > 0 ? ($1 * 100 / tot) : 0
      printf "  %6ss  %5.1f%%  %-34s %s\n", $1, pct, $2, $3 }'
echo "  ────────"
printf '  %6ss  total across %s member(s)\n' "$total" "${#members[@]}"

exit "$rc"
