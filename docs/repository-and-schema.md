# Repository layout, schema, CI and key files

**English** | [简体中文](zh/repository-and-schema.md)

## Repository layout

```
pkgs/<x>/<name>.lua          descriptors. <x> is the initial of the full package name (compat.* → c, nlohmann.json → n, imgui → i)
mcpp.toml                    workspace manifest (the members list) + the root-level [indices] compat = { path = "." },
                             inherited by members (relative paths resolve against the workspace root, mcpp >= 0.0.97)
tests/examples/<member>/     one test project per library (a workspace member; <member> is the package name minus its
  mcpp.toml                  prefix, or <name>-module for module packages). Members consuming compat write no
                             [indices]; members consuming another namespace write exactly one (module packages use
                             default), and that declaration **replaces** the root-level table rather than merging with
                             it — at most one project-level index repo per member is a hard constraint, see
                             "Index redirection" below. Dependencies gate themselves per platform
                             ([target.'cfg(...)'])
  tests/*.cpp                behavioral assertions (standalone main; a non-zero exit code is a failure)
tests/check_mirror_urls.lua  lint: GLOBAL+CN table completeness, and that CN points at mcpp-res
tests/check_package_name.lua lint: identity shape (name is a single atomic segment, hierarchy belongs to namespace)
tests/list_cn_urls.lua       extracts the CN urls for mirror-cn-reachable
tests/run_members.sh         runs workspace members one at a time and times each. The entry point used both by CI
                             and locally; see "Running workspace members locally" below
tests/plan_shards.lua        assigns members to shards from measured times. Called once by the `select` job, and by
                             run_members.sh --shard, so both produce the same split
tests/member-timings.tsv     the measured per-member wall-clock plan_shards.lua reads. Refreshed deliberately from
                             the member-timings artifact rather than written back on every run
README.md                    index overview and contribution entry point (README.zh-CN.md is the Chinese version)
.github/workflows/validate.yml   CI: lint / mirror-cn-reachable / select / workspace (sharded per platform on a full
                             run) / timings
.agents/docs/<date>-*.md     the design-document convention
docs/                        contributor reference documentation (this directory; docs/zh/ holds the Chinese version)
tools/gtc                    the gitcode CLI, see cn-mirror.md
tools/compat-ffmpeg/ etc.    descriptor regeneration pipelines for the large compat packages
.xpkgindex.json              site configuration (title, links, install template); rarely needs changing
```

## External repositories and documentation

- mcpp itself: https://github.com/mcpp-community/mcpp (a local clone usually exists at
  `/home/speak/workspace/github/mcpp-community/mcpp`). `mcpp --version` should match CI; `src/manifest.cppm`,
  `src/modgraph/scanner.cppm` and `src/build/prepare.cppm` are authoritative for feature and glob behavior.
- The xpkg extension schema (authoritative):
  https://github.com/mcpp-community/mcpp/tree/main/docs/spec (the "mcpp ext" link in this
  repository's `.xpkgindex.json`). For the V1 xpkg spec see `docs/V1/xpackage-spec.md` in `d2learn/xim-pkgindex`
  (url-template is around line 172).
- The CN mirror organization: gitcode `mcpp-res`.

## Descriptor schema cheat-sheet (Form B inline)

Required `package` fields: `spec`, `namespace`, `name`, `description`, `licenses`, `repo`, `type="package"`, `xpm`,
`mcpp`.

### Package identity: `(namespace, name)`

