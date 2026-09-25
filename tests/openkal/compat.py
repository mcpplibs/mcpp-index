#!/usr/bin/env python3
"""Measures whether the index's test projects build and run on openkal.

The measurement is the whole of what the site reports: a package is labelled
by what its test project did in an openkal graph, not by what its descriptor
claims. See docs/openkal-compat.md.

    compat.py run   [--member NAME ...] [--target TRIPLE ...] --out FILE
    compat.py check --results FILE [--baseline FILE] [--members NAME ...]
    compat.py select [--base REF] FILE ...

`run` copies each selected member of tests/examples into tests/openkal-work,
adds the openkal C++ runtime named by pins.toml, and builds with the pinned
toolchain. A target equal to the host is tested (`mcpp test`); another target
is tested through its runner when pins.toml names one and the runner is on
PATH, and has its tests built (`mcpp test --no-run`) otherwise. Each member is reported per target as one of

    runs      the member's tests passed
    builds    the member's own tests compiled and linked for the target; this
              host cannot run them, so `mcpp test --no-run` stopped there
    fails     the build or the tests failed; the first diagnostic is kept

and, alongside `status`, a second and orthogonal `kind` records how the
member relates to the platform rather than whether it worked:

    posix     built and ran using only the C environment the graph's C
              library presents -- `status == "runs"` and the member declares
              no platform dependency of its own (see `platform_bound` below)
    platform  needs the platform's own interfaces -- the member declares a
              platform dependency of its own (a per-target `dependencies`
              table, the same fact `platform_bound` already reports as
              "not portable" -- see docs/openkal-compat.md #4 rule 1, where a
              feature's `feature-deps` reaches a platform SDK shim) -- and
              `status` is "runs" or "builds"

`kind` is omitted, not guessed, when `status == "fails"`: an unmeasured member
states nothing about its relation to the platform. A third label, `native`
(built in the reduced ISO C form, with no POSIX-shaped package anywhere in
the graph), is deliberately deferred -- that form does not exist yet (design:
openkal/.agents/docs/2026-09-18-openkal-c-environment-and-personalities-
design.md §7, §12 decision 5) -- and is not computed here.

`select` reads changed file paths and prints the members to measure: every
listed member when the graph or the harness changed (an openkal family
descriptor, pins.toml, compat.py), otherwise only the members the change names
-- an entry added or changed in members.toml (compared with `--base`), a
member's own test project, or a descriptor a member's test project depends on.
See `select_members`.

`check` compares a results file with a baseline and fails when a member that
the baseline records as `runs` or `builds` for a target is recorded lower. It
is the regression guard for labels that have been published. It ALSO fails
when a cell declared `[not-portable]` in members.toml built: a declaration
that removes a cell from the figure has to stay falsifiable, or it is a
permanent excuse nothing can contradict.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import os
import platform
import re
import shutil
import subprocess
import sys

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover
    tomllib = None

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
EXAMPLES = os.path.join(ROOT, "tests", "examples")
WORK = os.path.join(ROOT, "tests", "openkal-work")
# The ordering a published label may not go backwards along. `refused` sits
# beside `fails` and not above it: an interface the graph does not provide is
# not a working member, and a member that used to run and is now refused has
# had something taken away from it. What the two do NOT share is the count the
# summary reports --- see `measure`.
RANK = {"fails": 0, "refused": 0, "builds": 1, "runs": 2}


def load_toml(path: str) -> dict:
    with open(path, "rb") as f:
        return tomllib.load(f)


def host_triple() -> str:
    machine = platform.machine().lower()
    arch = {"amd64": "x86_64", "arm64": "aarch64"}.get(machine, machine)
    system = platform.system().lower()
    if system == "linux":
        return f"{arch}-linux-gnu"
    if system == "darwin":
        return f"{arch}-apple-darwin"
    if system == "windows":
        return f"{arch}-windows-msvc"
    return f"{arch}-{system}"


def host_executes(target: str, host: str | None = None) -> bool:
    """Whether this host runs the target's programs itself, with no runner.

    A Linux host executes a Linux image of its own architecture whatever C
    library the image carries: an `x86_64-linux-musl` program is a static
    image, and mcpp runs it on an `x86_64-linux-gnu` machine as it is (`mcpp
    test --target x86_64-linux-musl` needs no runner). Measured with `--no-run`
    instead, such a cell would record `builds` for a member that runs."""
    h = (host or host_triple()).split("-")
    t = target.split("-")
    return len(h) >= 2 and len(t) >= 2 and h[1] == "linux" and t[1] == "linux" \
        and h[0] == t[0]


def packages_of(manifest: dict) -> list[str]:
    """The index packages a member depends upon, as `namespace.name`."""
    found: list[str] = []

    def take(table: dict) -> None:
        for key, value in table.items():
            if isinstance(value, dict) and not ({"version", "path", "features"} & set(value)):
                for name in value:
                    found.append(f"{key}.{name}")
            else:
                found.append(key if "." in key else f"mcpplibs.{key}")

    for section in ("dependencies", "dev-dependencies"):
        if isinstance(manifest.get(section), dict):
            take(manifest[section])
    for cfg in (manifest.get("target") or {}).values():
        if isinstance(cfg, dict):
            for section in ("dependencies", "dev-dependencies"):
                if isinstance(cfg.get(section), dict):
                    take(cfg[section])
    return sorted(set(found))


def platform_bound(manifest: dict) -> bool:
    """A member that selects dependencies per target brings platform code of its
    own. The openkal implementation is selected by the runtime and is not counted."""
    for cfg in (manifest.get("target") or {}).values():
        if isinstance(cfg, dict) and cfg.get("dependencies"):
            return True
    return False


def declared_not_portable(decls: dict, member: str, target: str) -> str | None:
    """The reason `members.toml` gives for this (member, target) being
    unbuildable by construction, or None.

    PER TARGET, NOT PER MEMBER. `[excluded]` already covers a member that
    cannot be built in any openkal graph; this covers one that builds on some
    targets and cannot on another, where excluding the member outright would
    discard a result that is true."""
    return ((decls.get(member) or {}).get(target)) or None


def kind_of(manifest: dict, status: str) -> str | None:
    """The platform-relation label for one (member, target) result -- see the
    `posix` / `platform` table in this module's docstring, which this
    function is the whole of the implementation of. `platform_bound` is the
    one signal used for "declares a platform dependency"; there is
    deliberately no second, separate heuristic guessing at a package's
    internals -- a label not backed by a declared or measured fact is worse
    than no label, so an ambiguous case returns None rather than a guess."""
    if status in ("fails", "refused"):
        return None
    if platform_bound(manifest):
        return "platform"
    if status == "runs":
        return "posix"
    return None


def prepare(member: str, pins: dict) -> str:
    """Copies a member and states the openkal graph in its manifest.

    The copy sits at the same depth as tests/examples/<member>, so a relative
    `[indices]` path in the member resolves to the same checkout."""
    src = os.path.join(EXAMPLES, member)
    dst = os.path.join(WORK, member)
    shutil.rmtree(dst, ignore_errors=True)
    # Build state is not copied, and a link is copied as a link: a member's
    # `.mcpp` directory links into the package store.
    shutil.copytree(src, dst, symlinks=True, ignore=shutil.ignore_patterns(
        "target", ".mcpp", "compile_commands.json", "mcpp.lock"))
    path = os.path.join(dst, "mcpp.toml")
    text = open(path, encoding="utf-8").read()
    runtime = f'openkal-llvm-runtime = "{pins["runtime"]}"\n'
    if re.search(r"^\[dependencies\]\s*$", text, re.M):
        text = re.sub(r"^\[dependencies\]\s*$", "[dependencies]\n" + runtime.rstrip("\n"),
                      text, count=1, flags=re.M)
    else:
        text = text.rstrip("\n") + "\n\n[dependencies]\n" + runtime
    # A copy is not a member of this workspace and does not inherit its
    # `[indices]`; without this line `compat` would resolve from the published
    # index and a changed descriptor in this checkout would not be measured.
    if not re.search(r"^\[indices\]\s*$", text, re.M):
        text += f'\n[indices]\ncompat = {{ path = {json.dumps(ROOT)} }}\n'
    for triple, runner in (pins.get("runners") or {}).items():
        if f"[target.{triple}]" not in text and f"[target.'{triple}']" not in text:
            text += f"\n[target.{triple}]\nrunner = {json.dumps(runner)}\n"
    open(path, "w", encoding="utf-8").write(text)
    return dst


def first_diagnostic(output: str) -> str:
    # A compiler's own diagnostic names a file and a line, and is preferred to
    # the build tool's summary of it.
    for line in output.splitlines():
        if re.search(r":\d+(:\d+)?: (fatal error|error):", line):
            return line.strip()[:300]
    for line in output.splitlines():
        if re.search(r"\b(fatal error|error)\b[:\[]", line) and "test result" not in line:
            return line.strip()[:300]
    for line in output.splitlines():
        if "FAIL" in line:
            return line.strip()[:300]
    return output.strip().splitlines()[-1][:300] if output.strip() else ""


def command_for(target: str, toolchain: str, native: bool, can_run: bool) -> list:
    """The command that measures one cell.

    Separated from `measure` so the choice has a criterion that runs without a
    toolchain, a network or a member (`compat.py selftest`). It decides what a
    published `builds` means, and the reading it produced before was about the
    member's dependencies rather than the member.
    """
    cmd = ["mcpp", "test", "--toolchain", toolchain]
    if not native:
        cmd += ["--target", target]
    if not can_run:
        # `mcpp test --no-run`, NOT `mcpp build`, AND THE DIFFERENCE IS THE
        # WHOLE CELL.
        #
        # `mcpp build` builds the PACKAGE. Every member here keeps its sources
        # under `tests/`, so for a target with no runner it compiled the
        # member's dependencies, exited 0, and this file recorded `builds` --- a
        # statement about musl and zlib with the member's name on it. Measured
        # on `archive` for aarch64-macos: 1990 objects, of which none came from
        # `tests/compression.cpp` or `tests/versions.cpp`.
        #
        # `--no-run` compiles and links the member's own tests for the target
        # and does not execute them, which is exactly what this cell claims.
        cmd.append("--no-run")
    return cmd


def measure(member: str, target: str, pins: dict) -> dict:
    work = prepare(member, pins)
    toolchain = pins["toolchain"]
    native = target == host_triple()
    runner = (pins.get("runners") or {}).get(target)
    can_run = bool(native or host_executes(target)
                   or (runner and shutil.which(runner[0])))
    cmd = command_for(target, toolchain, native, can_run)
    proc = subprocess.run(cmd, cwd=work, capture_output=True, text=True,
                          timeout=pins.get("timeout", 3600))
    out = proc.stdout + proc.stderr
    if proc.returncode == 0:
        status = "runs" if can_run else "builds"
        return {"status": status}
    return classify_failure(out, can_run)


def classify_failure(out: str, can_run: bool) -> dict:
    """Classify a member whose build or test command exited non-zero.

    Separated from `measure` so the rule below has a criterion that runs
    without a toolchain, a network or a member: `compat.py selftest`. The
    distinction it draws decides a published figure, and until this split
    the only way to exercise it was a four-hour matrix.
    """
    built = can_run and re.search(r"^\s*Running bin/", out, re.M) is not None
    if built:
        return {"status": "builds", "diagnostic": first_diagnostic(out)}
    # A REFUSAL IS NOT A FAILURE, AND THE DIFFERENCE IS NOT A MATTER OF DEGREE.
    #
    # A member that asks this graph for a capability the graph does not supply
    # is told so before anything is compiled, and being told so is the correct
    # outcome rather than a smaller kind of failure. Counting it as one turns
    # the compatibility figure into a score the build tool is judged by, and a
    # score of that shape asks the engine to supply what the environment does
    # not have --- which is how a build tool ends up simulating an operating
    # system it is not running on.
    #
    # THE JUDGE IS A REASON TOKEN, AND THE BRACKETS ARE WHAT MAKE IT ONE.
    # mcpp prints `[interface-not-provided]` in the refusal's own message, in
    # brackets, the way `E0006` does (docs/50 §"One token is also printed by
    # `mcpp build` itself"); the token is an entry in that page's table, which
    # is to say a machine interface this index may read, rather than a
    # sentence that may be rewritten.
    #
    # THE BRACKETS ARE PART OF THE MATCH AND NOT DECORATION. Read as a bare
    # word, `interface-not-provided` is a hyphenated phrase an ordinary
    # compile error could contain --- a member whose own diagnostic quoted a
    # manifest key, or an upstream error message using the same words, would
    # be recorded as correctly refused when it had simply failed. Requiring
    # the brackets is what distinguishes "the graph answered this member's
    # declared requirement" from "the output happened to say so".
    #
    # No member carries this status today: `requires-interfaces` reaches the
    # index with mcpp 2026.9.20.1 and no third-party descriptor states it yet.
    # The path is here rather than added later because the figure it changes is
    # the one this file publishes, and a member that starts declaring its
    # requirements should not have to wait for this file to catch up.
    if "[interface-not-provided]" in out:
        return {"status": "refused", "diagnostic": first_diagnostic(out)}
    return {"status": "fails", "diagnostic": first_diagnostic(out)}



def cmd_run(args: argparse.Namespace) -> int:
    pins = load_toml(os.path.join(HERE, "pins.toml"))
    members_file = load_toml(os.path.join(HERE, "members.toml"))
    members = args.member or list(members_file.get("members", {}).keys())
    targets = args.target or pins.get("targets", [host_triple()])
    results = {
        "schema": 1,
        "measured": _dt.date.today().isoformat(),
        "pins": {k: v for k, v in pins.items() if k in ("runtime", "toolchain", "mcpp")},
        "members": {},
        "excluded": members_file.get("excluded", {}),
        # CARRIED INTO THE RESULTS so the consumer that computes the figure
        # can take these cells out of the denominator, and so a reader of the
        # results file can see WHY without opening another file.
        "not_portable": members_file.get("not-portable", {}),
    }
    not_portable = members_file.get("not-portable", {})
    for member in members:
        manifest = load_toml(os.path.join(EXAMPLES, member, "mcpp.toml"))
        entry = {"packages": packages_of(manifest),
                 "portable": not platform_bound(manifest),
                 "targets": {}}
        for target in targets:
            print(f"== {member} on {target}", flush=True)
            try:
                entry["targets"][target] = measure(member, target, pins)
            except subprocess.TimeoutExpired:
                entry["targets"][target] = {"status": "fails", "diagnostic": "timed out"}
            kind = kind_of(manifest, entry["targets"][target]["status"])
            if kind:
                entry["targets"][target]["kind"] = kind
            # MEASURED ANYWAY. Skipping the build would make the declaration
            # unfalsifiable, and the cost is a cell that was going to be
            # measured before it was declared.
            why = declared_not_portable(not_portable, member, target)
            if why:
                entry["targets"][target]["declared"] = "not-portable"
                entry["targets"][target]["declared_reason"] = why
            print(f"   {entry['targets'][target]['status']}"
                  + (f" ({kind})" if kind else "")
                  + (f": {entry['targets'][target].get('diagnostic', '')}"
                     if entry['targets'][target]['status'] == 'fails' else ""), flush=True)
        results["members"][member] = entry
    with open(args.out, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, sort_keys=True)
        f.write("\n")
    shutil.rmtree(WORK, ignore_errors=True)
    return 0


def cmd_check(args: argparse.Namespace) -> int:
    current = json.load(open(args.results, encoding="utf-8"))
    baseline = json.load(open(args.baseline, encoding="utf-8"))
    regressions = []
    for member, entry in baseline.get("members", {}).items():
        if args.members and member not in args.members:
            continue
        now = current.get("members", {}).get(member)
        for target, rec in entry.get("targets", {}).items():
            was = RANK.get(rec.get("status"), 0)
            if was == 0:
                continue
            got = RANK.get(((now or {}).get("targets", {}).get(target) or {}).get("status"), 0)
            if got < was:
                regressions.append(f"{member} on {target}: {rec['status']} -> "
                                   f"{((now or {}).get('targets', {}).get(target) or {}).get('status', 'absent')}")
    # A DECLARATION THAT NOTHING CAN CONTRADICT IS A PERMANENT EXCUSE.
    # `[not-portable]` takes a cell out of the figure on the strength of a
    # sentence, and the only thing that keeps the sentence honest is failing
    # here when the cell builds. The cell is measured for this reason alone.
    contradicted = []
    decls = load_toml(os.path.join(HERE, "members.toml")).get("not-portable", {})
    for member, targets in decls.items():
        if args.members and member not in args.members:
            continue
        for target in targets:
            rec = ((current.get("members", {}).get(member) or {})
                   .get("targets", {}).get(target) or {})
            if RANK.get(rec.get("status"), 0) > 0:
                contradicted.append(
                    f"{member} on {target}: declared not-portable and "
                    f"recorded {rec.get('status')} -- remove the declaration")
    for line in regressions:
        print(f"regression: {line}")
    for line in contradicted:
        print(f"contradicted declaration: {line}")
    if not regressions and not contradicted:
        print("no published label regressed, and no declaration was contradicted")
    return 1 if (regressions or contradicted) else 0


# A change to any of these changes the graph every member is measured in, or
# the harness that measures it, so it selects every listed member.
FAMILY_PREFIXES = ("pkgs/o/openkal", "pkgs/s/std-freestanding-alloc-kal")
MEMBERS_FILE = "tests/openkal/members.toml"


def members_changed(now: dict, base: dict) -> set[str]:
    """The members whose entry in members.toml differs from the base: added,
    re-described, or with a `[not-portable]` declaration added, changed or
    removed. `[excluded]` selects nothing -- an excluded member is not
    measured -- and a removed member has nothing left to measure."""
    changed = set()
    now_m, base_m = now.get("members", {}), base.get("members", {})
    for m in now_m:
        if m not in base_m or now_m[m] != base_m[m]:
            changed.add(m)
    now_np, base_np = now.get("not-portable", {}), base.get("not-portable", {})
    for m in set(now_np) | set(base_np):
        if now_np.get(m) != base_np.get(m) and m in now_m:
            changed.add(m)
    return changed


def select_members(changed: list[str], listed: list[str], packages: dict,
                   members_now: dict, members_base: dict | None) -> list[str]:
    """What a change can affect, in listed order.

    Every listed member, when the change reaches all of them: an openkal
    family descriptor (the graph), `pins.toml` (the graph's versions),
    `compat.py` or anything else under tests/openkal/ (the harness), or
    members.toml with no base to compare it against.

    Otherwise only the members the change names: a member whose members.toml
    entry changed (`members_changed`), a member whose own test project under
    tests/examples/ changed, and a member whose test project depends on a
    changed descriptor. Adding one member measures that member, not the list.
    """
    chosen: set[str] = set()
    ids = set()
    for p in changed:
        if p.startswith(FAMILY_PREFIXES):
            return list(listed)
        if p == MEMBERS_FILE:
            if members_base is None:
                return list(listed)
            chosen |= members_changed(members_now, members_base)
        elif p.startswith("tests/openkal/"):
            return list(listed)
        elif p.startswith("tests/examples/"):
            chosen.add(p[len("tests/examples/"):].split("/", 1)[0])
        elif p.startswith("pkgs/") and p.endswith(".lua"):
            ids.add(descriptor_id(p))
    for member in listed:
        if ids & set(packages.get(member, [])):
            chosen.add(member)
    return [m for m in listed if m in chosen]


def descriptor_id(path: str) -> str:
    stem = os.path.basename(path)[: -len(".lua")]
    if "." in stem:
        return stem
    try:
        text = open(os.path.join(ROOT, path), encoding="utf-8").read()
        m = re.search(r'namespace\s*=\s*"([^"]+)"', text)
        return f"{m.group(1)}.{stem}" if m else f"mcpplibs.{stem}"
    except OSError:
        return f"mcpplibs.{stem}"


def cmd_select(args: argparse.Namespace) -> int:
    members_now = load_toml(os.path.join(HERE, "members.toml"))
    listed = list(members_now.get("members", {}).keys())
    changed = [p.strip() for p in args.files if p.strip()]
    # The base's members.toml, so that adding a member measures that member.
    # Without --base, or when the base has no such file, a change to it
    # selects every member, which is what it did before --base existed.
    members_base = None
    if args.base:
        proc = subprocess.run(["git", "show", f"{args.base}:{MEMBERS_FILE}"],
                              cwd=ROOT, capture_output=True, text=True)
        if proc.returncode == 0 and tomllib is not None:
            members_base = tomllib.loads(proc.stdout)
    packages = {m: packages_of(load_toml(os.path.join(EXAMPLES, m, "mcpp.toml")))
                for m in listed}
    print(" ".join(select_members(changed, listed, packages, members_now, members_base)))
    return 0


def cmd_selftest(_args: argparse.Namespace) -> int:
    """Exercise `classify_failure`, whose distinctions decide a published
    figure and which no other check reaches.

    Each case is one sentence about the rule, and each would have passed
    before the rule it pins was written the way it is now.
    """
    refusal = (
        "error: package 'x' requires the kernel-abi interface 'openkal.space',\n"
        "       which openkal-windows (14 interfaces) does not provide. "
        "[interface-not-provided]\n")
    # The same words, as prose, with no brackets: an upstream error quoting a
    # manifest key, or a member's own diagnostic naming the condition. Before
    # the brackets were part of the match this was recorded as a correct
    # refusal, which is to say a member that merely failed improved the figure.
    prose = ("error: no member named 'interface_not_provided'\n"
             "note: the interface-not-provided condition is described in "
             "the README\n")
    ran = "   Compiling x v0.1.0\n   Running bin/x\n  test failed\n"

    cases = [
        ("a bracketed token is a refusal",
         classify_failure(refusal, False)["status"], "refused"),
        ("the same token as prose is a failure",
         classify_failure(prose, False)["status"], "fails"),
        ("an ordinary compile error is a failure",
         classify_failure("error: no such file\n", False)["status"], "fails"),
        ("a member that ran and failed its tests still built",
         classify_failure(ran, True)["status"], "builds"),
        ("the same output without a runner is not evidence it built",
         classify_failure(ran, False)["status"], "fails"),
        # `[not-portable]` is per (member, target), and reading it per member
        # would take a working cell out of the figure along with the broken
        # one --- `cmp-module` runs on x86_64-windows-musl.
        ("a declaration is read for the target it names",
         declared_not_portable({"m": {"t1": "why"}}, "m", "t1"), "why"),
        ("and not for a target it does not name",
         declared_not_portable({"m": {"t1": "why"}}, "m", "t2"), None),
        ("nor for another member",
         declared_not_portable({"m": {"t1": "why"}}, "n", "t1"), None),
        # The command is what decides whether `builds` is about the member or
        # about its dependencies. `mcpp build` was the old answer and compiled
        # none of the member; these three pin the new one.
        ("a target with no runner builds the member's own tests",
         command_for("aarch64-macos", "llvm@22.1.8", False, False),
         ["mcpp", "test", "--toolchain", "llvm@22.1.8",
          "--target", "aarch64-macos", "--no-run"]),
        ("a target with a runner runs them",
         command_for("x86_64-windows-musl", "llvm@22.1.8", False, True),
         ["mcpp", "test", "--toolchain", "llvm@22.1.8",
          "--target", "x86_64-windows-musl"]),
        ("the host names no target and runs them",
         command_for("x86_64-linux-gnu", "llvm@22.1.8", True, True),
         ["mcpp", "test", "--toolchain", "llvm@22.1.8"]),
        # A static musl image of the host's own architecture is run as it
        # is; a runner is for what the host cannot execute.
        ("a Linux image of the host's architecture runs without a runner",
         host_executes("x86_64-linux-musl", "x86_64-linux-gnu"), True),
        ("another architecture needs a runner",
         host_executes("aarch64-linux-musl", "x86_64-linux-gnu"), False),
        ("and so does another system",
         host_executes("x86_64-windows-musl", "x86_64-linux-gnu"), False),
    ]

    # `select` decides how much of a pull request's four-hour matrix runs. It
    # used to measure every member for any change under tests/openkal/, which
    # made adding one member cost the whole list.
    listed = ["a", "b", "c"]
    packages = {"a": ["compat.x"], "b": ["compat.y"], "c": []}
    base = {"members": {"a": "A", "b": "B"}}
    now = {"members": {"a": "A", "b": "B", "c": "C"}}
    sel = lambda changed, n=now, b=base: select_members(changed, listed, packages, n, b)
    cases += [
        ("adding a member measures that member",
         sel([MEMBERS_FILE]), ["c"]),
        ("re-describing a member measures it",
         sel([MEMBERS_FILE], {"members": {"a": "A2", "b": "B"}}), ["a"]),
        ("a not-portable declaration measures the member it names",
         sel([MEMBERS_FILE], {"members": base["members"],
                              "not-portable": {"b": {"t": "why"}}}), ["b"]),
        ("an exclusion alone measures nothing",
         sel([MEMBERS_FILE], {"members": base["members"], "excluded": {"z": "why"}}), []),
        ("members.toml with no base measures every member",
         sel([MEMBERS_FILE], now, None), listed),
        ("a pin measures every member",
         sel(["tests/openkal/pins.toml"]), listed),
        ("the harness measures every member",
         sel(["tests/openkal/compat.py"]), listed),
        ("the scheduled run's directory measures every member",
         sel(["tests/openkal/"]), listed),
        ("an openkal family descriptor measures every member",
         sel(["pkgs/o/openkal-musl.lua"]), listed),
        ("a descriptor measures the members that depend on it",
         sel(["pkgs/c/compat.y.lua"]), ["b"]),
        ("a member's test project measures that member",
         sel(["tests/examples/a/tests/t.cpp"]), ["a"]),
        ("an unlisted test project measures nothing",
         sel(["tests/examples/zzz/mcpp.toml"]), []),
    ]
    bad = 0
    for name, got, want in cases:
        ok = got == want
        bad += not ok
        print(f"{'ok  ' if ok else 'FAIL'}  {name}: {got}"
              + ("" if ok else f" (expected {want})"))
    print(f"\n{len(cases) - bad} passed, {bad} failed")
    return 1 if bad else 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    run = sub.add_parser("run")
    run.add_argument("--member", action="append")
    run.add_argument("--target", action="append")
    run.add_argument("--out", required=True)
    check = sub.add_parser("check")
    check.add_argument("--results", required=True)
    check.add_argument("--baseline", required=True)
    check.add_argument("--members", nargs="*")
    select = sub.add_parser("select")
    select.add_argument("--base", help="git ref whose members.toml the change is compared with")
    select.add_argument("files", nargs="*")
    sub.add_parser("selftest")
    args = parser.parse_args()
    return {"run": cmd_run, "check": cmd_check, "select": cmd_select,
            "selftest": cmd_selftest}[args.command](args)


if __name__ == "__main__":
    sys.exit(main())
