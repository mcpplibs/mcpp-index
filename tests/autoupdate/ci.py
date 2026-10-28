#!/usr/bin/env python3
"""Real updater integration: full declaration coverage and candidate consumers."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tomllib
from pathlib import Path

from xpkgindex_update.manifest import inventory, version_blocks

ROOT = Path(__file__).resolve().parents[2]


def base_descriptors(base: str) -> set[str]:
    files = subprocess.check_output(
        ["git", "ls-tree", "-r", "--name-only", base, "--", "pkgs"], cwd=ROOT, text=True)
    return {name for name in files.splitlines() if name.endswith(".lua")}


def immutable_commit_snapshot(info: dict) -> bool:
    """Commit archives have no release-version substitution to automate."""
    urls = []
    for platform in info["platforms"].values():
        for value in platform["entries"].values():
            if value.kind != "table":
                return False
            entry = value.table()
            if "ref" in entry:
                continue
            # Inspect only the URL: revision/floor are valid numeric Lua
            # fields that the updater's general plain() conversion rejects.
            url = entry.get("url")
            if url is not None and url.kind == "table":
                url = url.table().get("GLOBAL")
            if url is None or url.kind != "string":
                return False
            urls.append(url.string())
    return bool(urls) and all(re.fullmatch(
        r"https://github\.com/[^/]+/[^/]+/archive/[0-9a-fA-F]{40}(?:[0-9a-fA-F]{24})?\.(?:tar\.gz|zip)",
        url) for url in urls)


def audit(base: str, output: Path):
    records = []
    manual = []
    previous = base_descriptors(base)
    infos = inventory(ROOT)
    removed = previous - {info["path"] for info in infos}
    if removed:
        raise RuntimeError(f"existing descriptors removed: {sorted(removed)}")
    for info in infos:
        if info["path"] in previous:
            before = subprocess.check_output(["git", "show", f"{base}:{info['path']}"], cwd=ROOT).decode()
            # `revision` exists to replace a payload under an unchanged
            # version, so it must be allowed to change that version block.
            # Applying the updater's byte-for-byte append-only guard here would
            # reject every packaging fix; audit the invariants this workflow
            # owns instead.
            old = version_blocks(before)
            new = version_blocks(info["text"])
            for plat, entries in old.items():
                if not set(entries) <= set(new.get(plat, {})):
                    raise RuntimeError(f"existing version removed: {info['id']} {plat}")
                if list(entries) != [key for key in new[plat] if key in entries]:
                    raise RuntimeError(f"existing version order changed: {info['id']} {plat}")
                for version in entries:
                    old_entry = old[plat][version]
                    new_entry = new[plat][version]
                    old_revision = _literal_field(old_entry, "revision")
                    new_revision = _literal_field(new_entry, "revision")
                    if old_entry == new_entry:
                        continue
                    if old_revision is None:
                        revision_advanced = new_revision is not None
                    else:
                        revision_advanced = (new_revision is not None
                                             and new_revision > old_revision)
                    if not revision_advanced:
                        if old_revision is not None and new_revision is not None:
                            raise RuntimeError(
                                f"existing version revision decreased: "
                                f"{info['id']} {plat}/{version}")
                        raise RuntimeError(
                            f"existing version changed without a revision bump: "
                            f"{info['id']} {plat}/{version}")
        if info["direct"]:
            if info["autoupdate"] is None:
                if immutable_commit_snapshot(info):
                    manual.append({"id": info["id"], "path": info["path"],
                                   "reason": "immutable commit archive; update requires a reviewed source revision"})
                    continue
                raise RuntimeError(f"missing autoupdate: {info['id']}")
            records.append({k: info[k] for k in ("id", "path", "direct", "autoupdate")})
    output.write_text(json.dumps({"covered": len(records), "packages": records, "manual": manual}, indent=2))
    print(f"All {len(records)} updateable GitHub-direct descriptors declared; "
          f"{len(manual)} immutable snapshots require manual updates; all existing versions preserved.")


def _literal_field(source: str, name: str) -> int | None:
    """Read one integer from a literal version block without executing Lua."""
    match = re.search(rf"(?m)^\s*{re.escape(name)}\s*=\s*(\d+)\s*,?\s*$", source)
    return int(match.group(1)) if match else None


def selection(base: str, output: Path):
    changed = subprocess.check_output(["git", "diff", "--name-only", base, "HEAD", "--", "pkgs"], cwd=ROOT, text=True).splitlines()
    selected = [info["id"] for info in inventory(ROOT) if info["path"] in changed and info["autoupdate"]]
    output.write_text(selected[0] if len(selected) == 1 else "")


def names_platform(value, namespace: str, name: str) -> bool:
    """Whether a mcpp SPEC-013 platform reference (`"<name>@<version>"` or a
    table naming `name`) names the package."""
    spelled = value.split("@", 1)[0] if isinstance(value, str) else (
        value.get("name") if isinstance(value, dict) else None)
    return isinstance(spelled, str) and spelled in (name, f"{namespace}.{name}")


def platform_conditions(manifest: dict, namespace: str, name: str):
    """The `[target.<condition>]` tables (and `[host]`, condition None) whose
    `platform` names the package."""
    for condition, table in manifest.get("target", {}).items():
        if isinstance(table, dict) and names_platform(table.get("platform"), namespace, name):
            yield condition
    if names_platform(manifest.get("host", {}).get("platform"), namespace, name):
        yield None


def direct_member(identity: str) -> str | None:
    namespace, name = identity.split(":", 1)
    candidates = []
    def dependency_tables(table):
        for key, value in table.items():
            if not isinstance(value, dict):
                continue
            if key in {"dependencies", "build-dependencies"}:
                yield value
            else:
                yield from dependency_tables(value)
    for category in ("examples", "mwrap"):
        for path in (ROOT / "tests" / category).glob("*/mcpp.toml"):
            manifest = tomllib.loads(path.read_text(encoding="utf-8"))
            if any(True for _ in platform_conditions(manifest, namespace, name)):
                candidates.append((category, path.parent.name))
                continue
            for deps in dependency_tables(manifest):
                nested = deps
                for part in namespace.split("."):
                    nested = nested.get(part, {}) if isinstance(nested, dict) else {}
                if (f"{namespace}.{name}" in deps or name in deps.get(namespace, {}) or name in nested):
                    candidates.append((category, path.parent.name))
                    break
    if not candidates:
        return None
    # A wrapper's dedicated consumer covers its current declared platforms;
    # old examples may intentionally be gated to just one OS or feature.
    return min(candidates, key=lambda value: (value[0] != "mwrap", len(value[1]), value[1]))[1]


def member_manifest(member: str) -> Path:
    for category in ("mwrap", "examples"):
        path = ROOT / "tests" / category / member / "mcpp.toml"
        if path.is_file():
            return path
    raise FileNotFoundError(f"consumer manifest not found: {member}")


def names_dependency(deps: dict, namespace: str, name: str) -> bool:
    nested = deps
    for part in namespace.split("."):
        nested = nested.get(part, {}) if isinstance(nested, dict) else {}
    return (f"{namespace}.{name}" in deps
            or name in deps.get(namespace, {}) or name in nested)


# The runner platforms, by the spelling a member's `cfg(os = ...)` uses.
_CFG_PLATFORMS = {"linux": "linux", "macos": "macosx", "windows": "windows"}


def member_platforms(member: str, identity: str) -> set[str]:
    """The runner platforms on which `member` builds `identity`.

    A member that names the package unconditionally builds it everywhere. One
    that names it under `[target.'cfg(...)']` builds it only where the condition
    holds, and a lockfile proves a candidate only where it was built: mcpp locks
    what the host resolves, so a platform package asked of another platform's
    runner is a job that can only fail. A condition naming one operating system
    (`os = "linux"`, `os = "macos"`, `windows`) selects that runner; any other
    condition (an environment, an architecture, a family) selects none, because
    no runner here builds for it and the package is measured by its own
    repository on that target.
    """
    namespace, name = identity.split(":", 1)
    manifest = tomllib.loads(member_manifest(member).read_text(encoding="utf-8"))
    platforms: set[str] = set()
    if any(names_dependency(manifest.get(key, {}), namespace, name)
           for key in ("dependencies", "build-dependencies")):
        platforms |= set(_CFG_PLATFORMS.values())
    for condition, table in manifest.get("target", {}).items():
        if not any(names_dependency(table.get(key, {}), namespace, name)
                   for key in ("dependencies", "build-dependencies")):
            continue
        platforms |= condition_platforms(condition)
    # A platform the member selects (mcpp SPEC-013): under `[host]` on every
    # runner, under `[target.<condition>]` where the condition names a system.
    for condition in platform_conditions(manifest, namespace, name):
        platforms |= set(_CFG_PLATFORMS.values()) if condition is None else condition_platforms(condition)
    platforms.discard("")
    return platforms


def condition_platforms(condition: str) -> set[str]:
    """The runner platforms a `cfg(...)` naming operating systems selects:
    `os = "linux"`, `windows`, or `any(...)` of those; any other condition
    selects none."""
    text = condition.strip()
    inner = re.fullmatch(r'cfg\(\s*any\(\s*(.*?)\s*\)\s*\)', text)
    parts = [p.strip() for p in inner.group(1).split(",")] if inner else [text[4:-1].strip()] if text.startswith("cfg(") and text.endswith(")") else []
    out: set[str] = set()
    for part in parts:
        spelled = re.fullmatch(r'(?:os\s*=\s*"(\w+)"|(windows|linux|macos))', part)
        if not spelled:
            return set()
        out.add(_CFG_PLATFORMS.get(spelled.group(1) or spelled.group(2), ""))
    return out


def matrix(plan: Path, output: Path, base: str):
    build_plan = json.loads(plan.read_text(encoding="utf-8"))
    # A normal bump PR already contains its candidate, so discovery says up-to-date.
    # Derive added versions from the actual diff and test those exact published entries.
    if base:
        previous = base_descriptors(base)
        for info in inventory(ROOT):
            if info["path"] not in previous:
                continue  # New descriptors are covered by ordinary consumer validation.
            old_text = subprocess.check_output(["git", "show", f"{base}:{info['path']}"], cwd=ROOT).decode()
            old = version_blocks(old_text)
            new = version_blocks(info["text"])
            added = {v for plat, entries in new.items() for v in entries if v not in old.get(plat, {})}
            if not added:
                continue
            if len(added) != 1:
                raise RuntimeError(f"expected one added candidate for {info['id']}: {added}")
            candidate = added.pop()
            assets = []
            for plat, platform in info["platforms"].items():
                if candidate not in platform["entries"]:
                    raise RuntimeError("candidate missing on a platform")
                entry = platform["entries"][candidate].plain()
                urls = entry["url"] if isinstance(entry["url"], dict) else {"GLOBAL": entry["url"]}
                assets.append({"platform": plat, "resources": {k: {"url": v, "sha256": entry["sha256"]} for k, v in urls.items()}})
            build_plan["packages"] = [r for r in build_plan["packages"] if r["id"] != info["id"]]
            build_plan["packages"].append({"id": info["id"], "path": info["path"],
                                           "candidate": candidate, "status": "existing-candidate", "assets": assets})
    # Packages released as one archive (one tag, several manifests reaching
    # each other by path) are built together: a member of one builds the
    # others from the same bytes, so the job of a sibling that has a member
    # proves a package that none names directly.
    def archive_of(record):
        return frozenset(r["url"] for asset in record.get("assets", []) for r in asset["resources"].values())
    candidates = [r for r in build_plan["packages"] if r["status"] in ("update-ready", "existing-candidate")]
    jobs = []
    for record in candidates:
        member = direct_member(record["id"])
        if member is None and record["id"] not in ("compat:hiredis", "compat:libuv"):
            sibling = next((r["id"] for r in candidates
                            if r is not record and archive_of(r) and archive_of(r) == archive_of(record)
                            and direct_member(r["id"])), None)
            if sibling is None:
                raise RuntimeError(f"no candidate consumer: {record['id']}")
            print(f"{record['id']}: built from the same archive by the job of {sibling}")
            continue
        applicable = member_platforms(member, record["id"]) if member else None
        if applicable is not None and not applicable:
            print(f"{record['id']}: {member} names it only for a target no runner builds; "
                  "measured by its own repository on that target")
        for platform in [asset["platform"] for asset in record["assets"]]:
            if applicable is not None and platform not in applicable:
                continue
            rows = {
                "linux": ("ubuntu-latest", "linux-x86_64", "tar.gz"),
                "macosx": ("macos-15", "macosx-arm64", "tar.gz"),
                "windows": ("windows-2022", "windows-x86_64", "zip"),
            }
            runner, suffix, ext = rows[platform]
            for toolchain in (["default", "llvm"] if platform == "linux" else ["default"]):
                jobs.append({"id": record["id"], "candidate": record["candidate"],
                             "member": member or "probe", "platform": platform,
                             "os": runner, "suffix": suffix, "ext": ext, "toolchain": toolchain})
    output.write_text(json.dumps({"include": jobs}))
    output.with_name("build-plan.json").write_text(json.dumps(build_plan, indent=2))
    print(f"Candidate matrix: {len(jobs)} real build/run jobs.")


def prepare(plan: Path, identity: str, output: Path, home: Path | None = None):
    record = next(r for r in json.loads(plan.read_text(encoding="utf-8"))["packages"] if r["id"] == identity)
    namespace, name = identity.split(":", 1)
    version = record["candidate"]
    member = direct_member(identity)
    output.mkdir(parents=True, exist_ok=True)
    if member:
        source = member_manifest(member).parent
        shutil.copytree(source, output, dirs_exist_ok=True,
                        ignore=shutil.ignore_patterns("target", ".mcpp", "mcpp.lock"))
        text = (output / "mcpp.toml").read_text(encoding="utf-8")
        text, replacements = re.subn(
            rf'(?m)^(\s*(?:{re.escape(name)}|"{re.escape(namespace)}\.{re.escape(name)}")\s*=\s*(?:\{{\s*version\s*=\s*)?")[^"]+(".*)$',
            lambda m: m[1] + version + m[2], text)
        if not replacements:
            raise RuntimeError("candidate dependency was not replaced")
        # Standalone consumer: no inherited workspace or stale relative index redirects.
        text = re.sub(r'(?ms)^\[indices(?:\.[^\]]+)?\]\s*\n.*?(?=^\[|\Z)', '', text)
    else:
        text = f'[package]\nname = "candidate-{name}"\nversion = "0.1.0"\n\n[dependencies.{namespace}]\n{name} = "{version}"\n'
        (output / "tests").mkdir(exist_ok=True)
        probes = {
            "hiredis": '#include <hiredis.h>\nint main() { auto *r = redisReaderCreate(); if (!r) return 1; redisReaderFree(r); }\n',
            "libuv": '#include <uv.h>\nint main() { uv_loop_t loop; if (uv_loop_init(&loop)) return 1; return uv_loop_close(&loop); }\n',
        }
        (output / "tests/probe.cpp").write_text(probes[name])
    if name == "nanodbc":
        # The existing Linux-only diagnostic test cannot prove non-Linux candidate resolution.
        text = f'[package]\nname = "candidate-nanodbc"\nversion = "0.1.0"\n\n[dependencies.compat]\nnanodbc = "{version}"\n'
        for path in (output / "tests").glob("*.cpp"):
            path.unlink()
        (output / "tests/connection.cpp").write_text(
            '#include <nanodbc/nanodbc.h>\nint main() { nanodbc::connection c; return c.connected() ? 1 : 0; }\n')
    if identity == "yizhinailong:mcr":
        parts = version.split(".")
        if len(parts) != 3 or not all(part.isdecimal() for part in parts):
            raise RuntimeError("mcr version assertions require three numeric parts")
        api = output / "tests/api.cpp"
        defines = f'#define MCR_EXPECT_VERSION "{version}"\n'
        defines += ''.join(f'#define MCR_EXPECT_{key} {int(value)}\n'
                           for key, value in zip(("MAJOR", "MINOR", "PATCH"), parts))
        api.write_text(defines + api.read_text(encoding="utf-8"), encoding="utf-8")
    if home is None:
        text += f'\n[indices]\n"{namespace}" = {{ path = {json.dumps(str(ROOT).replace(chr(92), "/"))} }}\n'
    else:
        # Coupled tool/runtime packages cross namespaces. One complete built-in
        # index resolves all of them without project-alias cache collisions.
        sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
        from prepare_builtin_index import prepare as prepare_index
        prepare_index(ROOT, home)
    (output / "mcpp.toml").write_text(text)
    print(f"Prepared {identity}@{version} in {output}")


def verify(plan: Path, identity: str, consumer: Path):
    record = next(r for r in json.loads(plan.read_text(encoding="utf-8"))["packages"] if r["id"] == identity)
    namespace, name = identity.split(":", 1)
    lock = tomllib.loads((consumer / "mcpp.lock").read_text(encoding="utf-8"))
    matches = [value for key, value in lock.get("package", {}).items()
               if value.get("namespace") == namespace and key in (name, identity, f"{namespace}.{name}")]
    if not matches or any(v["version"] != record["candidate"] for v in matches):
        raise RuntimeError(f"lockfile does not prove {identity}@{record['candidate']}: {matches}")
    print(f"PROVEN: build resolved {identity}@{record['candidate']}")


def diagnostics(consumer: Path, output: Path):
    output.mkdir(parents=True, exist_ok=True)
    for directory, dirs, files in os.walk(consumer):
        dirs[:] = [name for name in dirs if name not in (".xlings", ".git")]
        for name in files:
            if name in ("compile_commands.json", "build.ninja") or name.endswith(".rsp"):
                path = Path(directory) / name
                if path.stat().st_size <= 8 * 1024 * 1024:
                    destination = output / path.relative_to(consumer)
                    destination.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copyfile(path, destination)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("audit", "matrix", "prepare", "verify", "selection", "diagnostics"))
    parser.add_argument("--base")
    parser.add_argument("--plan", type=Path)
    parser.add_argument("--package")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--consumer", type=Path)
    parser.add_argument("--home", type=Path)
    args = parser.parse_args()
    if args.command == "audit":
        audit(args.base, args.output)
    elif args.command == "selection":
        selection(args.base, args.output)
    elif args.command == "matrix":
        matrix(args.plan, args.output, args.base)
    elif args.command == "prepare":
        prepare(args.plan, args.package, args.output, args.home)
    elif args.command == "diagnostics":
        diagnostics(args.consumer, args.output)
    else:
        verify(args.plan, args.package, args.consumer)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, OSError, ValueError) as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(1)
