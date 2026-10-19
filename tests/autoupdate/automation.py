#!/usr/bin/env python3
"""Create update PRs in Actions and explicitly dispatch their CI with GITHUB_TOKEN."""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path


def gh(*args):
    return subprocess.check_output(["gh", *args], text=True).strip()


def verify_pr(number, repo, sha=None):
    if not str(number).isdigit():
        raise ValueError("update_pr must be a PR number")
    pr = json.loads(gh("api", f"repos/{repo}/pulls/{number}"))
    if not (
        pr["state"] == "open"
        and pr["user"]["login"] == "github-actions[bot]"
        and pr["head"]["repo"]["full_name"] == repo
        and pr["base"]["repo"]["full_name"] == repo
        and pr["base"]["ref"] == os.environ["DEFAULT_BRANCH"]
        and re.fullmatch(r"auto/bump-[a-zA-Z0-9._-]+", pr["head"]["ref"])
        and (sha is None or pr["head"]["sha"] == sha)
    ):
        raise ValueError("expected an open bot update PR in this repository at the requested head")
    files = json.loads(gh("api", f"repos/{repo}/pulls/{number}/files?per_page=100"))
    if len(files) != 1 or not re.fullmatch(r"pkgs/[^/]+/[^/]+\.lua", files[0]["filename"]):
        raise ValueError("an update PR must change exactly one package descriptor")
    return pr


def dispatch(pr, repo, identity):
    """Resume missing dispatches after partial API failure without duplicating runs."""
    workflows = {
        "validate.yml": {"update_pr": str(pr["number"])},
        "xpkgindex-update.yml": {"package": identity},
        "site-check.yml": {},
        "openkal-compat.yml": {"update_pr": str(pr["number"])},
    }
    results = []
    for workflow, inputs in workflows.items():
        previous = json.loads(gh(
            "run", "list", "--repo", repo, "--workflow", workflow,
            "--branch", pr["head"]["ref"], "--commit", pr["head"]["sha"],
            "--event", "workflow_dispatch", "--limit", "1", "--json", "databaseId"))
        if previous:
            results.append({"workflow": workflow, "status": "existing", "run": previous[0]["databaseId"]})
            continue
        args = ["workflow", "run", workflow, "--repo", repo, "--ref", pr["head"]["ref"]]
        for key, value in inputs.items():
            args.extend(["-f", f"{key}={value}"])
        gh(*args)
        results.append({"workflow": workflow, "status": "dispatched", "head": pr["head"]["sha"]})
    return results


def propose(plan, output):
    repo = os.environ["GITHUB_REPOSITORY"]
    base = os.environ["DEFAULT_BRANCH"]
    report = output.with_name("proposals.json")
    fixed = json.loads(plan.read_text(encoding="utf-8"))
    remote = gh("api", f"repos/{repo}/git/ref/heads/{base}", "--jq", ".object.sha")
    if remote != fixed["base_commit"] or remote != os.environ["GITHUB_SHA"]:
        raise ValueError("default branch moved since scanning; rerun with a fresh plan")
    # The pinned CLI owns append-only editing, PR limits and duplicate detection.
    result = subprocess.run([
        sys.executable, "-m", "xpkgindex_update", "propose", "--plan", str(plan),
        "--base", base, "--output", str(report),
    ], check=False)
    proposals = json.loads(report.read_text(encoding="utf-8"))
    outcomes = []
    for record in proposals["packages"]:
        if record["status"] not in {"created", "pending"}:
            outcomes.append(record)
            continue
        try:
            if record["status"] == "created":
                number = record["url"].rsplit("/", 1)[-1]
            else:
                slug = re.sub(r"[^a-zA-Z0-9._-]", "-", record["id"])
                opened = json.loads(gh("pr", "list", "--repo", repo, "--state", "open",
                                       "--limit", "1000", "--json", "number,headRefName"))
                matches = [p for p in opened if p["headRefName"].startswith(f"auto/bump-{slug}-")]
                if len(matches) != 1:
                    raise ValueError("expected exactly one pending update PR")
                number = matches[0]["number"]
            pr = verify_pr(number, repo)
            outcomes.append({**record, "url": pr["html_url"], "ci": dispatch(pr, repo, record["id"])})
        except (ValueError, subprocess.CalledProcessError) as error:
            outcomes.append({**record, "status": "error", "reason": str(error)})
    output.write_text(json.dumps({"packages": outcomes}, indent=2) + "\n", encoding="utf-8")
    print(output.read_text(encoding="utf-8"))
    return result.returncode or int(any(r["status"] == "error" for r in outcomes))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    create = commands.add_parser("propose")
    create.add_argument("--plan", type=Path, required=True)
    create.add_argument("--output", type=Path, required=True)
    verify = commands.add_parser("verify")
    verify.add_argument("--pr", required=True)
    args = parser.parse_args()
    if args.command == "verify":
        pr = verify_pr(args.pr, os.environ["GITHUB_REPOSITORY"], os.environ["GITHUB_SHA"])
        print(pr["base"]["sha"])
        return 0
    return propose(args.plan.resolve(), args.output.resolve())


if __name__ == "__main__":
    raise SystemExit(main())
