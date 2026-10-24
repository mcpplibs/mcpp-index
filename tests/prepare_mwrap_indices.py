#!/usr/bin/env python3
"""Create test-only namespace views without changing the published index layout.

The pinned client routes descriptors by namespace, while xlings rejects two
project aliases of one physical full index as ambiguous. Each view contains
unchanged descriptor bytes for just its namespace. Normal published consumers
use one complete built-in index instead.
"""
import hashlib
import json
from pathlib import Path
import re
import shutil


def main():
    root = Path(__file__).resolve().parents[1]
    namespaces = {name: [] for name in ("compat", "mcpplibs.mwrap", "grpc", "mcpplibs")}
    for source in sorted((root / "pkgs").glob("*/*.lua")):
        match = re.search(r'^\s*namespace\s*=\s*[\'"]([^\'"]+)[\'"]', source.read_text(encoding="utf-8"), re.M)
        if match and match[1] in namespaces:
            namespaces[match[1]].append(source)
    for namespace, sources in namespaces.items():
        view = root / "tests/mwrap/.indices" / namespace
        payload = view / "pkgs/view"
        payload.mkdir(parents=True, exist_ok=True)
        expected = {source.name for source in sources}
        for stale in payload.glob("*.lua"):
            if stale.name not in expected:
                stale.unlink()
        provenance = {}
        for source in sources:
            dest = payload / source.name
            shutil.copyfile(source, dest)
            digest = hashlib.sha256(source.read_bytes()).hexdigest()
            assert hashlib.sha256(dest.read_bytes()).hexdigest() == digest
            provenance[source.relative_to(root).as_posix()] = digest
        shutil.copyfile(root / "index.toml", view / "index.toml")
        (view / "source-manifest.json").write_text(json.dumps(provenance, indent=2) + "\n")
        print(f"Test view {namespace}: {len(sources)} unchanged descriptors")


if __name__ == "__main__":
    main()