Identity is a pair — **`namespace` is a dotted hierarchical path, `name` is a single atomic segment**. Hierarchy always
goes in `namespace` (mcpp SPEC-001 §3.2, see
[`docs/spec/package-identity.md`](https://github.com/mcpp-community/mcpp/blob/main/docs/spec/package-identity.md) in
the mcpp repository):

```lua
namespace = "compat",        name = "zlib"      -- ✅
namespace = "mcpplibs.capi", name = "lua"       -- ✅ multi-level namespace
namespace = "mcpplibs",      name = "capi.lua"  -- ❌ the short name still carries a dot
```

The last one is rejected rather than reinterpreted: the extra dot inside `name` describes a namespace **nobody ever
declared**. mcpp used to split on the last dot and silently invent `(mcpplibs.capi, lua)`; since 0.0.106 it rejects.

**The compatibility shape**: descriptors published before SPEC-001 repeat the namespace inside `name`
(`namespace="compat", name="compat.zlib"`) and are still accepted — the prefix is stripped before the check, the wire
key is the literal `name`, and both spellings install. This repository has been migrated wholesale to the short form.

**The same short name can coexist across namespaces**: there are three such pairs here today — `compat:imgui` and the
default namespace's `imgui`, `compat:ffmpeg` and `ffmpeg`, `compat:lua` and `mcpplibs.capi:lua`. This needs
xlings >= 0.4.69 ([xlings#381](https://github.com/openxlings/xlings/issues/381)); `(namespace, name)` has to be
unique, `name` alone does not.

**File names play no part in resolution** and can be anything. `<name>.lua` or `<namespace>.<name>.lua` is recommended
(it hits mcpp's fast path), but descriptors are discovered by the **identity they declare**, so another name still
resolves.

`xpm.<linux|macosx|windows>.<bare version>`:

- `url`: a string, or a `{ GLOBAL=…, CN=… }` table (this repository uses the table form throughout).
- `sha256`: required, and equal to the digest of the actual downloaded bytes.

`mcpp` (common keys):

| Key | Description |
|---|---|
| `language` | usually `"c++23"` |
| `import_std` | mostly `false` |
| `c_standard` | for C sources: `"c99"` or `"c11"` |
| `modules` | for module libraries: `{ "x.y" }` |
| `include_dirs` | glob list; the header directories exposed to consumers |
| `generated_files` | `{ ["relative/path"]="content string" }`; mcpp >= 0.0.85 supports Lua long-bracket `[==[…]==]` multi-line strings (recommended — readable and reviewable), and escaped single-line strings still work |
| `scan_overrides` | `{ ["glob"]={ provides={…}, imports={…} } }`; declarative scan results — a matching file skips the M1 text scan (for upstream module units with conditional import guards, such as fmt's src/fmt.cc). Reconciled automatically against the compiler's P1689 output at build time, so a wrong declaration fails loudly (mcpp >= 0.0.85) |
| `sources` | glob list; the sources compiled into the lib |
| `cflags` / `cxxflags` / `ldflags` | appended to the corresponding rule |
| `targets` | `{ ["name"]={ kind="lib"/"bin", main=…, soname=… } }` |
| `features` | `{ ["f"]={ sources={…}, defines={…}, deps={…}, implies={…}, requires={…} } }`; `defines` applies only to the **package's own** TUs, so a consumer that wants to branch on a feature must declare it itself (see the `[target.'cfg(…)'.build] cxxflags` in `tests/examples/openssl` and `openblas`) |
| `deps` | `{ ["ns.name"]="ver" }`, flat or dotted; the same shape inside a feature |

## Index redirection (`[indices]`)

What the test surface has to validate is **the descriptors in the checkout**, not the published remote index, and
`[indices]` is what redirects a namespace into this repository to make that happen.

**Root-level inheritance**: the workspace root's `mcpp.toml` declares `[indices] compat = { path = "." }`, whose
relative path resolves against the **workspace root** (mcpp >= 0.0.97,
[mcpp#224](https://github.com/mcpp-community/mcpp/issues/224)), and members inherit it directly instead of each
writing their own `path = "../../.."`.

**Why there is only one, and why it is `compat`**:

- The index table is **keyed by namespace**. Declared under a name no dependency ever requests, the index is simply
  never registered, and resolution silently falls back to the published remote index — at which point what is under
  test is not this checkout at all.
- Declaring the same path under several namespaces does register all of them, but they become N independent project
  repos, and any lookup afterwards fails with an N-way ambiguity (physically the same descriptor;
  [mcpp#238](https://github.com/mcpp-community/mcpp/issues/238) /
  [xlings#374](https://github.com/openxlings/xlings/issues/374) — a silent exit 1 before xlings 0.4.69, a loud error
  since).

So the root level can carry exactly one namespace, and `compat` is the one that buys the most (13 members against 10
for everything else combined).

**Member-level override**: a member consuming another namespace declares its own `[indices]`, and that table
**replaces** the inherited root-level one rather than merging with it — which is precisely the mechanism that keeps
one project index repo per member.

**The cross-namespace trade-off**: a single member cannot resolve two namespaces from this checkout. `tests/examples/asio-ssl`
exploits that deliberately: it writes no member-level declaration and inherits the root `compat`, so asio itself comes
from the published remote index while its `ssl` feature dependency `compat.openssl` resolves from this checkout —
which means **an unmerged compat descriptor can be validated through an already-published consumer**. The local asio
descriptor is covered the other way round, by `tests/examples/asio-module`.

**Bare-name dependencies are out of scope**: the redirect is keyed by the **requesting** side's namespace, and a bare
`eigen = "5.0.1"` is a request issued in the default namespace — so it resolves from the remote index even though it
eventually lands on a `compat` descriptor. Members therefore always use the qualified spelling; bare-name resolution
itself is covered by upstream mcpp's e2e 165.

## The index version contract (index.toml)

`index.toml` at the repository root declares `[index] min_mcpp` — the oldest mcpp version able to resolve every
descriptor in this index. The contract travels with the tree: `publish_mcpp_index.sh` packs it into the artifact, and
a git clone or an `[indices] path =` local index carries it naturally. mcpp >= 0.0.85 checks it when opening an index
tree and reports `E0006` plus upgrade guidance on a violation (with `MCPP_INDEX_FLOOR=ignore` as a debugging escape
hatch).

The rule (mechanically enforced by lint, not by discipline): **floor first, new grammar after** — lint runs
`xpkg parse` with the mcpp version CI pins (strict: an unknown key fails), so a descriptor that needs newer
grammar/keys physically cannot land on main before `MCPP_VERSION` and `min_mcpp` are raised in lock-step. Reproduce
locally with `mcpp xpkg parse pkgs/<x>/<name>.lua`.

## CI behavior (validate.yml)

- Triggers: a PR (touching `pkgs/**/*.lua`, `tests/**`, either README, `mcpp.toml`, `index.toml` or this workflow),
  a push to main, the nightly cron, and manual dispatch. Dispatch takes a `cache` input — `global`, the default, or
  `local`. Under `local` every member rebuilds every dependency from scratch, which isolates a member's own cost from
  what it inherited from the members that ran before it; that is the condition per-member times should be compared
  under, and it is also far slower.
- `env.MCPP_VERSION` is the mcpp version every job uses; local verification should match it.
- `lint` (always runs): lua syntax via `loadfile(f,'t')`; `spec=`/`name=`/`xpm=` must be present; leading-v versions
  are rejected; runs `check_mirror_urls.lua`; runs `check_package_name.lua` (identity shape, see "Package identity"
  above); then runs `mcpp xpkg parse` over every descriptor with the mcpp version CI pins (strict — an unknown key
  fails). `xpkg parse` in mcpp >= 0.0.106 enforces the identity shape itself, which makes the lua lint an earlier and
  cheaper redundant gate.
- `mirror-cn-reachable` (always runs): `curl`s each CN url; all must return 200.
- `select`: decides the entire plan once and emits it to the runners as data. Three questions are answered here
  rather than on each runner — which members run, how many shards each platform gets, and which members land on
  which shard.
  - Selective member testing: on a PR, `git diff` maps changed files to the affected members
    (`pkgs/<x>/<lib>.lua` → members whose mcpp.toml references `<lib>`; `tests/examples/<m>/**` → member `<m>`).
    A change that can affect everything selects the full workspace instead: a non-PR event, this workflow file, a
    non-member edit to the workspace manifest, or a shared test script. Documentation-only and `tools/`-only changes
    select nothing.
  - Sharding applies to full runs only — a selective run is one job per platform. The shard count per platform is
    that platform's **measured runner concurrency** (linux 3, macos 1, windows 2) rather than a round number.
    Wall-clock is `ceil(shards / concurrency) × slowest-shard`, so shards beyond the concurrency remove no work and
    each still pays its own checkout, mcpp download and cache restore. At concurrency 1, splitting macOS is strictly
    slower than not splitting it. Re-measure with:
    `gh api repos/<owner>/<repo>/actions/runs/<id>/jobs --paginate --jq '[.jobs[]|select(.status=="in_progress")]|length'`
  - The assignment itself comes from `tests/plan_shards.lua`. It reads `tests/member-timings.tsv` and packs
    longest-first onto the least-loaded shard; ties break toward the shard already holding members with overlapping
    dependencies, because shards share no build cache and a dependency landing on two shards is built twice. A
    member with no recorded time is charged the median, so a newly added member is assumed neither free nor huge.
    Against round-robin on the real workspace the slowest linux shard falls from 4158s to 3706s and the spread from
    47% to 15%. One floor no split can beat remains: the single slowest member, `grpc-module` at 1701s.
  - Planning runs here, on linux, because it needs lua: windows has no apt or brew, and Homebrew installs `lua`
    rather than `lua5.4`.
- `workspace (<platform> <shard>/<count>)`: the whole test surface is one mcpp workspace and the **only build/run
  channel** — there is no shell-driven exception (the public module packages imgui/ffmpeg/opencv/tinyhttps are
  ordinary members too, resolving from the checkout through a member-level `[indices] default = { path = "../../.." }`,
  mcpp >= 0.0.97; members consuming `compat` inherit the root-level declaration, see "Index redirection" above). The
  shard suffix appears only where the platform is actually split.
  - Members run through `tests/run_members.sh`, the same script used locally. A timing table that exists only in CI
    cannot be consulted while deciding what to optimise, and a local harness that differs from CI measures something
    else.
  - The package build cache is global, which is mcpp's default. The step formerly set `MCPP_BUILD_CACHE: local` to
    work around mcpp#344, in which one cache entry could hold two object layouts; mcpp 2026.8.3.4 keyed the cache per
    package with the consumer-dependent layout included, so the reason no longer holds. Keeping the bypass was
    expensive: under `local`, 59 members that largely share abseil, protobuf and opencv rebuilt each of them from
    scratch, and a full linux run reached 2h30m — past the timeout, so it produced no result at all.
  - The `~/.mcpp/registry` cache carries the toolchains and the already-built compat packages, so a repeat run is
    incremental and fast. Its key is computed once, in a step of its own, from `git ls-files -s` over the tracked
    inputs — never with `hashFiles()`, which globs the working tree and would re-hash the multi-GB build output under
    `tests/examples/*/target` when actions/cache re-evaluates the key in its post (save) step (that blew past the
    runner's 120s template-evaluation cap on windows).
  - The published index is refreshed before testing. Most members resolve everything from the checkout, but a member
    redirecting a namespace other than `compat` takes the rest from the published index, whose snapshot is whatever
    the pinned mcpp release vendored — older than main by construction, and never moved by anything else in the run.
- `timings`: merges the per-shard timing artifacts into one ranking per platform in the run summary, and publishes
  the combined table as the `member-timings` artifact. Sharding otherwise hides where the time goes, since each
  runner reports only its own slice. The table is not committed automatically: a number that rewrites itself on
  every run makes every diff noisy and silently absorbs a one-off slow runner. Refresh `tests/member-timings.tsv`
  from that artifact when the numbers have actually moved.

## Reproducing lint locally (equivalent to the CI lint job)

```bash
fail=0
for f in pkgs/*/*.lua; do
  lua5.4 -e "assert(loadfile('$f','t'))" >/dev/null 2>&1 || { echo "SYNTAX $f"; fail=1; }
  for n in 'spec *=' 'name *=' 'xpm *='; do grep -q "$n" "$f" || { echo "MISS $n $f"; fail=1; }; done
  grep -nqE '\["v[0-9]+|\["[^"]+"\][[:space:]]*=[[:space:]]*"v[0-9]+' "$f" && { echo "LEADING-V $f"; fail=1; }
  lua5.4 tests/check_mirror_urls.lua "$f" >/dev/null 2>&1 || { echo "MIRROR $f"; fail=1; }
  lua5.4 tests/check_package_name.lua "$f" || fail=1
done
[ $fail -eq 0 ] && echo "ALL LINT PASS"
```

## Running workspace members locally

`tests/run_members.sh` is the entry point CI uses, so a local run measures the same thing under the same split:

```bash
bash tests/run_members.sh --all                             # every member
bash tests/run_members.sh opencv-module protobuf            # named members
bash tests/run_members.sh --all --shard 1/3                 # exactly what CI's linux shard 1 runs
bash tests/run_members.sh --all --shard 0/2 --platform windows
bash tests/run_members.sh --all --cache local               # bypass the package build cache
```

Shard indices are 0-based, and `--shard` delegates to `tests/plan_shards.lua` — the script the `select` job calls —
so shard N locally holds the members shard N holds in CI. Without lua on `PATH` it falls back to round-robin and
says so. `--platform` chooses which column of `tests/member-timings.tsv` to read and defaults to the host.

`MCPP` selects the binary (default: `mcpp` on `PATH`); `MCPP_TIMINGS` names a file to append
`<seconds>\t<member>\t<ok|FAIL>` rows to. The exit status is non-zero if any member failed, and the timing table
prints either way — a run worth diagnosing is exactly the one where the times matter.

## After the merge

`publish-artifact.yml` republishes the mcpp-index artifact and moves the pointer automatically once the change lands
on `main` — no new mcpp release required. Browse online at: https://mcpplibs.github.io/mcpp-index/

## Case index

| Shape | Descriptor | example | Design doc / PR |
|---|---|---|---|
| C source + feature | `pkgs/c/compat.cjson.lua`, `compat.gtest.lua` | `tests/examples/cjson/` | `.agents/docs/2026-06-27-add-cjson-and-nlohmann-json-plan.md` / #48 |
| C++23 module (generated wrapper) | `pkgs/n/nlohmann.json.lua` | `tests/examples/nlohmann.json/` | same as above / #48 |
| header-only + source-gated feature | `pkgs/c/compat.eigen.lua` | `tests/examples/eigen/` | `.agents/docs/2026-06-28-add-eigen-plan.md` / #50 |
| header-only (pure headers) | `pkgs/c/compat.opengl.lua`, `compat.khrplatform.lua` | — | `.agents/docs/2026-06-03-gl-runtime-packages-plan.md` |
| External build system (`install()`-driven) | `pkgs/c/compat.openblas.lua` (Make), `compat.openssl.lua` (Perl Configure + Make) | `tests/examples/openblas/`, `openssl/` | `docs/superpowers/specs/2026-07-26-openssl-asio-tls-design.md` / #124 |
| A feature pulling in a dependency (cross-package) | the `ssl` feature of `pkgs/c/chriskohlhoff.asio.lua` → `compat.openssl` | `tests/examples/asio-ssl/` | same as above |
