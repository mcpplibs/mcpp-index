#!/usr/bin/env python3
"""Create update PRs in Actions and explicitly dispatch their CI with GITHUB_TOKEN."""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import time
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



def publish_status(repo, head, state):
    context = "xpkgindex-update/ci"
    current = json.loads(gh("api", f"repos/{repo}/commits/{head}/status"))
    if any(s["context"] == context and s["state"] == state for s in current["statuses"]):
        return
    descriptions = {
        "pending": "Waiting for candidate, consumer, site and openkal CI",
        "success": "All four CI workflows passed for this exact PR head",
        "failure": "An update CI workflow failed; inspect the actual runs",
        "error": "CI verification timed out; no successful result was recorded",
    }
    gh("api", "--method", "POST", f"repos/{repo}/statuses/{head}",
       "-f", f"state={state}", "-f", f"context={context}",
       "-f", f"description={descriptions[state]}", "-f",
       f"target_url=https://github.com/{repo}/actions/runs/{os.environ['GITHUB_RUN_ID']}")


def wait_for_ci(outcomes, repo, output, *, timeout=2400, interval=20):
    """Report real dispatched results on the PR; never infer success from dispatch."""
    pending = [r for r in outcomes if r.get("head") and r.get("ci")]
    deadline = time.monotonic() + timeout
    last = {}
    failed = False
    while pending:
        for record in pending[:]:
            runs = []
            for ci in record["ci"]:
                found = json.loads(gh(
                    "run", "list", "--repo", repo, "--workflow", ci["workflow"],
                    "--branch", record["branch"], "--commit", record["head"],
                    "--event", "workflow_dispatch", "--limit", "1", "--json",
                    "databaseId,status,conclusion,url,headSha"))
                if found and found[0]["headSha"] != record["head"]:
                    raise ValueError("dispatched CI head differs from the update PR")
                runs.append(found[0] if found else {"status": "queued"})
            state = "pending"
            if any(r["status"] == "completed" and r["conclusion"] != "success" for r in runs):
                state = "failure"
            elif all(r["status"] == "completed" for r in runs):
                number = record["url"].rsplit("/", 1)[-1]
                verify_pr(number, repo, record["head"])
                state = "success"
            elif time.monotonic() >= deadline:
                state = "error"
            if last.get(record["id"]) != state:
                publish_status(repo, record["head"], state)
                print(f"{record['id']} CI: {state}", flush=True)
                last[record["id"]] = state
                summary = os.environ.get("GITHUB_STEP_SUMMARY")
                if summary:
                    links = [f"[{ci['workflow']}]({run['url']})" for ci, run in zip(record["ci"], runs) if run.get("url")]
                    with open(summary, "a", encoding="utf-8") as stream:
                        stream.write(f"\n### {record['id']}: {state}\n\n" + " · ".join(links) + "\n")
            record["verification"] = state
            record["runs"] = runs
            if state != "pending":
                failed |= state != "success"
                pending.remove(record)
        output.write_text(json.dumps({"packages": outcomes}, indent=2) + "\n", encoding="utf-8")
        if pending:
            time.sleep(interval)
    return int(failed)


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
            if record.get("url"):
                number = record["url"].rsplit("/", 1)[-1]
                existing = json.loads(gh("api", f"repos/{repo}/pulls/{number}"))
                if record["status"] == "pending" and existing["user"]["login"] != "github-actions[bot]":
                    # Human PRs run ordinary pull_request CI; do not duplicate or dispatch their code.
                    outcomes.append({**record, "ci": [{"status": "ordinary-pr-ci"}]})
                    continue
            else:
                slug = re.sub(r"[^a-zA-Z0-9._-]", "-", record["id"])
                opened = json.loads(gh("pr", "list", "--repo", repo, "--state", "open",
                                       "--limit", "1000", "--json", "number,headRefName"))
                matches = [p for p in opened if p["headRefName"].startswith(f"auto/bump-{slug}-")]
                if len(matches) != 1:
                    raise ValueError("expected exactly one pending update PR")
                number = matches[0]["number"]
            pr = verify_pr(number, repo)
            outcomes.append({**record, "url": pr["html_url"], "head": pr["head"]["sha"],
                             "branch": pr["head"]["ref"], "ci": dispatch(pr, repo, record["id"])})
        except (ValueError, subprocess.CalledProcessError) as error:
            outcomes.append({**record, "status": "error", "reason": str(error)})
    output.write_text(json.dumps({"packages": outcomes}, indent=2) + "\n", encoding="utf-8")
    verification = wait_for_ci(outcomes, repo, output)
    print(output.read_text(encoding="utf-8"))
    return result.returncode or verification or int(any(r["status"] == "error" for r in outcomes))


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
