# Automatic updates

[English](automatic-updates.md) · [简体中文](zh/automatic-updates.md)

[openxlings/xpkgindex-update](https://github.com/openxlings/xpkgindex-update)
checks declared packages daily at 02:17 UTC (11:17 JST). GitHub may delay scheduled
runs. A manual run of [the workflow](../.github/workflows/xpkgindex-update.yml)
on the default branch performs the same update cycle; the optional `package`
input limits it to one `namespace:name`.

The workflow downloads new release resources, calculates SHA256 and opens at
most three new PRs per run as `github-actions[bot]`. It then explicitly dispatches
candidate, consumer, site and openkal checks on each PR branch. Candidate checks
build and run the new version and verify its lockfile; ordinary consumer tests
also cover the versions their manifests already select. Failed upgrades stay
visible in PR CI for maintainers to resolve. PRs are never automatically merged.

## Declare a package

When adding or updating a package, include `package.extensions.autoupdate` if:

- A public GitHub release or numeric tag identifies the package version.
- The download URLs follow a stable template and resources exist on all declared platforms.
- Updating the version does not require changing its build recipe, hooks or dependency policy.

```lua
extensions = {
    autoupdate = {
        tag = "v${version}",
        url = "https://github.com/acme/foo/archive/refs/tags/${tag}.tar.gz",
    },
},
```

The tag template contains exactly one `${version}`. URLs can use `${tag}`,
`${version}` or `${version:dash}` and may be shared or mapped by platform.
A `GLOBAL`/`CN` template table is valid only if both resources already exist and
have identical bytes; the updater does not create mirrors. A GitHub-only URL
for future versions is allowed even when historical entries have mirrors.
Use `package.repo` as a fallback when the URL does not identify a GitHub repo.

Commit snapshots, independent source/package version mappings, prereleases,
non-GitHub providers and upgrades requiring recipe changes need manual handling.
Do not invent a rule to opt them in; explain the exception in the PR instead.
The current xim adapter does not advance `latest.ref`.

## Verify a declaration

Use the reviewed updater commit pinned in the workflow (Python 3.11+):

```sh
python -m xpkgindex_update inspect --package compat:foo
python -m xpkgindex_update check --package compat:foo --output plan.json
# If a new version is ready, inspect its generated patch in a clean worktree:
python -m xpkgindex_update apply --plan plan.json --package compat:foo
```

`check` must parse the declaration and report the actual upstream result.
If already current, keep that result rather than inventing a candidate. An added
version must pass the candidate build/run/lockfile checks. Future upgrades may
still need manual adaptation when upstream changes its API or source layout.

Only new versions are appended. Historical version definitions, URLs, mirrors,
hashes and comments remain unchanged. When every platform uses identical
resources, new URL/SHA256 definitions are stored once in a leading local table
and referenced by platform entries. Different resources remain separate.

## Workflow and credentials

The scan and build jobs have read access. Only the default-branch `propose` job
receives `contents: write`, `pull-requests: write` and `actions: write`.
It consumes the exact scan artifact using the pinned CLI; no local user token
or long-lived secret is involved. Organization and repository settings must
allow GitHub Actions to create PRs. The combined setting also permits approvals,
but this workflow never approves or merges a PR.

Under [GitHub’s trigger rules](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow),
`GITHUB_TOKEN` does not provide unattended ordinary PR-triggered CI, so the job
explicitly dispatches each workflow. The consumer and openkal dispatches verify
an open, same-repository bot PR, its exact head SHA, default base and single
changed descriptor before selecting affected members. A regular manual
consumer dispatch without `update_pr` still runs the full regression.

One open update PR per package is retained. An existing manual PR editing the
same descriptor also blocks duplicates and keeps its ordinary PR CI. Closed
candidate PRs are not reopened.
A later daily run can resume missing CI dispatches on an existing bot PR without
creating duplicates; existing runs, including failures, are not silently rerun.
`max_prs` in [.github/xpkgindex-update.yml](../.github/xpkgindex-update.yml) limits
new PRs per run. No update PR can recursively create more PRs.

The temporary `wellwei/libmysqlclient` outage exception retains its scan error;
its affected consumers are reported as **NOT TESTED**, not successful builds.

## Contribution scope

A normal package PR changes its descriptor, consumer test and workspace entry
when needed. Include the automatic-update declaration when eligible and describe
any exception in the PR. Package additions are discovered by the site from the
descriptors: do not append package announcements or examples to either root
README, and do not edit site configuration for a routine package addition.
