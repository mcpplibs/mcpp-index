#!/usr/bin/env python3
"""Temporary, explicitly approved exception for an unavailable upstream source.

Remove this policy once wellwei/libmysqlclient is accessible or migrated.
The updater plan keeps its error; excluded consumers are reported as untested.
"""
import argparse
import json
import os
from pathlib import Path

REASON = "User-approved temporary exception: wellwei/libmysqlclient is unavailable (GitHub 404); existing versions retained."
MEMBERS = {"libmysqlclient", "mysql-connector-cpp"}


def gate(plan, outcome):
    errors = [record for record in plan["packages"] if record["status"] == "error"]
    allowed = [record for record in errors if (
        record.get("id") == "compat:libmysqlclient"
        and record.get("repo") == "wellwei/libmysqlclient"
        and record.get("path") == "pkgs/c/compat.libmysqlclient.lua"
        and record.get("reason") == "HTTP Error 404: Not Found"
    )]
    if outcome not in {"success", "failure"} or len(errors) != len(allowed) or (outcome == "failure" and not allowed):
        raise RuntimeError("Unapproved scan failure: " + json.dumps(errors))
    if allowed:
        report(REASON + " Scan error remains in the plan; this is not a successful source check.")


def report(message):
    print("::warning::" + message)
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as stream:
            stream.write("\n- **NOT TESTED — source outage:** " + message + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("scan-gate", "members"))
    parser.add_argument("--plan", type=Path)
    parser.add_argument("--outcome")
    args = parser.parse_args()
    if args.command == "scan-gate":
        gate(json.loads(args.plan.read_text(encoding="utf-8")), args.outcome)
    else:
        selected = os.environ["MEMBERS"].split()
        skipped = [member for member in selected if member in MEMBERS]
        if skipped:
            report(REASON + " Untested consumers: " + ", ".join(skipped))
        with open(os.environ["GITHUB_ENV"], "a", encoding="utf-8") as stream:
            stream.write("MEMBERS=" + " ".join(member for member in selected if member not in MEMBERS) + "\n")


if __name__ == "__main__":
    main()
