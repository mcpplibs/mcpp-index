"""tests/check_capability_providers.lua on small descriptors in a temporary tree.

    python3 tests/test_check_capability_providers.py
"""
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def descriptor(name, mcpp, namespace="compat"):
    return f'package = {{ spec = "1", namespace = "{namespace}", name = "{name}", type = "package", mcpp = {mcpp} }}\n'


def run(files, *flags):
    with tempfile.TemporaryDirectory() as tmp:
        paths = []
        for name, text in files.items():
            path = Path(tmp) / f"{name}.lua"
            path.write_text(text)
            paths.append(str(path))
        result = subprocess.run(["lua5.4", str(ROOT / "tests/check_capability_providers.lua"), *flags, *paths],
                                capture_output=True, text=True)
        return result.returncode, result.stdout


PROVIDER = descriptor("glx", '{ runtime = { capabilities = { "gl" }, provides = { "gl" } } }')


class CapabilityProviders(unittest.TestCase):
    def test_a_capability_with_a_provider_the_package_depends_on_is_clean(self):
        rc, out = run({"glx": PROVIDER, "app": descriptor("app", '{ deps = { ["compat.glx"] = "1" }, runtime = { capabilities = { "gl" } } }')})
        self.assertEqual(rc, 0)
        self.assertNotIn("warning", out)

    def test_a_provider_reached_through_another_package_counts(self):
        rc, out = run({"glx": PROVIDER,
                       "mid": descriptor("mid", '{ deps = { ["compat.glx"] = "1" } }'),
                       "app": descriptor("app", '{ deps = { ["compat.mid"] = "1" }, runtime = { capabilities = { "gl" } } }')})
        self.assertNotIn("warning", out)

    def test_a_platform_section_is_read(self):
        rc, out = run({"glx": PROVIDER,
                       "app": descriptor("app", '{ linux = { deps = { ["compat.glx"] = "1" }, runtime = { capabilities = { "gl" } } } }')})
        self.assertNotIn("warning", out)

    def test_a_package_that_provides_it_itself_is_clean(self):
        rc, out = run({"glx": PROVIDER})
        self.assertNotIn("warning", out)

    def test_a_capability_nobody_provides_is_reported(self):
        rc, out = run({"app": descriptor("app", '{ runtime = { capabilities = { "display" } } }')})
        self.assertEqual(rc, 0)
        self.assertIn("no package in the index provides it", out)

    def test_a_provider_the_package_does_not_depend_on_is_reported(self):
        rc, out = run({"glx": PROVIDER, "app": descriptor("app", '{ runtime = { capabilities = { "gl" } } }')})
        self.assertEqual(rc, 0)
        self.assertIn("depends on no package that provides it (compat.glx does)", out)

    def test_strict_turns_a_finding_into_a_failure(self):
        rc, _ = run({"app": descriptor("app", '{ runtime = { capabilities = { "display" } } }')}, "--strict")
        self.assertEqual(rc, 1)

    def test_a_form_a_descriptor_is_ignored(self):
        rc, out = run({"app": 'package = { spec = "1", namespace = "compat", name = "app", type = "package", mcpp = "*/mcpp.toml" }\n'})
        self.assertEqual(rc, 0)
        self.assertNotIn("warning", out)


if __name__ == "__main__":
    unittest.main()
