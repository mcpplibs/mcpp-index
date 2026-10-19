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
                old.unlink()
                with self.assertRaisesRegex(RuntimeError, "existing descriptors removed"):
                    ci.audit("HEAD", root / "coverage.json")
