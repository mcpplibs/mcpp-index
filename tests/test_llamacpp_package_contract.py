import pathlib
import re
import subprocess
import tempfile
import tomllib
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
DESCRIPTOR = ROOT / "pkgs/g/ggml-org.llamacpp.lua"
WORKFLOW = ROOT / ".github/workflows/validate.yml"
CONSUMERS = (
    ROOT / "tests/examples/llamacpp-internal-cpu/mcpp.toml",
    ROOT / "tests/examples/llamacpp-internal-metal/mcpp.toml",
)


class LlamaCppPackageContractTests(unittest.TestCase):
    def test_descriptor_publishes_only_the_verified_version(self):
        self.assertTrue(DESCRIPTOR.is_file(), "llama.cpp descriptor is missing")
        text = DESCRIPTOR.read_text()
        self.assertIn('namespace   = "ggml-org"', text)
        self.assertIn('name        = "llamacpp"', text)
        self.assertNotIn('name        = "ggml-org.llamacpp"', text)
        self.assertIn('["b10069"]', text)
        self.assertNotIn('["b10107"]', text)

    def test_cpu_architecture_sources_are_target_conditional(self):
        text = DESCRIPTOR.read_text()
        target_cfg_start = text.find("        target_cfg = {")
        platform_start = text.find("        linux = {", target_cfg_start)

        self.assertGreaterEqual(target_cfg_start, 0, "mcpp.target_cfg is missing")
        self.assertGreater(
            platform_start,
            target_cfg_start,
            "platform tables must follow mcpp.target_cfg",
        )

        target_cfg = text[target_cfg_start:platform_start]
        platform_tables = text[platform_start:]
        self.assertIn('[\'cfg(arch = "x86_64")\']', target_cfg)
        self.assertIn('[\'cfg(arch = "aarch64")\']', target_cfg)

        arch_sources = (
            "*/ggml/src/ggml-cpu/arch/x86/quants.c",
            "*/ggml/src/ggml-cpu/arch/x86/repack.cpp",
            "*/ggml/src/ggml-cpu/arch/arm/quants.c",
            "*/ggml/src/ggml-cpu/arch/arm/repack.cpp",
        )
        for source in arch_sources:
            with self.subTest(source=source):
                self.assertEqual(text.count(f'"{source}"'), 1)
                self.assertIn(f'"{source}"', target_cfg)
                self.assertNotIn(f'"{source}"', platform_tables)

    def test_consumers_resolve_b10069_from_this_checkout(self):
        for manifest in CONSUMERS:
            with self.subTest(manifest=manifest):
                self.assertTrue(manifest.is_file(), f"missing consumer: {manifest}")
                data = tomllib.loads(manifest.read_text())
                self.assertEqual(data["indices"]["ggml-org"]["path"], "../../..")

                versions = []

                def collect(value):
                    if isinstance(value, dict):
                        for key, child in value.items():
                            if key == "llamacpp":
                                versions.append(
                                    child if isinstance(child, str) else child["version"]
                                )
                            else:
                                collect(child)

                collect(data)
                self.assertEqual(versions, ["b10069"])

    def test_workflow_selects_namespaced_descriptor_consumers(self):
        workflow = WORKFLOW.read_text()
        self.assertIn('lib=$(basename "$f" .lua); lib=${lib##*.}', workflow)
        self.assertIn(
            '[ "$hit" = 1 ] || full "no workspace member exercises $f"',
            workflow,
        )
        self.assertNotIn("tools/select_affected_members.py", workflow)

    def test_workflow_dependency_match_is_exact(self):
        workflow = WORKFLOW.read_text()
        line = next(
            (line for line in workflow.splitlines() if 'grep -Eq' in line and '"$mt"' in line),
            None,
        )
        self.assertIsNotNone(line, "exact dependency-key matcher is missing")
        match = re.search(r'grep -Eq "(.+)" "\$mt"', line)
        self.assertIsNotNone(match, f"cannot parse dependency matcher: {line}")
        pattern = match.group(1).replace("${lib}", "llamacpp")

        for manifest, expected in (
            ('ggml-org.llamacpp = "b10069"\n', True),
            ('llamacpp = "b10069"\n', True),
            ('# llamacpp = "b10069"\n', False),
            ('llamacpp-helper = "1.0.0"\n', False),
            ('name = "llamacpp-internal-cpu"\n', False),
        ):
            with self.subTest(manifest=manifest), tempfile.NamedTemporaryFile(
                mode="w", encoding="utf-8"
            ) as fixture:
                fixture.write(manifest)
                fixture.flush()
                result = subprocess.run(
                    ["grep", "-Eq", pattern, fixture.name], check=False
                )
                self.assertEqual(result.returncode == 0, expected)

    def test_workflow_forces_cold_llamacpp_materialization(self):
        workflow = WORKFLOW.read_text()
        self.assertIn("ggml-org-x-ggml-org.llamacpp", workflow)
        self.assertIn("Cold-start llama.cpp package", workflow)


if __name__ == "__main__":
    unittest.main()
