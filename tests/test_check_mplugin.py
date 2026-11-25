"""The two lints of docs/build-plugins.md, run on small descriptors in a temporary tree.

    python3 tests/test_check_mplugin.py
"""
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def descriptor(namespace, name):
    return f'package = {{ spec = "1", namespace = "{namespace}", name = "{name}", type = "package" }}\n'


def lint(script, directory, filename, namespace, name):
    with tempfile.TemporaryDirectory() as tmp:
        target = Path(tmp) / directory
        target.mkdir(parents=True)
        path = target / filename
        path.write_text(descriptor(namespace, name))
        result = subprocess.run(["lua5.4", str(ROOT / "tests" / script), str(path)], capture_output=True, text=True)
        return result.returncode


class MpluginLayout(unittest.TestCase):
    def layout(self, directory, namespace, name, filename=None):
        return lint("check_mplugin_layout.lua", directory, filename or f"{namespace}.{name}.lua", namespace, name)

    def test_plugin_in_mcpp_dir_passes(self):
        self.assertEqual(self.layout("pkgs/mcpp", "mcpplibs.mplugin", "slint"), 0)

    def test_underscores_pass(self):
        self.assertEqual(self.layout("pkgs/mcpp", "mcpplibs.mplugin", "openkal_bind"), 0)

    def test_plugin_outside_mcpp_dir_fails(self):
        self.assertEqual(self.layout("pkgs/s", "mcpplibs.mplugin", "slint"), 1)

    def test_hyphen_in_name_fails(self):
        self.assertEqual(self.layout("pkgs/mcpp", "mcpplibs.mplugin", "openkal-bind"), 1)

    def test_upper_case_owner_fails(self):
        self.assertEqual(self.layout("pkgs/mcpp", "Acme.mplugin", "foo"), 1)

    def test_official_package_in_mcpp_dir_passes(self):
        self.assertEqual(self.layout("pkgs/mcpp", "mcpp", "plugins"), 0)

    def test_other_namespace_in_mcpp_dir_fails(self):
        self.assertEqual(self.layout("pkgs/mcpp", "mcpplibs", "slintgen"), 1)

    def test_wrapper_elsewhere_passes(self):
        self.assertEqual(self.layout("pkgs/mwrap", "mcpplibs.mwrap", "slint"), 0)


class ReservedOwner(unittest.TestCase):
    def reserved(self, namespace, name="x"):
        return lint("check_reserved_namespace.lua", "pkgs/mcpp", "x.lua", namespace, name)

    def test_ordinary_owners_pass(self):
        for owner in ("mcpplibs", "acme", "d2learn"):
            self.assertEqual(self.reserved(owner + ".mplugin"), 0, owner)

    def test_reserved_owners_fail(self):
        for owner in ("mcpp", "core", "plugins", "deps", "rules", "dist", "tools", "platforms", "mwrap", "mplugin"):
            self.assertEqual(self.reserved(owner + ".mplugin"), 1, owner)

    def test_reserved_first_segment_still_fails(self):
        self.assertEqual(self.reserved("plugins"), 1)

    def test_other_namespaces_unaffected(self):
        for ns in ("mcpplibs", "compat", "mcpplibs.mwrap", "mcpp"):
            self.assertEqual(self.reserved(ns), 0, ns)


if __name__ == "__main__":
    unittest.main()
