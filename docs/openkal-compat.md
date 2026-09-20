# openkal compatibility

**Reader:** a package author or index maintainer who wants to know whether a
package works on openkal, or who is adapting one.

**The question this document answers:** what the `openkal` label on the site
means, how it is measured, and how a descriptor adapts a package whose build
fails in an openkal graph.

## 1. What is measured

A build selects openkal when its graph contains `openkal-llvm-runtime` (C++) or
`openkal-musl` (C). The graph then supplies four layers, and each guarantees only
its own:

| Layer | Supplied by | Guarantees |
| --- | --- | --- |
| `kernel-abi = openkal` | the specification and one implementation per target | every `kal_*` operation behaves the same on every platform |
| `c-abi = musl` | `openkal-musl` | a POSIX-shaped C environment; what it cannot provide it refuses and lists |
| `c++-abi = libc++` | `openkal-llvm-runtime` | a C++ runtime configured for that C library |
| build tool | `mcpp` | a layer supplied by the graph is supplied wholly by it; host headers are not searched |

The label is a measurement of the package's test project in that graph, not a
declaration. A descriptor has no field for it.

## 2. The label

`tests/openkal/compat.py run` copies each member listed in
`tests/openkal/members.toml`, adds the runtime pinned in `tests/openkal/pins.toml`,
and builds it with the pinned toolchain for every pinned target. The result is
recorded per target:

| Result | Meaning |
| --- | --- |
| `runs` | the member's tests passed; on a target other than the host they ran through the pinned runner (Wine for Windows) |
| `builds` | the member's own tests compiled and linked for the target, and were not run or did not pass; the first diagnostic is kept |
| `fails` | the member did not build; the first diagnostic is kept |
| `refused` | the member asked this graph for a capability it does not supply, and was told so before anything was compiled |

**A target with no runner is measured with `mcpp test --no-run`, and until it
was, `builds` was a statement about the dependencies.** Every member here keeps
its sources under `tests/`, and `mcpp build` builds the PACKAGE: for a target
this host cannot execute it compiled the member's dependencies, exited 0, and
that exit code was recorded as `builds`. Measured on `archive` for
`aarch64-macos`: 1990 objects, none of them from `tests/compression.cpp` or
`tests/versions.cpp`. `mcpp test --no-run` compiles and links the member's own
tests for the target and does not execute them, which is what this row claims.

**A refusal is not a failure, and the difference is not a matter of degree.**
A member that declares `[kernel-abi] requires-interfaces` naming something the
resolved implementation does not provide has been answered correctly. Counting
it as a failure turns the compatibility figure into a score the build tool is
judged by, and a score of that shape asks the engine to supply what the
environment does not have -- which is how a build tool ends up simulating an
operating system it is not running on. The summary counts the two apart.

The judge is mcpp's reason token `[interface-not-provided]`, matched WITH its
brackets. mcpp prints it in the refusal's own message the way it prints
`E0006`, and it is an entry in `docs/50`'s token table -- a machine interface
this measurement may read, rather than a sentence that may be rewritten. The
brackets are part of the match: read as a bare word, the token is a hyphenated
phrase an ordinary compile error could contain, and a member that merely failed
while quoting it would be recorded as correctly refused. No member carries it today --
`requires-interfaces` reaches the index with mcpp 2026.9.20.1 and no
third-party descriptor states it yet.

Beside `status`, and derived from the same measurement, `compat.py` records a
second, orthogonal `kind`: not whether the member worked, but what it needed
in order to:

| Kind | Meaning | Derived from |
| --- | --- | --- |
| `posix` | built and ran using only the C environment the graph's C library presents | `status == "runs"` and the member declares no platform dependency of its own |
| `platform` | needs the platform's own interfaces | the member declares a platform dependency of its own (a per-target `dependencies` table — see rule 1 below), and `status` is `runs` or `builds` |

`kind` is omitted for `status == "fails"`: an unmeasured member states nothing
about its relation to the platform. A third kind, `native` — built in a reduced
ISO C form with no POSIX-shaped package anywhere in the graph — is deliberately
deferred, because that form does not exist yet; it is not computed or shown
anywhere in this pipeline.

Selecting a platform dependency is permitted: a package on openkal may use a
platform's system interfaces, provided they come from the dependency graph.
The distinction is shown and does not lower the `status` label — it only
decides `kind`. See `tests/openkal/compat.py`'s module docstring for the exact
derivation, stated next to the code that computes it.

The results are written to `.xpkgindex/openkal-compat.json` together with the
pins and the date. The site gives every package a test project covers the best
result any covering project recorded for each target, and files the package
under the `openkal` facet by its best target and under the `openkal_kind`
facet by `platform` if any measured target recorded it, else `posix` if any
did. The packages of openkal itself are filed as `openkal itself` and carry
neither `kind` nor `openkal_kind`: they answer what openkal is, not what a
package built on it needs.

