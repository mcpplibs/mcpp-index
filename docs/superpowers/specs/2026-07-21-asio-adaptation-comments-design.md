# Asio Adaptation Comments Design

## Goal

Restore the detailed adaptation notes from the retired
`chriskohlhoff.asio@1.38.1` descriptor in the canonical
`pkgs/a/asio.lua` descriptor, updated for the current package identity.

## Scope

Only the leading comment block before `package = {` changes. The package
identity, archives, hashes, mirrors, generated module wrapper, sources,
features, defines, platform flags, and tests remain unchanged.

The merged comments will document:

- installation with `mcpp add asio@1.38.1` and consumption with
  `import std; import asio;`;
- why mcpp-index generates `asio.cppm` and compiles upstream `src/asio.cpp`
  with `ASIO_SEPARATE_COMPILATION`;
- the explicit `import std;` contract, macro boundary, `error_code` identity,
  completion-token limitations, and the rule against mixing header inclusion
  with module import in one translation unit;
- API areas intentionally absent from the generated wrapper and their
  alternatives;
- the standalone package's Boost exclusions and the `co_spawn` migration from
  stackful `spawn`;
- a migration checklist from header-only Asio to the canonical module package.

## Stale References

The comments will not restore the retired `compat.asio` package as a usable
dependency or the old `chriskohlhoff.asio` package name. Historical comparisons
will use generic "header-only Asio" wording. The obsolete warning against bare
`mcpp add asio@1.38.1` will be replaced by the canonical install command.

## Validation

Run Lua syntax validation, the repository mirror-table check, strict parsing
with the workflow-pinned mcpp, `git diff --check`, and the targeted
`asio-module` consumer suite. No full workspace or OpenCV test is required for
this comment-only change.
