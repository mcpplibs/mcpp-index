"""Mutation tests for the ggml-org.llamacpp llama.cpp snapshot gate."""
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
        cls.secondary_reports = []
        if checker.REPORT_PATH_B10107.is_file():
            cls.secondary_reports.append(
                json.loads(checker.REPORT_PATH_B10107.read_text()))
        cls.original = {
            name: checker.load_descriptor(lua, path)
            for name, path in checker.DESCRIPTORS.items()
        }

    def setUp(self):
        self.descriptors = copy.deepcopy(self.original)
        self.tag = self.report["upstream"]["tag"]

    def assert_rejected(self, function, pattern):
        with self.assertRaisesRegex(checker.CheckError, pattern):
            if function is checker.check_dependencies:
                function(self.descriptors, self.tag)
            elif function in (checker.check_cpu_private_macros,
                              checker.check_module_contract):
                function(self.descriptors)
            elif function in (checker.check_sources,
                              checker.check_report_metadata_contracts):
                function(self.descriptors, self.report, self.secondary_reports)
            else:
                function(self.descriptors, self.report)

    def test_uses_one_llamacpp_descriptor(self):
        self.assertEqual(
            checker.DESCRIPTORS,
            {"ggml-org.llamacpp": checker.ROOT / "pkgs/g/ggml-org.llamacpp.lua"},
        )
        for removed in (
            "compat.ggml-base.lua",
            "compat.ggml-cpu.lua",
            "compat.ggml-metal.lua",
        ):
            self.assertFalse((checker.ROOT / "pkgs/c" / removed).exists())

    def test_rejects_cn_url_before_mirror_is_published(self):
        release = self.descriptors["ggml-org.llamacpp"]["xpm"]["linux"][self.tag]
        release["url"] = {
            "GLOBAL": release["url"],
            "CN": "https://gitcode.com/mcpp-res/llamacpp/releases/download/"
                    f"{self.tag}/llama.cpp-{self.tag}.tar.gz",
        }
        self.assert_rejected(checker.check_cohort, "URL")

    def test_rejects_component_dependency(self):
        self.descriptors["ggml-org.llamacpp"]["mcpp"]["deps"] = {
            "compat.ggml-base": self.tag,
        }
        self.assert_rejected(checker.check_dependencies, "component packages")

    def test_rejects_feature_provider_dependency(self):
        feature = self.descriptors["ggml-org.llamacpp"]["mcpp"]["features"]["backend-metal"]
        feature["deps"] = {"compat.ggml-metal": self.tag}
        self.assert_rejected(checker.check_dependencies, "in-package feature")

    def test_rejects_provider_capability(self):
        self.descriptors["ggml-org.llamacpp"]["mcpp"]["provides"] = {1: "ggml.accelerator"}
        self.assert_rejected(checker.check_dependencies, "provider capabilities")

    def test_rejects_missing_default_translation_unit(self):
        sources = self.descriptors["ggml-org.llamacpp"]["mcpp"]["sources"]
        source = "*/ggml/src/ggml-cpu/ops.cpp"
        key = next(key for key, value in sources.items() if value == source)
        del sources[key]
        remaining = [sources[key] for key in sorted(sources)]
        sources.clear()
        sources.update(enumerate(remaining, start=1))
        self.assert_rejected(checker.check_sources, r"default TU set drift.*ops\.cpp")

    def test_rejects_missing_cpu_architecture_translation_unit(self):
        sources = self.descriptors["ggml-org.llamacpp"]["mcpp"]["linux"]["sources"]
        del sources[max(sources)]
        self.assert_rejected(checker.check_sources, "default TU set drift")

    def test_rejects_cpu_translation_unit_in_disabled_feature(self):
        mcpp = self.descriptors["ggml-org.llamacpp"]["mcpp"]
        source = "*/ggml/src/ggml-cpu/ops.cpp"
        sources = mcpp["sources"]
        key = next(key for key, value in sources.items() if value == source)
        del sources[key]
        remaining = [sources[key] for key in sorted(sources)]
        sources.clear()
        sources.update(enumerate(remaining, start=1))
        mcpp["features"]["parked"] = {"sources": {1: source}}
        self.assert_rejected(checker.check_sources, r"default TU set drift.*ops\.cpp")

    def test_rejects_default_metal_source(self):
        sources = self.descriptors["ggml-org.llamacpp"]["mcpp"]["sources"]
        sources[max(sources) + 1] = "*/ggml/src/ggml-metal/ggml-metal.cpp"
        self.assert_rejected(checker.check_sources, "default TU set drift")

    def test_rejects_missing_metal_translation_unit(self):
        feature = self.descriptors["ggml-org.llamacpp"]["mcpp"]["features"]["backend-metal"]
        del feature["sources"][max(feature["sources"])]
        self.assert_rejected(checker.check_sources, "Metal TU set drift")

    def test_rejects_duplicate_metal_translation_unit(self):
        sources = self.descriptors["ggml-org.llamacpp"]["mcpp"]["features"]["backend-metal"]["sources"]
        sources[max(sources) + 1] = "*/ggml/src/ggml-metal/ggml-metal.cpp"
        self.assert_rejected(checker.check_sources, "duplicate Metal TU")

    def test_rejects_duplicate_translation_unit(self):
        sources = self.descriptors["ggml-org.llamacpp"]["mcpp"]["sources"]
        sources[max(sources) + 1] = "*/ggml/src/ggml-backend-reg.cpp"
        self.assert_rejected(checker.check_sources, "duplicate")

    def test_rejects_model_wildcard(self):
        sources = self.descriptors["ggml-org.llamacpp"]["mcpp"]["sources"]
        key = next(key for key, value in sources.items() if value == "*/src/models/afmoe.cpp")
        sources[key] = "*/src/models/*.cpp"
        self.assert_rejected(checker.check_sources, "wildcard source")

    def test_rejects_backend_metal_on_platform_scope(self):
        mcpp = self.descriptors["ggml-org.llamacpp"]["mcpp"]
        mcpp.setdefault("linux", {})["features"] = {"backend-metal": {}}
        self.assert_rejected(checker.check_registry_and_features, "feature placement")

    def test_rejects_backend_feature_contract_drift(self):
        mutations = (
            ("missing CPU", lambda features: features.pop("backend-cpu")),
            ("extra feature", lambda features: features.update({"backend-cuda": {}})),
            ("non-CPU default", lambda features: features["default"].update(
                {"implies": {1: "backend-metal"}})),
        )
        for label, mutate in mutations:
            mutated = copy.deepcopy(self.descriptors)
            mutate(mutated["ggml-org.llamacpp"]["mcpp"]["features"])
            with self.subTest(label=label):
                with self.assertRaisesRegex(checker.CheckError, "CPU and Metal|select backend-cpu"):
                    checker.check_registry_and_features(mutated, self.report)

    def test_rejects_registry_macro_outside_registry_source(self):
        flags = self.descriptors["ggml-org.llamacpp"]["mcpp"]["flags"]
        flags[max(flags) + 1] = {"glob": "*/src/llama.cpp", "defines": {1: "GGML_USE_CPU"}}
        self.assert_rejected(checker.check_registry_and_features, "one registry-only owner")

    def test_rejects_cpu_repack_macro_removal(self):
        flags = self.descriptors["ggml-org.llamacpp"]["mcpp"]["cflags"]
        remaining = [value for _, value in sorted(flags.items())
                     if value != "-DGGML_USE_CPU_REPACK"]
        flags.clear()
        flags.update(enumerate(remaining, start=1))
        self.assert_rejected(checker.check_cpu_private_macros, "CPU repack")

    def test_rejects_llamafile_macro_removal(self):
        flags = self.descriptors["ggml-org.llamacpp"]["mcpp"]["flags"]
        key = next(key for key, value in flags.items()
                   if value.get("glob") == "*/ggml/src/ggml-cpu/**")
        del flags[key]
        remaining = [flags[key] for key in sorted(flags)]
        flags.clear()
        flags.update(enumerate(remaining, start=1))
        self.assert_rejected(checker.check_cpu_private_macros, "llamafile")

    def test_rejects_generated_module_drift(self):
        generated = self.descriptors["ggml-org.llamacpp"]["mcpp"]["generated_files"]
        generated["mcpp_generated/llama.cppm"] += "\n// drift\n"
        self.assert_rejected(checker.check_module_contract, "generated module input drift")

    def test_rejects_module_name_drift(self):
        self.descriptors["ggml-org.llamacpp"]["mcpp"]["modules"] = {1: "wrong"}
        self.assert_rejected(checker.check_module_contract, "exactly the llama module")

    def test_rejects_extra_target(self):
        self.descriptors["ggml-org.llamacpp"]["mcpp"]["targets"]["extra"] = {
            "kind": "lib",
        }
        self.assert_rejected(checker.check_module_contract, "exactly one llama target")

    def test_rejects_absolute_xcode_metal_tool_paths(self):
        generated = self.descriptors["ggml-org.llamacpp"]["mcpp"]["generated_files"]
        for tool in ("/usr/bin/xcrun", "/usr/bin/metal", "/usr/bin/metallib"):
            mutated = copy.deepcopy(self.descriptors)
            mutated["ggml-org.llamacpp"]["mcpp"]["generated_files"]["build.mcpp"] += (
                f"\n// {tool}\n"
            )
            with self.subTest(tool=tool):
                with self.assertRaisesRegex(checker.CheckError, "absolute Xcode Metal tool path"):
                    checker.check_metal_build_contract(mutated, self.report)
        self.assertTrue(generated["build.mcpp"])

    def test_rejects_process_launch_apis_in_metal_generator(self):
        calls = (
            'std::system("metal")',
            'popen("metal", "r")',
            'execl("xcrun", "xcrun", "metal", nullptr)',
            'posix_spawn(...)',
        )
        for call in calls:
            with self.subTest(call=call):
                mutated = copy.deepcopy(self.descriptors)
                mutated["ggml-org.llamacpp"]["mcpp"]["generated_files"]["build.mcpp"] += (
                    f"\n{call};\n"
                )
                with self.assertRaisesRegex(checker.CheckError, "process launch API"):
                    checker.check_metal_build_contract(mutated, self.report)

    def test_rejects_missing_metal_feature_gate(self):
        mutated = copy.deepcopy(self.descriptors)
        source = mutated["ggml-org.llamacpp"]["mcpp"]["generated_files"]["build.mcpp"]
        mutated["ggml-org.llamacpp"]["mcpp"]["generated_files"]["build.mcpp"] = source.replace(
            '    const char * enabled = std::getenv("MCPP_FEATURE_BACKEND_METAL");\n'
            '    if (!enabled || std::string(enabled) != "1") return 0;\n',
            "",
        )
        with self.assertRaisesRegex(checker.CheckError, "must no-op"):
            checker.check_metal_build_contract(mutated, self.report)

    def test_rejects_missing_feature_whitelist(self):
        mutated = copy.deepcopy(self.descriptors)
        source = mutated["ggml-org.llamacpp"]["mcpp"]["generated_files"]["build.mcpp"]
        mutated["ggml-org.llamacpp"]["mcpp"]["generated_files"]["build.mcpp"] = source.replace(
            "    if (int result = validate_features(); result != 0) return result;\n",
            "",
        )
        with self.assertRaisesRegex(checker.CheckError, "must reject undeclared feature"):
            checker.check_metal_build_contract(mutated, self.report)

    def test_workflow_runs_snapshot_and_selection_suites(self):
        workflow = checker.ROOT / ".github/workflows/validate.yml"
        ruby = r'''
doc = YAML.load_file(ARGV[0])
step = doc.fetch('jobs').fetch('lint').fetch('steps').find do |item|
  item['name'] == 'Check ggml-org.llamacpp snapshot'
end
abort 'snapshot check step missing' unless step
puts step.fetch('run')
'''
        result = subprocess.run(
            ["ruby", "-ryaml", "-e", ruby, str(workflow)],
            text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("python3 -m unittest tools/llamacpp/test_gen_exports.py -v", result.stdout)
        self.assertIn("python3 -m unittest tests/test_check_llamacpp_snapshot.py -v", result.stdout)
        self.assertIn("python3 -m unittest tests/test_select_affected_members.py -v", result.stdout)
        self.assertIn("python3 tools/llamacpp/audit_snapshot.py", result.stdout)
        self.assertIn("python3 tests/check_llamacpp_snapshot.py", result.stdout)

    def test_metal_member_consumes_merged_package(self):
        root_manifest = (checker.ROOT / "mcpp.toml").read_text()
        metal_manifest = checker.ROOT / "tests/examples/llamacpp-internal-metal/mcpp.toml"
        self.assertIn('"tests/examples/llamacpp-internal-metal"', root_manifest)
        self.assertIn('features = ["backend-metal"]', metal_manifest.read_text())
        self.assertNotIn("compat.ggml-metal", metal_manifest.read_text())
        self.assertIn("import llama;", (checker.ROOT / "tests/examples/llamacpp-internal-metal/tests/decode.cpp").read_text())


if __name__ == "__main__":
    unittest.main()