The `openkal_kind` facet and the badge it drives are a package-level
**summary**: they take the strictest target, the way `platform` above is
chosen over `posix` whenever both were measured. A package can genuinely be
`posix` on one target and `platform` on another — glfw needs a
window-system SDK everywhere it is measured, tinyhttps needs one only where
it falls back from epoll to Winsock — and the summary does not distinguish
those two shapes; it says `platform` either way, because that is true of at
least one target. The package's detail page's per-target `openkal` table (the
`environment` column, beside `result`) is the authority for what one
particular target actually needed; read that, not the badge, when the
question is about a target rather than the package as a whole.

`tests/openkal/members.toml` lists what is measured. `[excluded]` lists members
that cannot be built in any openkal graph, each with its reason; a member that
fails is measured and published, not excluded.

`[not-portable.<member>]` declares one TARGET of one member unbuildable by
construction, with the reason. It exists because `[excluded]` is whole-member
and some members are neither: `cmp-module` runs on `x86_64-windows-gnu` and
cannot build on `x86_64-linux-gnu`, because asio's `detail/config.hpp`
includes `<linux/version.h>` whenever `__linux__` is defined, outside every
`ASIO_DISABLE_*` guard. Excluding the member outright would discard a result
that is true in order to hide one that is also true.

**The bar is that no manifest key reaches it.** Upstream source asking in the
preprocessor qualifies; a generated configuration header this index writes
does not, and belongs in the recipe instead. `curl`'s `linux/tcp.h` is the
second kind — `#define HAVE_LINUX_TCP_H 1` inside `#if defined(__linux__)` in
`pkgs/c/compat.curl.lua`, which reads a correct fact about the kernel as a
claim about which userspace headers are installed.

**The cell is measured anyway, and `compat.py check` fails if it builds.** A
declaration that takes a cell out of the figure on the strength of a sentence
has to stay falsifiable; one that nothing can contradict is a permanent
excuse. The cost is a build that was already being paid for before the
declaration existed.

### curl's two failures have two different causes

Both are recipe defects, and neither is the same defect:

| target | first diagnostic | cause |
| --- | --- | --- |
| `x86_64-linux-gnu` | `lib/setopt.c:31: 'linux/tcp.h' file not found` | `#define HAVE_LINUX_TCP_H 1` inside `#if defined(__linux__)`. The kernel IS Linux, so the predicate is right; what is wrong is reading it as "glibc's userspace headers are installed". The honest test is `__has_include(<linux/tcp.h>)`. The same block also asserts `HAVE_GLIBC_STRERROR_R`, which is false over musl. |
| `x86_64-windows-gnu` | `curl_setup.h:591: "too small curl_off_t"` | The recipe's `windows` branch omits `HAVE_CONFIG_H` so that `curl_setup.h` reaches the checked-in `lib/config-win32.h`, and links `-lws2_32` with Schannel. Over openkal that target presents POSIX and is **LP64**, while `config-win32.h` is written for LLP64 and the Win32 API. |

**The second is the interesting one: the recipe branches on the PLATFORM where
the question is about the C ENVIRONMENT.** Those two agreed on every target
this index had until openkal presented POSIX on Windows, and mcpp has the
predicate for the question actually being asked — `cfg(c-abi = "musl")`
(mcpp docs/22, "Adaptation To The Resolved Target Side"). Selecting the
generated POSIX configuration there, rather than the checked-in Win32 one, is
the shape; it also needs this index's OpenSSL over the same environment, so
it is a larger change than the first and is not folded into it.

## 3. When it runs

`.github/workflows/openkal-compat.yml` runs weekly and on demand, measuring every
listed member. For a pull request it measures every member when the openkal
family or `tests/openkal` changes, and otherwise the members whose test projects
depend on a changed descriptor. It does not block a merge unless the comparison
below is enabled.

It installs the Windows cross toolchain's host headers on purpose. A build that
reached the host's headers would change its result when they are present, so a
result that does not change is evidence that the graph was closed.

The workflow also compares a new measurement with the published file
(`compat.py check`) and reports every member whose label for a target became
lower. The comparison becomes a required check for pull requests once the
repository variable `OPENKAL_RATCHET` is `on`; it is enabled after the weekly
measurement has been stable for two consecutive weeks.

## 4. Adapting a package

A package that fails in an openkal graph has met one of the layers. The rules
below decide where the adaptation goes.

1. **Adapt on the layer that differs.** A missing header or C runtime function
   (`io.h`, `_lseeki64`, `TargetConditionals.h`, `winsock2.h`) is a property of
   the C library, and the adaptation is selected with `c-abi`:

   ```lua
   target_cfg = {
       ["cfg(all(windows, c-abi = \"musl\"))"] = { cflags = { ... } },
   },
   ```

   A missing facility (`epoll`, signal handlers) is a property of openkal. Prefer
   a feature of the package that selects another mechanism (for example a
   `select`-based reactor); where a descriptor must select it, use
   `cfg(all(kernel-abi = "openkal", c-abi = "musl"))`. Nothing in source should
   test whether it is built on openkal.

