"""Exercise CI audit boundaries with real Git baselines and Lua descriptors."""
import json
import subprocess
import tempfile
import tomllib
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
    def test_commit_snapshot_is_manual_but_historical_bytes_are_still_guarded(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "pkgs/mwrap/mcpplibs.mwrap.example.lua"
            path.parent.mkdir(parents=True)
            original = '''package = {
spec="1", namespace="mcpplibs.mwrap", name="example",
xpm={linux={["1.0.0"]={
url="https://github.com/acme/example/archive/1111111111111111111111111111111111111111.tar.gz",
sha256="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
}}},
}'''
            path.write_text(original)
            for args in (("init",), ("add", "."),
                         ("-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-m", "baseline")):
                subprocess.run(["git", *args], cwd=root, check=True, capture_output=True)
            with patch.object(ci, "ROOT", root):
                report = root / "coverage.json"
                ci.audit("HEAD", report)
                self.assertEqual(len(json.loads(report.read_text())["manual"]), 1)
                path.write_text(original.replace("a" * 64, "b" * 64))
                with self.assertRaisesRegex(RuntimeError, "without a revision bump"):
                    ci.audit("HEAD", report)
                path.write_text(original)
                release = path.with_name("mcpplibs.mwrap.release.lua")
                release.write_text(original.replace('name="example"', 'name="release"').replace(
                    'archive/1111111111111111111111111111111111111111', 'archive/refs/tags/v1.0.0'))
                with self.assertRaisesRegex(RuntimeError, "missing autoupdate"):
                    ci.audit("HEAD", report)

    def test_mwrap_candidate_uses_its_actual_member_and_qualified_dependency(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "tests/mwrap/example"
            (source / "tests").mkdir(parents=True)
            (source / "mcpp.toml").write_text(
                '[package]\nname="consumer"\nversion="0.1.0"\n'
                '[dependencies]\n"mcpplibs.mwrap.example"="1.0.0"\n')
            (source / "tests/probe.cpp").write_text('int main() { return 0; }\n')
            plan = root / "plan.json"
            plan.write_text(json.dumps({"packages": [
                {"id": "mcpplibs.mwrap:example", "candidate": "1.0.1"}]}))
            with patch.object(ci, "ROOT", root):
                self.assertEqual(ci.direct_member("mcpplibs.mwrap:example"), "example")
                dest = root / "candidate"
                ci.prepare(plan, "mcpplibs.mwrap:example", dest)
                result = tomllib.loads((dest / "mcpp.toml").read_text())
                self.assertEqual(result["dependencies"]["mcpplibs.mwrap.example"], "1.0.1")
                self.assertEqual((dest / "tests/probe.cpp").read_text(), 'int main() { return 0; }\n')

    def test_candidate_discovers_target_and_build_dependencies(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "tests/mwrap/tools"
            source.mkdir(parents=True)
            (source / "mcpp.toml").write_text(
                '[package]\nname="tools"\nversion="0.1.0"\n'
                '[target.\'cfg(unix)\'.dependencies.grpc]\ngrpc="1.83.0"\n'
                '[build-dependencies]\n"mcpplibs.grpcgen"={version="1.83.0",host-module=true}\n')
            with patch.object(ci, "ROOT", root):
                self.assertEqual(ci.direct_member("grpc:grpc"), "tools")
                self.assertEqual(ci.direct_member("mcpplibs:grpcgen"), "tools")
                self.assertIsNone(ci.direct_member("grpc:grpc-plugin"))
                plan = root / "plan.json"
                plan.write_text(json.dumps({"packages": [
                    {"id": "mcpplibs:grpcgen", "candidate": "1.83.0.1"}]}))
                dest = root / "candidate"
                ci.prepare(plan, "mcpplibs:grpcgen", dest)
                result = tomllib.loads((dest / "mcpp.toml").read_text())
                self.assertEqual(result["build-dependencies"]["mcpplibs.grpcgen"]["version"], "1.83.0.1")

    def test_dedicated_mwrap_consumer_precedes_shorter_legacy_example(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for category, name in (("examples", "old"), ("mwrap", "headless")):
                source = root / "tests" / category / name
                source.mkdir(parents=True)
                (source / "mcpp.toml").write_text(
                    '[package]\nname="consumer"\nversion="0.1.0"\n'
                    '[dependencies]\n"ocornut.imgui"="1.92.8.1"\n')
            with patch.object(ci, "ROOT", root):
                self.assertEqual(ci.direct_member("ocornut:imgui"), "headless")

    def test_coupled_consumer_uses_one_complete_builtin_index(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "tests/mwrap/tools"
            source.mkdir(parents=True)
            (source / "mcpp.toml").write_text(
                '[package]\nname="tools"\nversion="0.1.0"\n'
                '[indices]\ngrpc={path="../../.."}\n'
                '[dependencies]\n"grpc.grpc-plugin"="1.83.0.1"\n'
                '[build-dependencies]\n"mcpplibs.grpcgen"={version="1.83.0.1",host-module=true}\n')
            (root / "index.toml").write_text('[index]\nname="mcpplibs"\n')
            package = root / "pkgs/mwrap/example.lua"
            package.parent.mkdir(parents=True)
            package.write_bytes(b'-- unchanged descriptor bytes\n')
            home = root / "home"
            stale = home / "indices/mcpplibs/pkgs/old.lua"
            stale.parent.mkdir(parents=True)
            stale.write_text('-- stale')
            plan = root / "plan.json"
            plan.write_text(json.dumps({"packages": [
                {"id": "mcpplibs:grpcgen", "candidate": "1.83.0.1"}]}))
            with patch.object(ci, "ROOT", root):
                dest = root / "consumer"
                ci.prepare(plan, "mcpplibs:grpcgen", dest, home)
                manifest = tomllib.loads((dest / "mcpp.toml").read_text())
                self.assertNotIn("indices", manifest)
                self.assertIn("grpc.grpc-plugin", manifest["dependencies"])
                self.assertIn("mcpplibs.grpcgen", manifest["build-dependencies"])
                self.assertEqual((home / "indices/mcpplibs/pkgs/mwrap/example.lua").read_bytes(), package.read_bytes())
                self.assertFalse(stale.exists())

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
