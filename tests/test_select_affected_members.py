"""Behavioral tests for the workspace member selector used by CI."""
from __future__ import annotations

import importlib.util
import os
import subprocess
import tempfile
import textwrap
import unittest
from pathlib import Path


SCRIPT = Path(__file__).parents[1] / "tools/select_affected_members.py"
WORKSPACE = Path(__file__).parents[1]
WORKFLOW = WORKSPACE / ".github/workflows/validate.yml"
SPEC = importlib.util.spec_from_file_location("select_affected_members", SCRIPT)
assert SPEC and SPEC.loader
selector = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(selector)


def workflow_selector_script() -> str:
    workflow = WORKFLOW.read_text()
    marker = "      - name: Select affected workspace members\n"
    step = workflow.split(marker, 1)[1].split("      - name:", 1)[0]
    script = step.split("        run: |\n", 1)[1]
    script = textwrap.dedent(script)
    return script.replace(
        '${{ github.event_name }}', 'pull_request',
    ).replace(
        'base="origin/${{ github.base_ref }}"', 'base="HEAD^"',
    )


class TestLlamacppCohortSelection(unittest.TestCase):
    def test_ffmpeg_descriptor_selects_direct_and_transitive_consumers(self):
        manifests = {
            path.parent.name: path.read_text()
            for path in (WORKSPACE / "tests/examples").glob("*/mcpp.toml")
        }
        selected = selector.select_descriptor_members(
            "pkgs/c/compat.ffmpeg.lua", manifests,
        )
        self.assertEqual(selected, {
            "ffmpeg", "ffmpeg-module", "opencv", "opencv-dnn",
            "opencv-unifont",
        })

    def test_opencv_unifont_descriptor_selects_compat_and_module_members(self):
        self.assertEqual(
            selector.cohort_members("pkgs/c/compat.opencv-unifont.lua"),
            {"opencv-unifont", "opencv-module-unifont"},
        )

    def test_workflow_falls_back_to_full_run_for_unexercised_descriptor(self):
        workflow = WORKFLOW.read_text()
        self.assertIn(
            '[ "$hit" = 1 ] || full "no workspace member exercises $f"',
            workflow,
        )
        self.assertNotIn(
            'echo "note: no workspace member exercises $f"', workflow,
        )

    def test_removed_workspace_member_forces_full_run(self):
        with tempfile.TemporaryDirectory() as td:
            repo = Path(td)
            manifest = repo / "mcpp.toml"
            subprocess.run(["git", "init", "-q"], cwd=repo, check=True)
            manifest.write_text(textwrap.dedent("""\
                [workspace]
                members = [
                    "tests/examples/kept",
                    "tests/examples/removed",
                ]
            """))
            subprocess.run(["git", "add", "mcpp.toml"], cwd=repo, check=True)
            subprocess.run([
                "git", "-c", "user.name=Test", "-c",
                "user.email=test@example.com", "commit", "-qm", "base",
            ], cwd=repo, check=True)
            manifest.write_text(textwrap.dedent("""\
                [workspace]
                members = [
                    "tests/examples/kept",
                ]
            """))
            subprocess.run(["git", "add", "mcpp.toml"], cwd=repo, check=True)
            subprocess.run([
                "git", "-c", "user.name=Test", "-c",
                "user.email=test@example.com", "commit", "-qm", "remove",
            ], cwd=repo, check=True)

            github_env = repo / "github-env"
            env = os.environ.copy()
            env["GITHUB_ENV"] = str(github_env)
            subprocess.run(
                ["bash", "-c", workflow_selector_script()], cwd=repo,
                env=env, check=True, text=True, capture_output=True,
            )

            self.assertIn("MEMBERS=__ALL__", github_env.read_text().splitlines())

    def test_descriptor_changes_select_transitive_consumers(self):
        expected = {
            "pkgs/c/compat.ggml-base.lua": {
                "llamacpp-internal-cpu", "llamacpp-internal-metal",
            },
            "pkgs/c/compat.ggml-cpu.lua": {
                "llamacpp-internal-cpu", "llamacpp-internal-metal",
            },
            "pkgs/c/compat.llamacpp.lua": {
                "llamacpp-internal-cpu", "llamacpp-internal-metal",
            },
            "pkgs/c/compat.ggml-metal.lua": {
                "llamacpp-internal-metal",
            },
        }
        for path, members in expected.items():
            with self.subTest(path=path):
                self.assertEqual(selector.cohort_members(path), members)

    def test_non_cohort_descriptor_uses_manifest_references(self):
        manifests = {
            "archive": "[dependencies.compat]\nlibarchive = \"3.8.7\"\n",
            "unrelated": "[dependencies.compat]\neigen = \"5.0.1\"\n",
        }
        selected = selector.select_descriptor_members(
            "pkgs/c/compat.libarchive.lua", manifests,
        )
        self.assertEqual(selected, {"archive"})

    def test_namespace_qualified_descriptors_use_the_full_package_name(self):
        cases = {
            "pkgs/f/fmtlib.fmt.lua": (
                "fmtlib.fmt", "[dependencies.fmtlib]\nfmt = \"12.2.0\"\n",
            ),
            "pkgs/c/chriskohlhoff.asio.lua": (
                "asio-module", "[dependencies.chriskohlhoff]\nasio = \"1.38.1\"\n",
            ),
            "pkgs/n/nlohmann.json.lua": (
                "nlohmann.json", "[dependencies.nlohmann]\njson = \"3.12.0\"\n",
            ),
            "pkgs/m/marzer.tomlplusplus.lua": (
                "marzer.tomlplusplus",
                "[dependencies.marzer]\ntomlplusplus = \"3.4.0\"\n",
            ),
        }
        for descriptor, (member, manifest) in cases.items():
            with self.subTest(descriptor=descriptor):
                selected = selector.select_descriptor_members(
                    descriptor, {member: manifest},
                )
                self.assertEqual(selected, {member})

    def test_selection_is_deduplicated(self):
        manifests = {
            "llamacpp-internal-cpu": (
                "[dependencies.compat]\nllamacpp = \"b10069\"\n"
            ),
            "llamacpp-internal-metal": (
                "[target.'cfg(macos)'.dependencies.compat]\n"
                "llamacpp = { version = \"b10069\", "
                "features = [\"backend-metal\"] }\n"
            ),
        }
        selected = selector.select_descriptor_members(
            "pkgs/c/compat.llamacpp.lua", manifests,
        )
        self.assertEqual(selected, {
            "llamacpp-internal-cpu", "llamacpp-internal-metal",
        })


if __name__ == "__main__":
    unittest.main()
