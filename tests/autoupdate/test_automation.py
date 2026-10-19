"""Exercise bot identity, exact-head validation and resumable CI dispatch."""
import copy
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import automation

REPO = "acme/index"
PR = {
    "number": 7, "state": "open", "user": {"login": "github-actions[bot]"},
    "html_url": f"https://github.com/{REPO}/pull/7",
    "base": {"repo": {"full_name": REPO}, "ref": "main", "sha": "base"},
    "head": {"repo": {"full_name": REPO}, "ref": "auto/bump-compat-foo-2.0.0", "sha": "head"},
}


class AutomationTests(unittest.TestCase):
    def setUp(self):
        self.environment = patch.dict(os.environ, {
            "DEFAULT_BRANCH": "main", "GITHUB_REPOSITORY": REPO, "GITHUB_SHA": "head",
        })
        self.environment.start()
        self.addCleanup(self.environment.stop)

    def test_verify_exact_head_and_single_descriptor(self):
        with patch.object(automation, "gh", side_effect=[
            json.dumps(PR), json.dumps([{"filename": "pkgs/c/compat.foo.lua"}]),
        ]):
            self.assertEqual(automation.verify_pr(7, REPO, "head"), PR)

    def test_reject_human_fork_closed_wrong_base_and_changed_head(self):
        variants = []
        for keys, value in [
            (("user", "login"), "Sunrisepeak"),
            (("head", "repo", "full_name"), "attacker/index"),
            (("base", "ref"), "release"),
            (("head", "sha"), "replacement"),
            (("state",), "closed"),
            (("head", "ref"), "feature/manual"),
        ]:
            pr = copy.deepcopy(PR)
            target = pr
            for key in keys[:-1]:
                target = target[key]
            target[keys[-1]] = value
            variants.append(pr)
        for pr in variants:
            with self.subTest(pr=pr), patch.object(automation, "gh", return_value=json.dumps(pr)):
                with self.assertRaises(ValueError):
                    automation.verify_pr(7, REPO, "head")

    def test_reject_workflow_changes(self):
        with patch.object(automation, "gh", side_effect=[
            json.dumps(PR), json.dumps([{"filename": ".github/workflows/validate.yml"}]),
        ]):
            with self.assertRaisesRegex(ValueError, "one package descriptor"):
                automation.verify_pr(7, REPO, "head")

    def test_partial_dispatch_is_resumable_and_targets_pr_head(self):
        calls = []
        completed = {"validate.yml"}

        def gh(*args):
            calls.append(args)
            if args[:2] == ("run", "list"):
                workflow = args[args.index("--workflow") + 1]
                self.assertEqual(args[args.index("--commit") + 1], "head")
                return '[{"databaseId": 12}]' if workflow in completed else '[]'
            self.assertEqual(args[args.index("--ref") + 1], PR["head"]["ref"])
            return ""

        with patch.object(automation, "gh", side_effect=gh):
            results = automation.dispatch(PR, REPO, "compat:foo")
        self.assertEqual([r["status"] for r in results], ["existing"] + ["dispatched"] * 3)
        dispatched = [c for c in calls if c[:2] == ("workflow", "run")]
        self.assertEqual(len(dispatched), 3)
        self.assertIn("package=compat:foo", dispatched[0])
        self.assertIn("update_pr=7", dispatched[2])

    def test_moved_main_refuses_propose(self):
        with tempfile.TemporaryDirectory() as directory:
            plan = Path(directory) / "plan.json"
            plan.write_text(json.dumps({"base_commit": "old"}))
            with patch.object(automation, "gh", return_value="head"), patch.object(automation.subprocess, "run") as run:
                with self.assertRaisesRegex(ValueError, "moved"):
                    automation.propose(plan, Path(directory) / "report.json")
                run.assert_not_called()

    def test_created_pr_and_pending_retry_both_receive_ci(self):
        for state in ("created", "pending"):
            with self.subTest(state=state), tempfile.TemporaryDirectory() as directory:
                plan = Path(directory) / "plan.json"
                plan.write_text(json.dumps({"base_commit": "head"}))
                output = Path(directory) / "automation-report.json"

                def run(args, check):
                    self.assertEqual(args[2:4], ["xpkgindex_update", "propose"])
                    Path(args[-1]).write_text(json.dumps({"packages": [
                        {"id": "compat:foo", "status": state, "url": PR["html_url"]},
                        {"id": "compat:bar", "status": "error", "reason": "resource changed"},
                    ]}))
                    return subprocess.CompletedProcess(args, 1)

                def gh(*args):
                    if args[:2] == ("pr", "list"):
                        return json.dumps([{"number": 7, "headRefName": PR["head"]["ref"]}])
                    return "head"

                with patch.object(automation, "gh", side_effect=gh), \
                     patch.object(automation.subprocess, "run", side_effect=run), \
                     patch.object(automation, "verify_pr", return_value=PR), \
                     patch.object(automation, "dispatch", return_value=[{"status": "dispatched"}]) as dispatch:
                    self.assertEqual(automation.propose(plan, output), 1)
                dispatch.assert_called_once_with(PR, REPO, "compat:foo")
                result = json.loads(output.read_text())["packages"]
                self.assertEqual(result[0]["ci"], [{"status": "dispatched"}])
                self.assertEqual(result[1]["status"], "error")
