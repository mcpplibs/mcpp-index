# Add mcpplibs.mwrap.concurrentqueue (concurrentqueue-m 1.0.5)

## Form

- Third-party upstream [cameron314/concurrentqueue](https://github.com/cameron314/concurrentqueue), tag `v1.0.5`. It
  is available under the Simplified BSD license or the Boost Software License; its semaphore is under zlib. The
  tarball (`4d6368a2…6ef3`) is the one compat.concurrentqueue 1.0.5 already pins.
- Form A external mwrap module repository: [mcpplibs/concurrentqueue-m](https://github.com/mcpplibs/concurrentqueue-m),
  package `mcpplibs.mwrap.concurrentqueue`. The version is the upstream one (first release of the identity, no
  revision suffix); tag series `mwrap-${version}`.
- Implementation ownership: the headers, and the C API sources with the `c-api` feature, are compat.concurrentqueue's.
  The wrapper vendors no upstream code. It retains upstream's README and license under `upstream/concurrentqueue/`,
  with checksums in `upstream/documents.json`.

## Modules

- `mcpplibs.mwrap.concurrentqueue` exports the upstream entities of `concurrentqueue.h`, `blockingconcurrentqueue.h`
  and `lightweightsemaphore.h` by `using` in `export namespace moodycamel`: `ConcurrentQueue`,
  `BlockingConcurrentQueue`, `ConcurrentQueueDefaultTraits`, `ProducerToken`, `ConsumerToken`, `LightweightSemaphore`,
  every `swap` overload, and `ConcurrentQueueTests`.
  - `moodycamel::details` is the implementation and is not exported.
  - Its TU-local helpers that are not templates over arbitrary types are adapted in
    `mcpplibs::mwrap::concurrentqueue::details`, each calling upstream's body.
- `mcpplibs.mwrap.concurrentqueue.macros` holds the value macros and the configuration inputs as built, all as
  `constexpr bool`. The syntax macros stay in `<mwrap/concurrentqueue/macros.hpp>`.
- `mcpplibs.mwrap.concurrentqueue.c_api` exports upstream's C API (`moodycamel_cq_*`, `moodycamel_bcq_*`), with the
  `c-api` feature, which forwards to `compat.concurrentqueue/c-api`.
- The `no-thread-local` feature sets upstream's `MOODYCAMEL_NO_THREAD_LOCAL`.
- GCC 16.1 module handling:
  - `MOODYCAMEL_NOEXCEPT_CTOR` / `_ASSIGN` are spelled with the equivalent type traits (upstream's configuration
    point). Upstream's expression names a `static` function inside a template argument, which GCC rejects as an
    exposure.
  - The module instantiates the queues' members once, so that the non-dependent specializations of `static` helpers
    have bodies in its interface.
  - A unit that includes `<cxxabi.h>` cannot instantiate the thread-exit path; `no-thread-local` is the documented
    remedy.

`tools/check_exports.py` audits every declaration of `moodycamel`, every name of `moodycamel::details`, the C API, and
every macro and configuration input against the pinned headers. It was negative-checked by removing an export and a
mapping.

## Verification

Wrapper CI runs on four rows, all required: Linux GCC 16.1, Linux LLVM 23.1.3, macOS LLVM and Windows LLVM. It
covers:

- the build, with and without `c-api`;
- the tests: multi-producer multi-consumer traffic with tokens and bulk operations, timed waits, user types and
  traits, the semaphore, the adapted helpers, the constants and header mixing;
- the `c-api` / `no-thread-local` test project;
- the export audit;
- upstream's `tests/unittests`, all 45 registered tests, built against the module instead of the headers. The
  conformance tool documents its mechanical edits and applies them to the pinned tarball's files.

The templates job scaffolds the default `pipeline` template as an installed package, builds it with `--strict` and runs
it.

Local checks, with the CI-pinned mcpp 2026.10.26.1 and `MCPP_INDEX_MIRROR=GLOBAL`:

- `bash tests/run_members.sh concurrentqueue-mpmc` installs the real release archive through the candidate index. The
  consumer runs four producers enqueueing in bulk through tokens and four consumers waiting with timeouts; every item
  must arrive once and in per-producer order. It then exercises a timed-out wait and the semaphore. Result:
  `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.concurrentqueue@1.0.5` reports "Verified
  real indexed archive installation and unmodified template consumer".

## Mirror and updates

This change has no `mcpp-res` access. The descriptor therefore uses the GitHub release URL as a plain string, and CN
users fall back to it. A maintainer can add the GitCode mirror with identical bytes. `extensions.autoupdate` follows
the repository's own `mwrap-${version}` tags.

## Motivation

openmui.core's UI queue is a `moodycamel::ConcurrentQueue`. Through this module its implementation unit imports
`mcpplibs.mwrap.concurrentqueue` instead of including concurrentqueue.h.
