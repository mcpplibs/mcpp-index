#!/usr/bin/env python3
"""The rows a platform package's entry lists (`platform_rows`, mcpp SPEC-013 §14).

mcpp's target table answers its platform column from the engine's own data; for a
row it has no answer for, it reads the rows that the index's platform entries list.
That list is derived data: it is what the platform's own manifest serves, at the
entry's newest version, and is never written by hand.

    platform_rows.py write [pkgs/o/openkal-platform.lua ...]   derive and write the list
    platform_rows.py check [pkgs/*/*.lua ...]                  every list matches its manifest,
                                                               and no row has two platforms

Without files, both take the entries that list their rows; a new platform's entry
is named. An entry whose platform serves only the engine's rows lists none.

A row is listed when the manifest serves it: `[platform] targets`,
`[[platform.define]] triple`, and `[[platform.provider]] serves`, where a pattern
(`*-linux-musl`) stands for the rows it matches among the platform's own and the
engine's (mcpp's builtin.toml at the release the index's CI pins, $MCPP_VERSION).
`[platform.hosted] targets` are the rows its hosted arrangement applies to once the
platform is chosen, host rows among them; of those, only a row the engine does not
hold or holds as `planned` (`i686-linux-musl`) is listed, so the index never names
a platform for a host's own row.
The manifest is read from the GLOBAL archive of the newest version, at the entry's
`mcpp` path; archives are kept under $PLATFORM_ROWS_CACHE (default
~/.cache/mcpp-index-platform-rows), keyed by sha256.
"""
import fnmatch, hashlib, io, os, re, sys, tarfile, tomllib, urllib.request
from pathlib import Path

CACHE = Path(os.environ.get("PLATFORM_ROWS_CACHE", Path.home() / ".cache" / "mcpp-index-platform-rows"))
ENGINE_ROWS = "https://raw.githubusercontent.com/mcpp-community/mcpp/v{}/modules/toolchain-model/data/builtin.toml"


def mcpp_version() -> str:
    if v := os.environ.get("MCPP_VERSION"):
        return v
    m = re.search(r'^\s*MCPP_VERSION:\s*"([^"]+)"', Path(".github/workflows/validate.yml").read_text(), re.M)
    if not m:
        raise SystemExit("MCPP_VERSION is neither set nor found in .github/workflows/validate.yml")
    return m.group(1)


def engine_rows() -> dict[str, str]:
    """The rows of mcpp's built-in table and their tiers, at the release the index pins."""
    version = mcpp_version()
    path = CACHE / f"builtin-{version}.toml"
    if not path.is_file():
        CACHE.mkdir(parents=True, exist_ok=True)
        path.write_bytes(urllib.request.urlopen(ENGINE_ROWS.format(version), timeout=60).read())
    doc = tomllib.loads(path.read_text())
    return {d["triple"]: d.get("tier", "") for d in doc.get("platform", {}).get("define", []) if "triple" in d}
ROWS_LINE = re.compile(r'^(\s*)platform_rows\s*=\s*\{([^}]*)\},?\s*$', re.M)


def lua_field(text: str, key: str) -> str | None:
    m = re.search(rf'^\s*{key}\s*=\s*"([^"]*)"', text, re.M)
    return m.group(1) if m else None


def newest(text: str) -> tuple[str, str, str] | None:
    """(version, GLOBAL url, sha256) of the newest version under `linux`."""
    block = re.search(r'\blinux\s*=\s*\{(.*?)\n\s{8}\},', text, re.S)
    if not block:
        return None
    best = None
    for m in re.finditer(r'\["(\d+(?:\.\d+)*)"\]\s*=\s*\{(.*?)sha256\s*=\s*"([0-9a-f]{64})"', block.group(1), re.S):
        version, body, sha = m.groups()
        url = re.search(r'GLOBAL\s*=\s*"([^"]+)"', body) or re.search(r'url\s*=\s*"([^"]+)"', body)
        if not url:
            continue
        key = tuple(int(x) for x in version.split("."))
        if best is None or key > best[0]:
            best = (key, version, url.group(1), sha)
    return best[1:] if best else None


def archive(url: str, sha: str) -> bytes:
    path = CACHE / sha
    if path.is_file():
        return path.read_bytes()
    data = urllib.request.urlopen(url, timeout=120).read()
    if hashlib.sha256(data).hexdigest() != sha:
        raise SystemExit(f"{url}: sha256 differs from the entry's")
    CACHE.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    return data


