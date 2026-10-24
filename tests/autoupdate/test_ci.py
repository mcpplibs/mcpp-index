"""Exercise CI audit boundaries with real Git baselines and Lua descriptors."""
import json
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import ci


def descriptor(name):
    return '''package = {
 spec = "1", namespace = "compat", name = "%s",
 extensions = { autoupdate = {
   tag = "v${version}", url = "https://github.com/acme/%s/archive/refs/tags/${tag}.tar.gz",
 } },
 xpm = { linux = { ["1.0.0"] = {
   url = "https://github.com/acme/%s/archive/refs/tags/v1.0.0.tar.gz",
   sha256 = "%s",
 } } },
}
''' % (name, name, name, "a" * 64)


class BaselineTests(unittest.TestCase):
    def test_added_descriptor_and_removed_historical_descriptor(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            pkgs = root / "pkgs/f"
            pkgs.mkdir(parents=True)
            old = pkgs / "compat.old.lua"
            old.write_text(descriptor("old"))
            for args in (("init",), ("add", "."),
                         ("-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-m", "baseline")):
                subprocess.run(["git", *args], cwd=root, check=True, capture_output=True)
            (pkgs / "compat.new.lua").write_text(descriptor("new"))
            plan = root / "plan.json"
            plan.write_text(json.dumps({"packages": []}))
            with patch.object(ci, "ROOT", root):
                ci.audit("HEAD", root / "coverage.json")
                self.assertEqual(json.loads((root / "coverage.json").read_text())["covered"], 2)
                ci.matrix(plan, root / "matrix.json", "HEAD")
                self.assertEqual(json.loads((root / "matrix.json").read_text()), {"include": []})
                # A normal bump is already present when discovery runs. Shared
                # definitions must still produce jobs for that exact version.
                resource = '{ url = "https://github.com/acme/old/archive/refs/tags/v1.1.0.tar.gz", sha256 = "' + "b" * 64 + '" }'
                old.write_text('local versions = { ["1.1.0"] = ' + resource + ' }\n' +
                               old.read_text().replace('xpm = { linux = {',
                                   'xpm = { linux = { ["1.1.0"] = versions["1.1.0"],'))
                consumer = root / "tests/examples/old"
                consumer.mkdir(parents=True)
                (consumer / "mcpp.toml").write_text('[dependencies.compat]\nold = "1.1.0"\n')
                ci.audit("HEAD", root / "coverage.json")
                ci.matrix(plan, root / "matrix.json", "HEAD")
                jobs = json.loads((root / "matrix.json").read_text())["include"]
                self.assertEqual(len(jobs), 2)
                self.assertTrue(all(job["candidate"] == "1.1.0" for job in jobs))
                generated = json.loads((root / "build-plan.json").read_text())["packages"][0]
                self.assertEqual(generated["status"], "existing-candidate")
                self.assertEqual(generated["assets"][0]["resources"]["GLOBAL"]["sha256"], "b" * 64)
                old.unlink()
                with self.assertRaisesRegex(RuntimeError, "existing descriptors removed"):
                    ci.audit("HEAD", root / "coverage.json")

    def test_revision_allows_packaging_fix_but_not_resource_drift(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            pkgs = root / "pkgs/f"
            pkgs.mkdir(parents=True)
            descriptor_path = pkgs / "compat.old.lua"
            descriptor_path.write_text(descriptor("old"))
            for args in (("init",), ("add", "."),
                         ("-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-m", "baseline")):
                subprocess.run(["git", *args], cwd=root, check=True, capture_output=True)
            baseline = descriptor_path.read_text()
            with patch.object(ci, "ROOT", root):
                # A revision bump is the documented way to replace an installed
                # payload without inventing a new upstream version.
                descriptor_path.write_text(baseline.replace(
                    'sha256 = "' + "a" * 64 + '",',
                    'sha256 = "' + "a" * 64 + '",\n   revision = 1,'))
                ci.audit("HEAD", root / "coverage.json")

                # A resource change without that bump is still rejected.
                descriptor_path.write_text(baseline.replace("a" * 64, "b" * 64))
                with self.assertRaisesRegex(RuntimeError, "without a revision bump"):
                    ci.audit("HEAD", root / "coverage.json")

                # Revisions are monotonic; replacing revision 1 with 0 would
                # make an installed client treat the old payload as current.
                descriptor_path.write_text(baseline.replace(
                    'sha256 = "' + "a" * 64 + '",',
                    'sha256 = "' + "a" * 64 + '",\n   revision = 1,'))
                subprocess.run(["git", "add", "."], cwd=root, check=True, capture_output=True)
                subprocess.run(["git", "-c", "user.name=Test", "-c", "user.email=test@example.com",
                                "commit", "-m", "revision 1"], cwd=root, check=True, capture_output=True)
                descriptor_path.write_text(baseline.replace(
                    'sha256 = "' + "a" * 64 + '",',
                    'sha256 = "' + "a" * 64 + '",\n   revision = 0,'))
                with self.assertRaisesRegex(RuntimeError, "revision decreased"):
                    ci.audit("HEAD", root / "coverage.json")


class MemberPlatformTests(unittest.TestCase):
    """A candidate is asked of the runners its consumer builds it on, and of no other."""

    def member(self, root, text):
        member = root / "tests/examples/probe"
        member.mkdir(parents=True)
        (member / "mcpp.toml").write_text(text, encoding="utf-8")

    def test_conditions_select_runners(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            self.member(root, """[package]
name = "probe"
version = "0.1.0"

[dependencies.acme]
spec = "1.0.0"

[target.'cfg(os = "linux")'.dependencies.acme]
on-linux = "1.0.0"

[target.'cfg(os = "macos")'.dependencies.acme]
on-macos = "1.0.0"

[target.'cfg(windows)'.dependencies.acme]
on-windows = "1.0.0"

[target.'cfg(all(os = "linux", env = "musl"))'.dependencies.acme]
on-musl = "1.0.0"
""")
            with patch.object(ci, "ROOT", root):
                self.assertEqual(ci.member_platforms("probe", "acme:spec"), {"linux", "macosx", "windows"})
                self.assertEqual(ci.member_platforms("probe", "acme:on-linux"), {"linux"})
                self.assertEqual(ci.member_platforms("probe", "acme:on-macos"), {"macosx"})
                self.assertEqual(ci.member_platforms("probe", "acme:on-windows"), {"windows"})
                self.assertEqual(ci.member_platforms("probe", "acme:on-musl"), set())
                self.assertEqual(ci.member_platforms("probe", "other:spec"), set())
