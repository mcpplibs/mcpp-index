# The CN mirror loop (gtc / gitcode / mcpp-res)

**English** | [简体中文](zh/cn-mirror.md)

Giving every package a domestic download mirror speeds up `mcpp add/build` inside mainland China. The mechanism:
rewrite `xpm.<plat>.<ver>.url` from a single string into `{ GLOBAL = "<upstream>", CN = "<gitcode mirror>" }`, where
resolution prefers **GLOBAL over CN** (GLOBAL stays the default and CN is only the fallback when it is unavailable).
Resolution happens in **xlings** (the xim engine), not in mcpp's C++ parser, so the mechanism is spec-driven and takes
effect through the existing engine.

- CN layout: the gitcode organization **`mcpp-res`**, one repository per library, with the assets attached to a
  release tagged by version number.
- The repo slug is the package name with the `compat.` or `mcpplibs.` prefix stripped (`compat.eigen` → `eigen`;
  for the `nlohmann` family prefer `nlohmann-json`, to avoid the ambiguity of a bare `json`).
- The public URL of a CN asset follows this convention:
  `https://gitcode.com/mcpp-res/<slug>/releases/download/<ver>/<slug>-<ver>.<ext>`
- A library's own maintainer may host its CN mirror instead, under their own gitcode account
  (`https://gitcode.com/<owner>/<repo>/releases/download/<tag>/<file>`, as `ZheFeng7110.boost` does). They then keep it
  in step with the GLOBAL asset: the same bytes, so the same `sha256`.

## Fallback without `mcpp-res` write access

Setting up a mirror requires write access (a token) to the gitcode `mcpp-res` organization. Without it, do not force a
mirror table into existence: lint (`check_mirror_urls.lua`) mandates that once `url` is written as a table, its `CN`
must be a gitcode release asset (`https://gitcode.com/<owner>/<repo>/releases/download/…`), so
`{ GLOBAL=upstream, CN=upstream }` fails lint outright. The correct
fallback is a plain-string url (upstream release only) — lint imposes no mirror constraint on plain-string urls:

```lua
-- fallback: no CN mirror, GLOBAL and CN both equal the upstream release (a single string is enough)
["0.1.1"] = { url = "https://github.com/<owner>/<repo>/releases/download/v0.1.1/<repo>-0.1.1.tar.gz",
              sha256 = "…" },
```

- CN users fall back to the upstream source: slower to reach, but functionally unaffected.
- Existing precedent: `pkgs/t/tensorvia-cpu.lua` (a user's own mcpp library, no CN mirror, a single upstream string
  url on all three platforms).
- Later, once access is granted or a maintainer supplies the mirror, that version's `url` can be rewritten into a
  `{ GLOBAL=…, CN=… }` table (the sha256 stays the same).

If you need to express "GLOBAL and CN both point at upstream", use the single-string form above rather than a
`{ GLOBAL=x, CN=x }` table (which cannot pass the "CN must point at gitcode" lint check).

## The gtc tool

`gtc` (`tools/gtc`, also at `~/.local/bin/gtc`; a Python implementation over the gitcode API v5). The token lives in
`~/.config/gitcode-tool/config.json` and can be overridden through `GITCODE_TOKEN` or `--token`. The currently
logged-in user is `Sunrisepeak`.

```bash
gtc repo create  <owner>/<name> [--description …] [--private]   # owner==login goes through /user/repos, otherwise /orgs/<owner>/repos; idempotent (422 only warns)
gtc repo push    <owner>/<name> <dir> [--branch main]
gtc release create  <owner>/<repo> --tag T [--name] [--body-file] [--target] [--prerelease]   # idempotent (skips when the tag exists)
gtc release upload  <owner>/<repo> --tag T <file…>              # NOT idempotent; query the existing assets before uploading
gtc release publish <owner>/<repo> --tag T [--name] [--target] [--asset FILE]   # equivalent to create + upload
gtc pr create    <owner>/<repo> --title --head --base [--body-file]
```

`gtc` cannot create an org; `mcpp-res` already exists. To create a new org, call `POST /api/v5/orgs` and supply both
the `name` and the `path` field.

## Standard operation (with slug=`eigen`, ver=`5.0.1` as the example)

```bash
# 0. download the GLOBAL upstream tarball and compute its sha256 (goes into all three platforms of the descriptor);
#    compute it twice to confirm it is stable
curl -L -fsS -o eigen-5.0.1.tar.gz "https://gitlab.com/libeigen/eigen/-/archive/5.0.1/eigen-5.0.1.tar.gz"
sha256sum eigen-5.0.1.tar.gz

# 1. create the repository (idempotent)
gtc repo create mcpp-res/eigen --description "Eigen — CN mirror for mcpp-index"

# 2. a new repo has no branch yet, so push an init commit first — only then can a release target main
mkdir eigen-init && echo "# Eigen — CN mirror" > eigen-init/README.md
gtc repo push mcpp-res/eigen eigen-init --branch main

# 3. publish the release and upload the asset (upload the same file as GLOBAL, so the bytes and the sha match)
gtc release publish mcpp-res/eigen --tag 5.0.1 --name "Eigen 5.0.1" --target main --asset eigen-5.0.1.tar.gz

# 4. close the loop: CN returns 200 and is byte-identical to GLOBAL
CN="https://gitcode.com/mcpp-res/eigen/releases/download/5.0.1/eigen-5.0.1.tar.gz"
curl -fsSL -o cn.tar.gz -w 'CN http=%{http_code}\n' "$CN"
[ "$(sha256sum eigen-5.0.1.tar.gz|cut -d' ' -f1)" = "$(sha256sum cn.tar.gz|cut -d' ' -f1)" ] && echo "BYTE-IDENTICAL"
```

## Caveats

- The gitcode API is rate-limited to 25 calls/minute/user, so space calls about 3.2 seconds apart and back off and
  retry on a 429.
- Release assets with the same name cannot be overwritten; a mistaken upload can only be deleted through the web UI,
  so settle on the name in one go (`<slug>-<ver>.<ext>`).
- A new repo has no branch: without pushing an init commit first, a release with `--target main` fails.
- Content filtering: some library descriptions or repository names are rejected by gitcode's text filter — reword them
  neutrally.
- You must upload the same package as GLOBAL: never upload a modified one, or CN and GLOBAL diverge in a way that is
  hard to notice outside `mirror-cn-reachable`.
- sha drift: GitLab archives are occasionally repacked, which changes the sha, so the descriptor's sha must equal the
  actual bytes GLOBAL serves today (use it right after downloading, and compute it twice).
- xlings deduplicates globally by sha256: when CN and GLOBAL share a sha, a local "switch to CN and re-test" hits the
  dedup cache and never actually reaches gitcode — so verify CN with `curl` directly (step 4 above, which is also what
  CI's `mirror-cn-reachable` does).

## CI guarantees

`.github/workflows/validate.yml` sets up two checks:

- `tests/check_mirror_urls.lua` inside `lint`: when a url is written as a table, both GLOBAL and CN must be present,
  and CN must point at the gitcode `mcpp-res` mirror.
- `mirror-cn-reachable`: extracts every CN url and `curl`s them one by one; anything other than 200 fails.