def toml_1_0(text: str) -> str:
    """An inline table written over several lines (TOML 1.1) on one line, for tomllib."""
    out, depth, quote, comment = [], 0, None, False
    for ch in text:
        if comment:
            if ch == "\n":
                comment = False
                out.append(" " if depth else ch)
            continue
        if quote:
            out.append(ch)
            if ch == quote:
                quote = None
            continue
        if ch in "\"'":
            quote = ch
        elif ch == "#":
            comment = True
            continue
        elif ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
        elif ch == "\n" and depth:
            ch = " "
        out.append(ch)
    return re.sub(r",\s*}", " }", "".join(out))


def manifest_rows(data: bytes, pattern: str) -> list[str]:
    with tarfile.open(fileobj=io.BytesIO(data)) as tar:
        names = [n for n in tar.getnames() if fnmatch.fnmatch(n, pattern)]
        if not names:
            raise SystemExit(f"no manifest {pattern} in the archive")
        text = tar.extractfile(min(names, key=len)).read().decode()
    doc = tomllib.loads(toml_1_0(text))
    platform = doc.get("platform", {})
    rows = set(platform.get("targets", []))
    rows |= {d["triple"] for d in platform.get("define", []) if "triple" in d}
    engine = engine_rows()
    rows |= {r for r in platform.get("hosted", {}).get("targets", []) if engine.get(r, "planned") == "planned"}
    known = rows | set(engine)
    for p in platform.get("provider", []):
        for s in p.get("serves", []):
            rows |= {r for r in known if fnmatch.fnmatchcase(r, s)} if any(c in s for c in "*?[") else {s}
    return sorted(rows)


def derive(path: Path) -> list[str]:
    text = path.read_text()
    found = newest(text)
    pattern = lua_field(text, "mcpp")
    if not found or not pattern:
        raise SystemExit(f"{path}: no version with an archive, or no `mcpp` manifest path")
    version, url, sha = found
    return manifest_rows(archive(url, sha), pattern)


def written(text: str) -> list[str] | None:
    m = ROWS_LINE.search(text)
    return sorted(re.findall(r'"([^"]+)"', m.group(2))) if m else None


def write(path: Path) -> None:
    rows = derive(path)
    text = path.read_text()
    if not rows:
        # A platform whose rows are all the engine's states none: the column
        # answers only for a row the built-in table does not.
        if ROWS_LINE.search(text):
            text = re.sub(r"^[ \t]*platform_rows\s*=\s*\{[^}]*\},?[ \t]*\n", "", text, count=1, flags=re.M)
            path.write_text(text)
        print(f"{path}: no rows")
        return
    line = "    platform_rows = { " + ", ".join(f'"{r}"' for r in rows) + " },"
    if ROWS_LINE.search(text):
        text = ROWS_LINE.sub(line, text, count=1)
    else:
        text = re.sub(r'^(\s*type\s*=\s*"package",\s*)$', lambda m: m.group(1) + "\n" + line, text, count=1, flags=re.M)
    path.write_text(text)
    print(f"{path}: {len(rows)} rows")


def check(paths: list[Path]) -> int:
    claims: dict[str, list[str]] = {}
    fail = 0
    for path in paths:
        text = path.read_text()
        listed = written(text)
        if listed is None:
            continue
        name = f"{lua_field(text, 'namespace') or 'mcpp'}.{lua_field(text, 'name')}"
        for row in listed:
            claims.setdefault(row, []).append(name)
        derived = derive(path)
        if listed != derived:
            print(f"::error file={path}::platform_rows is {listed}; the manifest of the newest version serves {derived} "
                  f"(tools/platform_rows.py write {path})")
            fail = 1
    for row, who in sorted(claims.items()):
        if len(who) > 1:
            print(f"::error::{row} is listed by {', '.join(who)}: a row has one platform")
            fail = 1
    if not fail:
        print(f"platform_rows: {len(claims)} rows, each with one platform and matching its manifest")
    return fail


def main(argv: list[str]) -> int:
    if len(argv) < 2 or argv[1] not in ("write", "check"):
        print(__doc__)
        return 2
    paths = [Path(a) for a in argv[2:]]
    if not paths:
        # Every entry that lists its rows; a new platform is named (`write pkgs/<l>/<name>.lua`).
        paths = [p for p in sorted(Path("pkgs").glob("*/*.lua")) if written(p.read_text()) is not None]
    if argv[1] == "write":
        for p in paths:
            write(p)
        return 0
    return check(paths)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
