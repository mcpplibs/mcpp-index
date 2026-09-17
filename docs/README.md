# mcpp-index documentation

**English** | [简体中文](zh/README.md)

This directory holds the contributor reference documentation, written for humans and agents alike. The end-to-end
procedure for adding a package is defined in the agent skill
[`add-mcpp-index-package`](../.agents/skills/add-mcpp-index-package/SKILL.md); the documents below provide the details
behind each step.

| Document | Contents |
|------|------|
| [package-types.md](package-types.md) | Descriptor templates and samples for the four library shapes (C-source compat, header-only, C++23 module wrapper, external Form-A module repo) |
| [descriptor-examples.md](descriptor-examples.md) | The complete catalog of descriptors in this index, grouped by shape — what each package compiles, and what it deliberately leaves out |
| [cn-mirror.md](cn-mirror.md) | The GitCode `mcpp-res` CN mirror loop (`gtc` tooling, closed-loop verification, caveats), including the fallback when you lack write access to `mcpp-res` (plain-string upstream url) |
| [repository-and-schema.md](repository-and-schema.md) | Repository layout, descriptor schema cheat-sheet, `validate.yml` CI behavior, reproducing lint locally, case index |
| [openkal-compat.md](openkal-compat.md) | What the `openkal` label means, how it is measured, and how a package that fails in an openkal graph is adapted |

> The package field specification (the `mcpp = { … }` extension) is settled by `mcpp xpkg parse` — the very parser CI
> uses; for semantics and constraints see [`docs/spec/`](https://github.com/mcpp-community/mcpp/tree/main/docs/spec)
> in the mcpp repository.

Chinese versions of these documents live in [`zh/`](zh/).
