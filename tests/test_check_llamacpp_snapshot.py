"""Mutation tests for the llama.cpp descriptor cohort gate."""
from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path


SCRIPT = Path(__file__).with_name("check_llamacpp_snapshot.py")
SPEC = importlib.util.spec_from_file_location("check_llamacpp_snapshot", SCRIPT)
assert SPEC and SPEC.loader
checker = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(checker)


class TestLlamacppSnapshotMutations(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        lua = checker.find_lua()
        cls.report = json.loads(checker.REPORT_PATH.read_text())
        cls.original = {
            name: checker.load_descriptor(lua, path)
            for name, path in checker.DESCRIPTORS.items()
        }

    def setUp(self):
        self.descriptors = copy.deepcopy(self.original)
        self.tag = self.report["upstream"]["tag"]

    def assert_rejected(self, function, pattern):
        with self.assertRaisesRegex(checker.CheckError, pattern):
            function(self.descriptors, self.report)

    def test_rejects_cn_url_drift(self):
        release = self.descriptors["compat.ggml-base"]["xpm"]["linux"][self.tag]
        release["url"]["CN"] = "https://example.invalid/mutated.tar.gz"
        self.assert_rejected(checker.check_cohort, "URL")

    def test_rejects_missing_required_dependency_edge(self):
        del self.descriptors["compat.ggml-cpu"]["mcpp"]["deps"]["compat.ggml-base"]
        with self.assertRaisesRegex(checker.CheckError, "dependency graph"):
            checker.check_dependencies(self.descriptors, self.tag)

    def test_rejects_extra_dependency_edge(self):
        self.descriptors["compat.llamacpp"]["mcpp"]["deps"]["compat.ggml-metal"] = self.tag
        with self.assertRaisesRegex(checker.CheckError, "dependency graph"):
            checker.check_dependencies(self.descriptors, self.tag)

    def test_rejects_duplicate_tu_within_one_descriptor(self):
        sources = self.descriptors["compat.llamacpp"]["mcpp"]["sources"]
        sources[max(sources) + 1] = "*/ggml/src/ggml-backend-reg.cpp"
        self.assert_rejected(checker.check_sources, "duplicate")

    def test_rejects_backend_metal_on_another_descriptor(self):
        base = self.descriptors["compat.ggml-base"]["mcpp"]
        base.setdefault("features", {})["backend-metal"] = {}
        self.assert_rejected(checker.check_registry_and_features, "backend-metal")

    def test_rejects_llamafile_in_another_package_compile_flags(self):
        flags = self.descriptors["compat.ggml-base"]["mcpp"]["cxxflags"]
        flags[max(flags) + 1] = "-DGGML_USE_LLAMAFILE"
        with self.assertRaisesRegex(checker.CheckError, "GGML_USE_LLAMAFILE"):
            checker.check_cpu_private_macros(self.descriptors)

    def test_rejects_cpu_repack_in_another_package_compile_flags(self):
        flags = self.descriptors["compat.llamacpp"]["mcpp"]["cflags"]
        flags[max(flags) + 1] = "-DGGML_USE_CPU_REPACK"
        with self.assertRaisesRegex(checker.CheckError, "GGML_USE_CPU_REPACK"):
            checker.check_cpu_private_macros(self.descriptors)

    def test_rejects_registry_macro_in_raw_compile_flags(self):
        flags = self.descriptors["compat.ggml-base"]["mcpp"]["cxxflags"]
        flags[max(flags) + 1] = "-DGGML_USE_CPU"
        with self.assertRaisesRegex(checker.CheckError, "GGML_USE_CPU"):
            checker.check_cpu_private_macros(self.descriptors)

    def test_rejects_implementation_macro_in_public_defines(self):
        self.descriptors["compat.ggml-base"]["mcpp"]["public_defines"] = {
            1: "GGML_USE_LLAMAFILE",
        }
        with self.assertRaisesRegex(checker.CheckError, "GGML_USE_LLAMAFILE"):
            checker.check_cpu_private_macros(self.descriptors)


if __name__ == "__main__":
    unittest.main()
