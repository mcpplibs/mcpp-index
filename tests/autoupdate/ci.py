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
            entry = value.plain()
            if "ref" in entry:
                continue
            url = entry.get("url")
            if isinstance(url, dict):
                url = url.get("GLOBAL")
            if not isinstance(url, str):
                return False
            urls.append(url)
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


def direct_member(identity: str) -> str | None:
    namespace, name = identity.split(":", 1)
    candidates = []
    for category in ("examples", "mwrap"):
        for path in (ROOT / "tests" / category).glob("*/mcpp.toml"):
            deps = tomllib.loads(path.read_text(encoding="utf-8")).get("dependencies", {})
            nested = deps
            for part in namespace.split("."):
                nested = nested.get(part, {}) if isinstance(nested, dict) else {}
            if (f"{namespace}.{name}" in deps or name in deps.get(namespace, {}) or name in nested):
                candidates.append(path.parent.name)
    if not candidates:
        return None
    return min(candidates, key=lambda value: (len(value), value))


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
    jobs = []
    for record in build_plan["packages"]:
        if record["status"] not in ("update-ready", "existing-candidate"):
            continue
        member = direct_member(record["id"])
        if member is None and record["id"] not in ("compat:hiredis", "compat:libuv"):
            raise RuntimeError(f"no candidate consumer: {record['id']}")
        for platform in [asset["platform"] for asset in record["assets"]]:
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


def prepare(plan: Path, identity: str, output: Path):
    record = next(r for r in json.loads(plan.read_text(encoding="utf-8"))["packages"] if r["id"] == identity)
    namespace, name = identity.split(":", 1)
    version = record["candidate"]
    member = direct_member(identity)
    output.mkdir(parents=True, exist_ok=True)
    if member:
        paths = [ROOT / "tests" / category / member for category in ("examples", "mwrap")]
        source = next(path for path in paths if (path / "mcpp.toml").is_file())
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
    text += f'\n[indices]\n"{namespace}" = {{ path = {json.dumps(str(ROOT).replace(chr(92), "/"))} }}\n'
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
    args = parser.parse_args()
    if args.command == "audit":
        audit(args.base, args.output)
    elif args.command == "selection":
        selection(args.base, args.output)
    elif args.command == "matrix":
        matrix(args.plan, args.output, args.base)
    elif args.command == "prepare":
        prepare(args.plan, args.package, args.output)
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
