# mwrap / xxx-m README layout

[简体中文](zh/mwrap-readme.md)

This is the README layout convention for module wrappers maintained as
`<upstream>-m` repositories. The [mwrap specification](mwrap.md) defines package
identity, versions and implementation ownership.

## Language and opening

- `README.md` is English; `README.zh.md` is required simplified Chinese.
- Put language links, the upstream repository, Releases, mcpp and Index on **one
  navigation line**. Use the uniform label `[Upstream](https://github.com/owner/repo)`, not `Upstream: owner/repo`.
- After the project name, write **one sentence** introducing the wrapper.
  Put any longer capability/architecture introduction **below the badges and
  before Modules and Getting started**, without a Characteristics heading.
- Preserve useful existing badges/navigation. Link to the wrapper's own CI and
  release pages and the correct licenses; avoid badges implying unsupported scope.

The opening order is fixed; the detailed paragraph is optional:

```text
# Project name
> One-sentence introduction.
English · 简体中文 · [Upstream](upstream-url) · Releases · mcpp · Index
[badges]
Optional detailed introduction, without a Characteristics heading.
## Modules
- `import mcpplibs.mwrap.library;`: Core API
- `import mcpplibs.mwrap.library.macros;`: Macro mappings
> More Modules API -> [Usage and API](docs/usage.md)
## Getting started
```

The quickstart heading can retain the project's original equivalent title
(Quick start, Install or Add The Package). Navigation is intentionally one line;
this does not justify compressing ordinary prose into very long lines.

## Content and order

Preserve each project's useful original section hierarchy and order after the
opening. Shared style does not require a wholesale rewrite into identical headings.
Translate headings while retaining their meaning. Use this sequence as a starting
point for a new README, adapting to the library:

1. Title, one-sentence introduction, one navigation line, then badges.
   Optional detailed introduction follows the badges, then Modules precedes quickstart.
2. Modules: list the root and a few useful public modules, one complete
   bullet per module: a complete import in a code span, a colon and its purpose.
   Follow with a blockquote link `> More Modules API -> [Usage and API](docs/usage.md)`.
   Use the actual declared names and state any required feature.
3. Quick start using the actual default `mcpp new` template; dependency and import
   examples for existing projects when useful. Actual mcpp feature switches may
   have their own concise table afterwards.
4. Examples, important platform/runtime conditions, detailed documentation links
   and license information in their existing sections.

Do not add a repeated `Use mcpp <version>. The new mwrap identity becomes
installable after index publication.` paragraph. Keep the exact tested tool pin in
`.xlings.json`, CI and detailed usage/build documentation. Mention a tool/SDK/device
requirement in the relevant section only when the reader needs it for the command.
Candidate status belongs in release/PR documentation; an unavailable example must
still be identified where it would otherwise mislead users.

## mcpp features and examples

These are actual mcpp manifest `[features]` / `[feature-deps.*]` switches,
not a general list of library capabilities. Prefer a short table of exact feature
names and their effects. State defaults and
module/backend boundaries in one sentence. For example:

| Feature | Purpose |
|---|---|
| `all-modules` | Main module interfaces; external backends remain explicit |
| `highgui-native` | The documented GTK3 / Win32 / Cocoa mapping |
| `dnn-onnxruntime` | ORT CPU integration on supported targets |

Do not invent a Features section for a library without optional features. Keep
long dependency graphs, complete matrices, provider setup and troubleshooting in
docs and link to them. Do not advertise planned features as implemented.

Dependency selectors, template commands and imports use full
`mcpplibs.mwrap.<lib>` names. Ordinary APIs retain upstream names. Version examples
must match the actual package release. Every default template must work without
user-supplied model/media assets; document desktop/device requirements for optional
templates. A small example must exercise a real library contract.

## Length and translation review

Aim for a concise page, roughly within **100–150 lines per language**. Shorter
pages are welcome; do not pad them to reach 100 lines. Do not hide prerequisites,
compress paragraphs into very long lines or use large folded blocks to meet the
target. A release guard may flag pages above 150 lines for editing.

English and Chinese must agree on versions, commands, features, platform limits
and relevant links. They need not have identical line counts. Check translated
heading anchors separately and keep reciprocal language links valid. Existing
Chinese-only entry pages become English defaults with the corresponding Chinese
content retained in `README.zh.md`, preserving their useful original layout.
