"""Mutation tests for the llama.cpp descriptor cohort gate."""
from __future__ import annotations

import copy
import importlib.util
import json
import subprocess
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

    def test_rejects_dependency_under_arbitrary_feature(self):
        base = self.descriptors["compat.ggml-base"]["mcpp"]
        base.setdefault("features", {})["arbitrary"] = {
            "deps": {"compat.ggml-cpu": self.tag},
        }
        with self.assertRaisesRegex(checker.CheckError, "feature dependency"):
            checker.check_dependencies(self.descriptors, self.tag)

    def test_requires_exact_optional_metal_dependency(self):
        feature = self.descriptors["compat.llamacpp"]["mcpp"]["macosx"]["features"]["backend-metal"]
        del feature["deps"]["compat.ggml-metal"]
        with self.assertRaisesRegex(checker.CheckError, "feature dependency"):
            checker.check_dependencies(self.descriptors, self.tag)

    def test_rejects_duplicate_tu_within_one_descriptor(self):
        sources = self.descriptors["compat.llamacpp"]["mcpp"]["sources"]
        sources[max(sources) + 1] = "*/ggml/src/ggml-backend-reg.cpp"
        self.assert_rejected(checker.check_sources, "duplicate")

    def test_rejects_cpu_translation_unit_parked_in_disabled_feature(self):
        cpu = self.descriptors["compat.ggml-cpu"]["mcpp"]
        sources = cpu["sources"]
        source = "*/ggml/src/ggml-cpu/ops.cpp"
        remaining = [value for _, value in sorted(sources.items()) if value != source]
        sources.clear()
        sources.update(enumerate(remaining, start=1))
        cpu["features"]["parked"] = {"sources": {1: source}}

        with self.assertRaisesRegex(checker.CheckError, r"CPU TU set drift.*ops\.cpp"):
            checker.check_sources(self.descriptors, self.report)

    def test_rejects_cpu_translation_unit_on_default_feature(self):
        cpu = self.descriptors["compat.ggml-cpu"]["mcpp"]
        sources = cpu["sources"]
        source = "*/ggml/src/ggml-cpu/ops.cpp"
        remaining = [value for _, value in sorted(sources.items()) if value != source]
        sources.clear()
        sources.update(enumerate(remaining, start=1))
        cpu["features"]["default"]["sources"] = {1: source}

        with self.assertRaisesRegex(checker.CheckError, r"CPU TU set drift.*ops\.cpp"):
            checker.check_sources(self.descriptors, self.report)

    def test_rejects_cpu_translation_unit_when_default_implies_is_removed(self):
        cpu = self.descriptors["compat.ggml-cpu"]["mcpp"]
        del cpu["features"]["default"]["implies"]

        with self.assertRaisesRegex(
                checker.CheckError, r"CPU TU set drift.*llamafile/sgemm\.cpp"):
            checker.check_sources(self.descriptors, self.report)

    def test_rejects_unknown_default_implied_feature(self):
        cpu = self.descriptors["compat.ggml-cpu"]["mcpp"]
        cpu["features"]["default"]["implies"] = {1: "missing-feature"}

        with self.assertRaisesRegex(
                checker.CheckError, "implies unknown feature: missing-feature"):
            checker.check_sources(self.descriptors, self.report)

    def test_rejects_scalar_default_implies(self):
        cpu = self.descriptors["compat.ggml-cpu"]["mcpp"]
        cpu["features"]["default"]["implies"] = "llamafile"

        with self.assertRaisesRegex(checker.CheckError, "implies must be a Lua array"):
            checker.check_sources(self.descriptors, self.report)

    def test_accepts_platform_sources_appended_to_default_feature(self):
        cpu = self.descriptors["compat.ggml-cpu"]["mcpp"]
        implies = cpu["features"]["default"]["implies"]
        implies[max(implies) + 1] = "arch-default"
        cpu["features"]["arch-default"] = {}
        platform_sources = {
            "linux": "*/ggml/src/ggml-cpu/arch/x86/quants.c",
            "macosx": "*/ggml/src/ggml-cpu/arch/arm/quants.c",
            "windows": "*/ggml/src/ggml-cpu/arch/x86/repack.cpp",
        }
        for platform, source in platform_sources.items():
            sources = cpu[platform]["sources"]
            remaining = [value for _, value in sorted(sources.items()) if value != source]
            sources.clear()
            sources.update(enumerate(remaining, start=1))
            features = cpu[platform].setdefault("features", {})
            features["arch-default"] = {"sources": {1: source}}

        checker.check_sources(self.descriptors, self.report)

    def test_rejects_missing_cpu_translation_units(self):
        mutations = {
            "*/ggml/src/ggml-cpu/ops.cpp": "common",
            "*/ggml/src/ggml-cpu/arch/x86/quants.c": "linux",
            "*/ggml/src/ggml-cpu/arch/arm/quants.c": "macosx",
        }
        for source, scope in mutations.items():
            with self.subTest(source=source, scope=scope):
                self.descriptors = copy.deepcopy(self.original)
                mcpp = self.descriptors["compat.ggml-cpu"]["mcpp"]
                sources = mcpp["sources"] if scope == "common" else mcpp[scope]["sources"]
                key = next(key for key, value in sources.items() if value == source)
                del sources[key]
                remaining = [sources[key] for key in sorted(sources)]
                sources.clear()
                sources.update(enumerate(remaining, start=1))
                with self.assertRaisesRegex(checker.CheckError, "ggml_cpu"):
                    checker.check_sources(self.descriptors, self.report)

    def test_rejects_cpu_translation_units_from_the_wrong_architecture(self):
        mutations = {
            "linux": "*/ggml/src/ggml-cpu/arch/arm/quants.c",
            "macosx": "*/ggml/src/ggml-cpu/arch/x86/quants.c",
            "windows": "*/ggml/src/ggml-cpu/arch/arm/quants.c",
        }
        for platform, source in mutations.items():
            with self.subTest(platform=platform, source=source):
                self.descriptors = copy.deepcopy(self.original)
                sources = self.descriptors["compat.ggml-cpu"]["mcpp"][platform]["sources"]
                sources[max(sources) + 1] = source
                with self.assertRaisesRegex(checker.CheckError, "CPU TU set drift"):
                    checker.check_sources(self.descriptors, self.report)

    def test_rejects_backend_metal_on_another_descriptor(self):
        base = self.descriptors["compat.ggml-base"]["mcpp"]
        base.setdefault("features", {})["backend-metal"] = {}
        self.assert_rejected(checker.check_registry_and_features, "backend-metal")

    def test_rejects_backend_metal_in_scope_without_xpm(self):
        metal = self.descriptors["compat.ggml-metal"]["mcpp"]
        metal.setdefault("linux", {}).setdefault("features", {})["backend-metal"] = {}
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

    def test_rejects_split_dash_d_macro(self):
        flags = self.descriptors["compat.ggml-base"]["mcpp"]["cxxflags"]
        flags[max(flags) + 1] = "-D"
        flags[max(flags) + 1] = "GGML_USE_LLAMAFILE"
        with self.assertRaisesRegex(checker.CheckError, "GGML_USE_LLAMAFILE"):
            checker.check_cpu_private_macros(self.descriptors)

    def test_rejects_windows_value_macro(self):
        flags = self.descriptors["compat.ggml-base"]["mcpp"]["cxxflags"]
        flags[max(flags) + 1] = "/DGGML_USE_CPU_REPACK=1"
        with self.assertRaisesRegex(checker.CheckError, "GGML_USE_CPU_REPACK"):
            checker.check_cpu_private_macros(self.descriptors)

    def test_workflow_runs_checker_mutation_suite(self):
        workflow = checker.ROOT / ".github/workflows/validate.yml"
        ruby = r'''
doc = YAML.load_file(ARGV[0])
step = doc.fetch('jobs').fetch('lint').fetch('steps').find do |item|
  item['name'] == 'Check llama.cpp snapshot cohort'
end
abort 'snapshot cohort step missing' unless step
puts step.fetch('run')
'''
        result = subprocess.run(
            ["ruby", "-ryaml", "-e", ruby, str(workflow)],
            text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(
            "python3 -m unittest tests/test_check_llamacpp_snapshot.py -v",
            result.stdout,
        )

    def test_internal_metal_member_is_wired_into_workspace_and_ci(self):
        root_manifest = (checker.ROOT / "mcpp.toml").read_text()
        metal_manifest = checker.ROOT / "tests/examples/llamacpp-internal-metal/mcpp.toml"
        metal_test = checker.ROOT / "tests/examples/llamacpp-internal-metal/tests/decode.cpp"
        self.assertIn('"tests/examples/llamacpp-internal-metal"', root_manifest)
        self.assertTrue(metal_manifest.is_file())
        self.assertTrue(metal_test.is_file())

        manifest_text = metal_manifest.read_text()
        test_text = metal_test.read_text()
        self.assertIn('cfg(all(macos, arch = "aarch64"))', manifest_text)
        self.assertIn('features = ["backend-metal"]', manifest_text)
        self.assertIn("LLAMACPP_METAL_TEST", manifest_text)
        self.assertIn("llama_supports_gpu_offload", test_text)
        self.assertIn("ggml_backend_reg_by_name", test_text)
        self.assertIn("n_gpu_layers", test_text)
        self.assertIn("llama_decode", test_text)
        self.assertIn(
            '#error "LLAMACPP_METAL_TEST must be enabled on macOS ARM64"',
            test_text,
        )
        self.assertIn("defined(__aarch64__) || defined(__arm64__)", test_text)


if __name__ == "__main__":
    unittest.main()
