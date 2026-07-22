#!/usr/bin/env python3
"""Select workspace members affected by one package descriptor change."""
from __future__ import annotations

import argparse
import tomllib
from pathlib import Path
from typing import Mapping


DESCRIPTOR_COHORTS = {
    "compat.ggml-base.lua": {
        "llamacpp-internal-cpu", "llamacpp-internal-metal",
    },
    "compat.ggml-cpu.lua": {
        "llamacpp-internal-cpu", "llamacpp-internal-metal",
    },
    "compat.llamacpp.lua": {
        "llamacpp-internal-cpu", "llamacpp-internal-metal",
    },
    "compat.ggml-metal.lua": {
        "llamacpp-internal-metal",
    },
    "compat.ffmpeg.lua": {
        "opencv", "opencv-dnn", "opencv-unifont",
    },
    "compat.opencv-unifont.lua": {
        "opencv-unifont", "opencv-module-unifont",
    },
}


def cohort_members(descriptor_path: str | Path) -> set[str]:
    return set(DESCRIPTOR_COHORTS.get(Path(descriptor_path).name, set()))


def _dependency_names(value: object) -> set[str]:
    names: set[str] = set()
    if not isinstance(value, dict):
        return names
    for key, child in value.items():
        if key == "dependencies" and isinstance(child, dict):
            for dependency, declaration in child.items():
                names.add(dependency)
                if isinstance(declaration, dict) and "version" not in declaration:
                    for package in declaration:
                        names.add(package)
                        names.add(f"{dependency}.{package}")
        names.update(_dependency_names(child))
    return names


def select_descriptor_members(
    descriptor_path: str | Path,
    manifests: Mapping[str, str],
) -> set[str]:
    package_name = Path(descriptor_path).stem.removeprefix("compat.")
    selected = cohort_members(descriptor_path)
    for member, text in manifests.items():
        parsed = tomllib.loads(text)
        if package_name in _dependency_names(parsed):
            selected.add(member)
    return selected


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("descriptor")
    parser.add_argument("manifests", nargs="+")
    args = parser.parse_args()
    manifests = {
        path.parent.name: path.read_text()
        for raw in args.manifests
        if (path := Path(raw)).is_file()
    }
    for member in sorted(select_descriptor_members(args.descriptor, manifests)):
        print(member)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
