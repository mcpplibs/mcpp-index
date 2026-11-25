#!/usr/bin/env python3
"""Compute each distinct platform/count split advertised by the CI matrix."""
import json
from pathlib import Path
import subprocess
import sys


def plan_matrix(matrix, members):
    root = Path(__file__).resolve().parents[1]
    result = {}
    for entry in matrix["include"]:
        platform, count = entry["platform"], entry["shards"]
        if not isinstance(count, int) or count < 1:
            raise ValueError(f"Invalid shard count: {count}")
        key = f"{platform}:{count}"
        if key in result:
            continue
        result[key] = {
            str(index): subprocess.check_output(
                ["lua5.4", "tests/plan_shards.lua", platform, str(index), str(count), *members],
                cwd=root, text=True,
            ).strip()
            for index in range(count)
        }
    return result


def select_shard(plans, platform, count, index):
    key = f"{platform}:{count}"
    split = plans.get(key)
    if split is None or set(split) != {str(i) for i in range(count)}:
        raise ValueError(f"Missing or incomplete shard plan for {key}")
    if not 0 <= index < count:
        raise ValueError(f"Shard {index} outside {key}")
    return split[str(index)]


if __name__ == "__main__":
    if sys.argv[1] == "--select":
        platform, count, index = sys.argv[2:]
        print(select_shard(json.load(sys.stdin), platform, int(count), int(index)))
    else:
        matrix = json.loads(Path(sys.argv[1]).read_text())
        members = sys.argv[2:]
        if members == ["__ALL__"]:
            members = []
        print(json.dumps(plan_matrix(matrix, members), sort_keys=True))
