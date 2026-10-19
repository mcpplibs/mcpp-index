#!/usr/bin/env python3
"""Real updater integration: full declaration coverage and candidate consumers."""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import tomllib
from pathlib import Path

from xpkgindex_update.manifest import assert_preserved, inventory, version_blocks

ROOT = Path(__file__).resolve().parents[2]


def audit(base: str, output: Path):
    records = []
    for info in inventory(ROOT):
        before = subprocess.check_output(["git", "show", f"{base}:{info['path']}"], cwd=ROOT).decode()
        assert_preserved(before, info["text"])
        if info["direct"]:
            if info["autoupdate"] is None:
                raise RuntimeError(f"missing autoupdate: {info['id']}")
            records.append({k: info[k] for k in ("id", "path", "direct", "autoupdate")})
    output.write_text(json.dumps({"covered": len(records), "packages": records}, indent=2))
    print(f"All {len(records)} GitHub-direct descriptors declared; all existing versions unchanged.")


def selection(base: str, output: Path):
    changed = subprocess.check_output(["git", "diff", "--name-only", base, "HEAD", "--", "pkgs"], cwd=ROOT, text=True).splitlines()
    selected = [info["id"] for info in inventory(ROOT) if info["path"] in changed and info["autoupdate"]]
    output.write_text(selected[0] if len(selected) == 1 else "")


def direct_member(identity: str) -> str | None:
    namespace, name = identity.split(":", 1)
    candidates = []
    for path in (ROOT / "tests/examples").glob("*/mcpp.toml"):
        text = path.read_text()
        # Metadata-only selection; prepare() and the lock assertion verify actual resolution.
        if re.search(rf"(?m)^\s*{re.escape(name)}\s*=", text) and (
            f"dependencies.{namespace}]" in text or f"dependencies.{namespace}." in text
        ):
            candidates.append(path.parent.name)
    if not candidates:
        return None
    return min(candidates, key=lambda value: (len(value), value))


def matrix(plan: Path, output: Path, base: str):
    build_plan = json.loads(plan.read_text())
    # A normal bump PR already contains its candidate, so discovery says up-to-date.
    # Derive added versions from the actual diff and test those exact published entries.
    if base:
        for info in inventory(ROOT):
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
                "macosx": ("macos-latest", "macos-arm64", "tar.gz"),
                "windows": ("windows-latest", "windows-x86_64", "zip"),
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
    record = next(r for r in json.loads(plan.read_text())["packages"] if r["id"] == identity)
    namespace, name = identity.split(":", 1)
    version = record["candidate"]
    member = direct_member(identity)
    output.mkdir(parents=True, exist_ok=True)
    if member:
        source = ROOT / "tests/examples" / member
        shutil.copytree(source, output, dirs_exist_ok=True,
                        ignore=shutil.ignore_patterns("target", ".mcpp", "mcpp.lock"))
        text = (output / "mcpp.toml").read_text()
        text, replacements = re.subn(
            rf'(?m)^(\s*{re.escape(name)}\s*=\s*(?:\{{\s*version\s*=\s*)?")[^"]+(".*)$',
            lambda m: m[1] + version + m[2], text)
        if not replacements:
            raise RuntimeError("candidate dependency was not replaced")
        # Standalone consumer: no inherited workspace or stale relative index redirects.
        text = re.sub(r'(?ms)^\[indices(?:\.[^\]]+)?\]\s*\n.*?(?=^\[|\Z)', '', text)
    else:
        text = f'[package]\nname = "candidate-{name}"\nversion = "0.1.0"\n\n[dependencies.{namespace}]\n{name} = "{version}"\n'
        (output / "tests").mkdir(exist_ok=True)
        probes = {
            "hiredis": '#include <read.h>\nint main() { auto *r = redisReaderCreate(); if (!r) return 1; redisReaderFree(r); }\n',
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
    text += f'\n[indices]\n"{namespace}" = {{ path = {json.dumps(str(ROOT).replace(chr(92), "/"))} }}\n'
    (output / "mcpp.toml").write_text(text)
    print(f"Prepared {identity}@{version} in {output}")


def verify(plan: Path, identity: str, consumer: Path):
    record = next(r for r in json.loads(plan.read_text())["packages"] if r["id"] == identity)
    namespace, name = identity.split(":", 1)
    lock = tomllib.loads((consumer / "mcpp.lock").read_text())
    matches = [value for key, value in lock.get("package", {}).items()
               if value.get("namespace") == namespace and key in (name, identity, f"{namespace}.{name}")]
    if not matches or any(v["version"] != record["candidate"] for v in matches):
        raise RuntimeError(f"lockfile does not prove {identity}@{record['candidate']}: {matches}")
    print(f"PROVEN: build resolved {identity}@{record['candidate']}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("audit", "matrix", "prepare", "verify", "selection"))
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
    else:
        verify(args.plan, args.package, args.consumer)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, OSError, ValueError) as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(1)
