"""Regression for ambiguous candidates left by complete test-index copies."""
from pathlib import Path
import json
import shutil
import subprocess
import sys
import tempfile
import unittest


class NamespaceViews(unittest.TestCase):
    def test_rebuild_removes_cross_namespace_candidates(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "tests").mkdir()
            script = root / "tests/prepare_mwrap_indices.py"
            shutil.copyfile(Path(__file__).with_name(script.name), script)
            (root / "index.toml").write_text('name = "fixture"\n')
            originals = {}
            namespaces = ("compat", "mcpplibs.mwrap", "grpc", "mcpplibs")
            for namespace in namespaces:
                source = root / "pkgs/mwrap" / (namespace + ".sample.lua")
                source.parent.mkdir(parents=True, exist_ok=True)
                data = ('namespace = "' + namespace + '"\nname = "sample"\n').encode()
                source.write_bytes(data)
                originals[source.relative_to(root).as_posix()] = data
            views = root / "tests/mwrap/.indices"
            for attempt in range(2):
                # Old clients could populate a missing view with a full index.
                stale = views / "compat/pkgs/old-category/mcpplibs.mwrap.sample.lua"
                stale.parent.mkdir(parents=True, exist_ok=True)
                stale.write_bytes(originals["pkgs/mwrap/mcpplibs.mwrap.sample.lua"])
                subprocess.run([sys.executable, str(script)], check=True, capture_output=True)
                self.assertFalse(stale.exists())
                candidates = []
                for namespace in namespaces:
                    view = views / namespace
                    descriptors = list(view.glob("pkgs/*/*.lua"))
                    self.assertEqual(len(descriptors), 1)
                    key = "pkgs/mwrap/" + namespace + ".sample.lua"
                    self.assertEqual(descriptors[0].read_bytes(), originals[key])
                    self.assertEqual(set(json.loads((view / "source-manifest.json").read_text())), {key})
                    candidates.append(descriptors[0].read_bytes())
                self.assertEqual(len(set(candidates)), 4)


if __name__ == "__main__":
    unittest.main()
