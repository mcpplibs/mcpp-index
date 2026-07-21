# Asio Adaptation Comments Design

## Goal

Merge the useful notes from the retired `chriskohlhoff.asio@1.38.1`
descriptor into canonical `pkgs/a/asio.lua` without changing package behavior.

## Scope

Replace only the comment block before `package = {`. Keep three concise
sections:

- usage cautions for `mcpp add`, `import std`, module-only consumption, and
  propagated build defines;
- differences and limitations compared with header-only Asio;
- API component groups not exported by the generated wrapper.

Do not include a tutorial, detailed Boost history, or a migration checklist.
Do not restore `compat.asio` or `chriskohlhoff.asio` as usable package names.

## Validation

Prove the executable Lua table is unchanged, then run Lua syntax, mirror,
workflow-pinned parser, whitespace, and targeted `asio-module` checks only.
