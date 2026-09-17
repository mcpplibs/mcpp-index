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
| `builds` | the member built, and its tests were not run or did not pass; the first diagnostic is kept |
| `fails` | the member did not build; the first diagnostic is kept |

The results are written to `.xpkgindex/openkal-compat.json` together with the
pins and the date. The site gives every package a test project covers the best
result any covering project recorded for each target, and files the package
under the `openkal` facet by its best target. The packages of openkal itself are
filed as `openkal itself`.

A member is also recorded as selecting platform dependencies of its own or not.
Selecting them is permitted: a package on openkal may use a platform's system
interfaces, provided they come from the dependency graph. The distinction is
shown and does not lower the label.

`tests/openkal/members.toml` lists what is measured. `[excluded]` lists members
that cannot be built in any openkal graph, each with its reason; a member that
fails is measured and published, not excluded.

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
