#!/usr/bin/env python3
"""Exercise real Lua plans when toolchain legs advertise different counts."""
from collections import Counter
import tomllib
from pathlib import Path
import unittest

from plan_matrix_shards import plan_matrix, select_shard


class MatrixShardCoverage(unittest.TestCase):
    def test_different_linux_counts_cover_each_selected_member_once(self):
        members = ["opencv-module", "opencv-module-dnn", "opencv-cpu",
                   "onnxruntime-cpu", "opencv-webp", "grpc-cpu"]
        matrix = {"include": [
            {"platform": "linux", "toolchain": "default", "shards": 2},
            {"platform": "linux", "toolchain": "llvm", "shards": 3},
            {"platform": "macos", "toolchain": "default", "shards": 1},
        ]}
        plans = plan_matrix(matrix, members)
        self.assertEqual(set(plans), {"linux:2", "linux:3", "macos:1"})
        for entry in matrix["include"]:
            split = plans[f"{entry['platform']}:{entry['shards']}"]
            self.assertEqual(set(split), {str(i) for i in range(entry["shards"])})
            assigned = [member for i in range(entry["shards"])
                        for member in select_shard(plans, entry["platform"], entry["shards"], i).split()]
            self.assertEqual(Counter(assigned), Counter(members))
            self.assertTrue(all(split.values()))

    def test_full_workspace_keeps_both_member_categories(self):
        root = Path(__file__).resolve().parents[1]
        manifest = tomllib.loads((root / "mcpp.toml").read_text())
        expected = [Path(member).name for member in manifest["workspace"]["members"]]
        matrix = {"include": [{"platform": "linux", "shards": 5}]}
        split = plan_matrix(matrix, [])["linux:5"]
        assigned = [member for shard in split.values() for member in shard.split()]
        self.assertEqual(Counter(assigned), Counter(expected))
        self.assertIn("opencv-cpu", assigned)
        self.assertIn("opencv-module", assigned)

    def test_missing_or_partial_split_fails_instead_of_reporting_empty_success(self):
        with self.assertRaises(ValueError):
            select_shard({"linux:2": {"0": "opencv-cpu", "1": "grpc-cpu"}}, "linux", 3, 0)
        with self.assertRaises(ValueError):
            select_shard({"linux:3": {"0": "opencv-cpu", "1": "grpc-cpu"}}, "linux", 3, 0)


if __name__ == "__main__":
    unittest.main()
