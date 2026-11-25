"""The installed-template check follows the checkout's newest wrapper version."""
from pathlib import Path
import importlib.util
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("check_installed_template", ROOT / "tests/mwrap/check_installed_template.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class NewestDeclaredVersion(unittest.TestCase):
    def fake_root(self, text):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        root = Path(directory.name)
        (root / "pkgs/mwrap").mkdir(parents=True)
        (root / "pkgs/mwrap/demo.lua").write_text(text, encoding="utf-8")
        return root

    def test_newest_is_numeric_not_lexical(self):
        root = self.fake_root('xpm = { linux = { ["0.9.0"] = {}, ["0.10.0"] = {}, ["0.5.3.1"] = {} } }')
        self.assertEqual(module.newest_declared_version(root, "mcpplibs.mwrap.demo"), "0.10.0")

    def test_four_part_revision_follows_its_base(self):
        root = self.fake_root('xpm = { linux = { ["0.5.3"] = {}, ["0.5.3.1"] = {} } }')
        self.assertEqual(module.newest_declared_version(root, "mcpplibs.mwrap.demo"), "0.5.3.1")

    def test_nonnumeric_keys_are_not_versions(self):
        root = self.fake_root('xpm = { linux = { ["b10069.2"] = {} } }')
        with self.assertRaises(AssertionError):
            module.newest_declared_version(root, "mcpplibs.mwrap.demo")

    def test_every_numeric_mwrap_descriptor_resolves(self):
        for descriptor in sorted((ROOT / "pkgs/mwrap").glob("*.lua")):
            identity = "mcpplibs.mwrap." + descriptor.stem
            try:
                version = module.newest_declared_version(ROOT, identity)
            except AssertionError as error:
                self.assertIn("no numeric version", str(error), identity)
                continue
            self.assertRegex(version, r"^\d+(\.\d+)*$", identity)


if __name__ == "__main__":
    unittest.main()
