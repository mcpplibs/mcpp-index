#!/usr/bin/env python3
"""Every internal link of a generated site resolves to a page or a file.

    python3 tools/site/check_links.py <site-dir>

Resolves each relative href/src of every HTML page the way a static host
does — a directory serves its index.html — and lists those that land on
nothing. Exit 1 when there is one.

The site build reports what it knows to be wrong as warnings; this checks the
output instead, so a dead link fails the pull request whichever layer — a
guide, a template, the plugin — produced it. External URLs are not fetched.
"""

from __future__ import annotations

import os
import re
import sys
import urllib.parse

LINK = re.compile(r'(?:href|src)="([^"]+)"')
EXTERNAL = ("http://", "https://", "//", "#", "mailto:", "data:", "javascript:")


def dead_links(site: str) -> dict[str, list[str]]:
    dead: dict[str, list[str]] = {}
    for dirpath, _, files in os.walk(site):
        for name in files:
            if not name.endswith(".html"):
                continue
            page = os.path.join(dirpath, name)
            with open(page, encoding="utf-8") as f:
                hrefs = LINK.findall(f.read())
            for href in sorted(set(hrefs)):
                if href.startswith(EXTERNAL):
                    continue
                path = urllib.parse.unquote(href.split("#")[0].split("?")[0])
                if not path:
                    continue
                target = os.path.normpath(os.path.join(dirpath, path))
                if not (os.path.isfile(target)
                        or os.path.isfile(os.path.join(target, "index.html"))):
                    dead.setdefault(os.path.relpath(page, site), []).append(href)
    return dead


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__.strip().splitlines()[2].strip(), file=sys.stderr)
        return 2
    dead = dead_links(sys.argv[1])
    for page in sorted(dead):
        for href in dead[page]:
            print(f"::error::{page}: dead link {href}")
    total = sum(len(v) for v in dead.values())
    print(f"{total} dead link(s) on {len(dead)} page(s)")
    return 1 if dead else 0


if __name__ == "__main__":
    sys.exit(main())