2. **Do not undefine a platform macro.** `_WIN32` and `__APPLE__` are defined by
   the target triple and are true. Change the package's own condition instead,
   in this order of preference: a configuration macro the package already
   honours (`Z_HAVE_UNISTD_H`, `HAVE_*`); a generated configuration header
   (`generated_files`); a patch. An exception is permitted only for a private
   translation unit whose result reaches no public header, and the descriptor
   states why beside it.

3. **A public header is read one way.** A macro that changes what a public header
   declares must reach the package's consumers as well as the package. If it
   cannot, the member asserts the agreement (rule 4).

4. **A changed configuration is checked across the boundary.** A member of a
   package whose configuration differs in an openkal graph asserts a layout the
   compiled package reports about itself against the one its consumer computes.
   `tests/examples/zlib` compares `zlibCompileFlags()` with `sizeof(z_off_t)`.

5. **One C runtime and one C++ runtime per image.** A package that depends on a
   platform may call the platform's system interfaces across which only handles
   and values pass. A static library compiled against the platform's C runtime,
   or an object that runtime owns crossing the boundary (`FILE*`, memory released
   by the other runtime, `errno`), is not supported, and such a package is not
   measured on openkal. A callback that a platform library makes on a thread it
   created has no C library state and must not rely on it.

## 5. Reproducing a measurement

```bash
python3 tests/openkal/compat.py run --member cjson --target x86_64-linux-gnu --out /tmp/r.json
python3 tests/openkal/compat.py check --results /tmp/r.json --baseline .xpkgindex/openkal-compat.json
```

The members are copied into `tests/openkal-work/`, which is not tracked, and the
directory is removed when the run ends.

## The 2026-09-20 measurement, and what it settled

The graph moved from `openkal-llvm-runtime 0.10.0` to `0.12.0`. Below that
version no package the pin resolved declared a `[c-abi]` block, so mcpp
realised nothing for the target side and the Windows leg compiled as
`x86_64-w64-windows-gnu` with `_WIN32` defined. Every Windows result recorded
before this move measured the behaviour the declaration exists to replace.

| target | before | after |
| --- | --- | --- |
| `x86_64-linux-gnu` | 27 runs / 3 fails | 27 runs / 3 fails |
| `x86_64-windows-gnu` | 15 runs / 15 fails | **23 runs / 7 fails** |

Eight members that had failed on a missing Windows header now run unchanged:
asio (through `cmp-module`), catch2, cli11, eigen, fmtlib.fmt, libpng, re2 and
lua (through `capi-lua`). Each selected its Windows branch on `_WIN32` or
`__MINGW32__`; with neither defined it takes the POSIX branch it takes on
Linux, and needs no adaptation in its descriptor. This is what the declaration
is for, and it is the first measurement in which it was in effect.

**The seven that remain, and what each is waiting on.** They are not one
residue but three, and only the first is about the C environment at all.

| member | first diagnostic | what it is waiting on |
| --- | --- | --- |
| mimalloc | `atomic.h:16: 'windows.h' file not found` | `__CYGWIN__`. Its guard is `#if defined(_WIN32) \|\| defined(__CYGWIN__)`, with the comment "we use windows locks on cygwin, but otherwise treat it at unix" |
| sqlite3 | `sqlite3.c:29506: 'windows.h' file not found` | `__CYGWIN__`. `SQLITE_OS_WIN` is selected by a list that includes it, and `os_win.h` then includes `windows.h` unconditionally |
| archive (xz) | `tuklib_physmem.c:21: 'windows.h' file not found` | a generated configuration, as on every system |
| c-ares | `ares_setup.h:81: 'windows.h' file not found` | a generated configuration |
| curl | `curl_setup.h:591: "too small curl_off_t"` | a generated configuration, for LP64 |
| doctest | `ld.lld: undefined symbol: __cxa_thread_atexit` | the C++ runtime, not the C environment |
| spdlog | `ld.lld: undefined symbol: __cxa_thread_atexit` | the same |

**The first two settle a trade-off that was left open.** `__CYGWIN__` is left
defined by the Cygwin-flavoured realisation on the reasoning that portable
third-party code needing to know the OBJECT FORMAT has no other name for "PE
with a POSIX-presenting C environment", and mcpp's own documentation recorded
that as "a trade-off for the 30-member measurement to settle, not a settled
fact". The measurement has now settled half of it: two members read that name
as "the Win32 API is available", which is a different question, and mimalloc's
own comment says so in as many words. A name borrowed from another environment
carries the meaning its lender gave it.

**The last two are new, and they are progress.** doctest and spdlog previously
stopped at a missing header; they now compile and stop at the link, naming
`__cxa_thread_atexit` -- the hook libc++abi calls to register a `thread_local`
destructor. It is a gap in the C++ runtime above openkal rather than in the C
environment, and it was not reachable until the environment was right.
