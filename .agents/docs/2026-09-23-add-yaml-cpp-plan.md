# compat.yaml-cpp 0.8.0 / 0.9.0

## Shape

C++ source compat (Form B). Upstream's CMake target is `src/*.cpp` plus, with
`YAML_CPP_BUILD_CONTRIB` at its default ON, `src/contrib/*.cpp`. No configure
step, no generated header, no platform code in the library. 0.9.0 adds one TU
(`src/fptostring.cpp`, over the vendored `src/contrib/dragonbox.h`) and one
public header (`yaml-cpp/fptostring.h`); one glob covers both versions.

Tags are spelled differently upstream (`0.8.0`, `yaml-cpp-0.9.0`), so the wrap
dirs differ (`yaml-cpp-0.8.0/`, `yaml-cpp-yaml-cpp-0.9.0/`); `*` absorbs both.

## Mirror

gitcode `mcpp-res/yaml-cpp`, releases `0.8.0` and `0.9.0`, assets byte-identical
to the GitHub tag archives (sha256 checked after download from both sides; each
GitHub archive downloaded twice, digest stable).

| version | sha256 |
| --- | --- |
| 0.8.0 | `fbe74bbdcee21d656715688706da3c8becfd946d92cd44705cc6098bb23b3a16` |
| 0.9.0 | `25cb043240f828a8c51beb830569634bc7ac603978e0f69d6b63558dadefd49a` |

## YAML_CPP_STATIC_DEFINE

Upstream makes it a PUBLIC definition of a static build and reads it only in
`include/yaml-cpp/dll.h`, which every public header reaches. A descriptor's
`defines` are package-private, so `mcpp_generated/yaml-cpp/dll.h` defines it
and `#include_next`s upstream's; `mcpp_generated` is first in `include_dirs`.
The compile database confirms the consumer TU carries no `-D` for it, and the
test's `#error` guard passes: the shim delivered it.

## Upstream defect found by the test

`GraphBuilderInterface` declares its destructor pure virtual and defines it
nowhere, in both versions. Any derived class (upstream's own `GraphBuilder<Impl>`
included) fails to link with `undefined symbol: ~GraphBuilderInterface()`
unless its user defines it. The descriptor does not supply the definition: a
consumer that already writes it would then get a duplicate symbol. The test
writes it, as any consumer of the contrib API must.

## Features

None. Contrib is on by default upstream and is two small TUs; there is no
optional component worth a gate.

## Verification

- `mcpp test -p yaml-cpp` / `-p yaml-cpp-v080` with the pinned mcpp 2026.9.18.3,
  cold: `test result ok`. Objects: 32 + test TU (0.9.0), 31 + test TU (0.8.0),
  equal to the source count.
- 0.8.0 member asserts at compile time that `yaml-cpp/fptostring.h` is absent,
  so it cannot pass by silently resolving 0.9.0.
- openkal: both members are listed in `tests/openkal/members.toml`. Locally,
  `x86_64-linux-gnu`: `runs (posix)` for both. The Windows leg is taken from
  the PR's openkal-compat run (a local run with an unpinned mcpp failed inside
  openkal-llvm-runtime's libunwind for the cli11 control member as well, so it
  says nothing about this package).
