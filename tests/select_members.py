#!/usr/bin/env python3
"""The workspace members a change to some descriptors reaches.

A descriptor is a package identity, `(namespace, name)`. A member is reached
when the dependency graph it declares contains a changed identity: its own
manifest names it, or names a package of this index that depends on it, at any
distance. Both ends are read as what they declare and matched by identity:

  * a member's manifest, as TOML, with mcpp's reading of nesting -- a table
    naming a source (`path`, `version`, `git`, `workspace`) is a dependency,
    any other table a namespace, and a bare key is in `mcpplibs`;
  * a descriptor, through tests/descriptor_identities.lua: its identity, the
    `deps` it states, and -- for a package that builds from the manifest in its
    archive -- where that manifest is. The manifest is read at the archive's
    ref from raw.githubusercontent.com, or from the archive itself when the
    archive is a release asset rather than the repository's tree; its
    dependencies, and those of the manifests it reaches by `path`, are the
    package's remaining edges. An archive is pinned by its sha256, so what was
    read once is kept in a cache file (`--cache`) and read again only for an
    archive the cache does not hold.

The selection this replaces searched each member's manifest for the
descriptor's short name as a substring: `pkgs/o/os.lua` selected 113 of 205
members (`boost-*`, `macos`, `cfg(os = ...)`, `posix`), and `compat.openssl`
missed every member that reaches it through asio or curl.

What it cannot see is a manifest it cannot read: an archive that is not on
GitHub, or a fetch that fails three times. Each is reported as a warning, and
the scheduled full run covers that edge, as it covers two changes that break
each other.

Usage: select_members.py [--base <rev>] [--cache <file>] <descriptor.lua>...
    prints the selected member directory names on one line, space separated;
    a descriptor not on disk is read at <rev> (a deletion); a descriptor no
    member reaches is noted on stderr.
"""
from __future__ import annotations

import argparse
import concurrent.futures
import io
import json
import posixpath
import re
import subprocess
import sys
import tarfile
import tempfile
import time
import tomllib
import urllib.error
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_NAMESPACE = "mcpplibs"                    # mcpp: `cmdline = "0.0.2"` is (mcpplibs, cmdline)
SOURCE_KEYS = ("path", "version", "git", "workspace")   # mcpp's spec-vs-namespace discriminator

Identity = tuple[str, str]


# ── What a manifest declares ────────────────────────────────────────────────

def is_spec(value) -> bool:
    if isinstance(value, str):
        return True
    return isinstance(value, dict) and any(k in value for k in SOURCE_KEYS)


def dependency_tables(manifest: dict):
    """Every `*dependencies` table of a manifest: [dependencies],
    [dev-dependencies], [build-dependencies], [workspace.dependencies], and
    the same under [target.<cfg>] and [feature-deps.<feature>]."""
    for key, value in manifest.items():
        if not isinstance(value, dict):
            continue
        if key.endswith("dependencies"):
            yield value
        else:
            yield from dependency_tables(value)


def declared(table: dict, namespace: str | None = None):
    """(selector, spec) for every dependency a table declares. A selector is
    the namespace path and the key joined by dots, as mcpp spells it."""
    for key, value in table.items():
        selector = key if namespace is None else f"{namespace}.{key}"
        if is_spec(value):
            yield selector, value
        elif isinstance(value, dict):
            yield from declared(value, selector)


def platform_refs(manifest: dict):
    """(selector, spec) for the package references mcpp SPEC-013 states outside
    the dependency tables: `platform` under [target.<selector>],
    [workspace.target.<selector>] and [host], and a platform package's own
    [platform.layers], [platform.hosted.layers] and [platform.tools]. A
    reference is `"<name>@<version>"`, a table naming a source, or `"none"` /
    `false` (no package)."""
    def ref(value):
        if isinstance(value, str) and value != "none" and not value.startswith("path:"):
            return value, value
        if isinstance(value, dict) and is_spec(value) and isinstance(value.get("name"), str):
            return value["name"], value
        return None
    def platform_of(table):
        if isinstance(table, dict) and (r := ref(table.get("platform"))):
            yield r
    for scope in (manifest, manifest.get("workspace", {})):
        if not isinstance(scope, dict):
            continue
        for selector_table in (scope.get("target") or {}).values():
            yield from platform_of(selector_table)
    yield from platform_of(manifest.get("host"))
    platform = manifest.get("platform")
    if isinstance(platform, dict):
        for table in (platform.get("layers"), (platform.get("hosted") or {}).get("layers"),
                      platform.get("tools")):
            for value in (table or {}).values():
                if (r := ref(value)):
                    yield r


def resolve(spelling: str, identities: set[Identity]) -> set[Identity]:
    """A spelling of a dependency (`os`, `compat.openssl`, `compat:openssl@3`,
    `mcpplibs.mwrap.ffmpeg`), as the identities of this index it can name."""
    spelling = spelling.split("@", 1)[0]
    if ":" in spelling:
        return {tuple(spelling.split(":", 1))} & identities
    found = {(DEFAULT_NAMESPACE, spelling)} & identities
    parts = spelling.split(".")
    for i in range(1, len(parts)):
        candidate = (".".join(parts[:i]), ".".join(parts[i:]))
        if candidate in identities:
            found.add(candidate)
    return found


# ── What the index declares ─────────────────────────────────────────────────

class Index:
    def __init__(self, rows: list[str]):
        self.identity_of: dict[str, Identity] = {}
        self.deps: dict[Identity, set[str]] = {}
        self.manifests: dict[Identity, set[str]] = {}
        for row in rows:
            path, ns, name, deps, manifests = (row.split("\t") + [""])[:5]
            ident = (ns, name)
            self.identity_of[path] = ident
            self.deps.setdefault(ident, set()).update(d for d in deps.split(",") if d)
            self.manifests.setdefault(ident, set()).update(m for m in manifests.split() if m)
        self.identities = set(self.deps)


def dump(files: list[str], cwd: Path = ROOT) -> list[str]:
    if not files:
        return []
    out = subprocess.run(["lua5.4", str(ROOT / "tests/descriptor_identities.lua"), *files],
                         check=True, capture_output=True, text=True, cwd=cwd).stdout
    return out.splitlines()


def deleted_identities(paths: list[str], base: str) -> dict[str, Identity]:
    """Descriptors removed by the change, read as they were at `base`."""
    out = {}
    with tempfile.TemporaryDirectory() as tmp:
        for path in paths:
            text = subprocess.run(["git", "show", f"{base}:{path}"], cwd=ROOT,
                                  capture_output=True, text=True)
            if text.returncode != 0:
                continue
            copy = Path(tmp) / Path(path).name
            copy.write_text(text.stdout)
            for row in dump([str(copy)], cwd=Path(tmp)):
                _, ns, name = row.split("\t")[:3]
                out[path] = (ns, name)
    return out


# ── Manifests inside archives ───────────────────────────────────────────────

ARCHIVE = re.compile(r"https://github\.com/([^/]+)/([^/]+)/(?:"
                     r"archive/(?:refs/tags/)?(?P<archive>.+?)\.(?:tar\.gz|tgz|zip)"
                     r"|releases/download/(?P<release>[^/]+)/)")


def raw_location(location: str) -> tuple[str, str] | None:
    """`<GLOBAL archive url>#<manifest path>` -> (the raw url of the archive's
    ref, the manifest's path inside it), or None for an archive this cannot
    address."""
    url, _, inside = location.partition("#")
    m = ARCHIVE.match(url)
    if not m:
        return None
    ref = m.group("archive") or m.group("release")
    return f"https://raw.githubusercontent.com/{m.group(1)}/{m.group(2)}/{ref}", inside


def fetch(url: str) -> bytes:
    """The body at `url`; a 404 at once, any other failure after three tries."""
    for attempt in range(3):
        try:
            with urllib.request.urlopen(url, timeout=60) as response:
                return response.read()
        except urllib.error.HTTPError as e:
            if e.code == 404 or attempt == 2:
                raise
        except OSError:
            if attempt == 2:
                raise
        time.sleep(2 * (attempt + 1))
    raise AssertionError("unreachable")


def archive_files(data: bytes) -> dict[str, bytes]:
    """The manifests of an archive, by path below its top-level directory."""
    out = {}
    if data[:2] == b"PK":
        with zipfile.ZipFile(io.BytesIO(data)) as z:
            for name in z.namelist():
                if name.endswith("mcpp.toml") and "/" in name:
                    out[name.split("/", 1)[1]] = z.read(name)
        return out
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:*") as t:
        for member in t:
            if member.isfile() and member.name.endswith("mcpp.toml") and "/" in member.name:
                out[member.name.split("/", 1)[1]] = t.extractfile(member).read()
    return out


def merge(into: dict, more: dict) -> None:
    for key, value in more.items():
        if isinstance(value, dict) and isinstance(into.get(key), dict):
            merge(into[key], value)
        else:
            into[key] = value


def loads(text: str) -> dict:
    """A manifest, as mcpp reads one: a table may be opened twice, and the
    second opening adds to the first (TOML forbids it; published manifests --
    openkal-llvm-runtime 0.7.0 to 0.9.7 among them -- carry it)."""
    try:
        return tomllib.loads(text)
    except tomllib.TOMLDecodeError:
        pass
    out: dict = {}
    chunk: list[str] = []
    for line in text.splitlines(keepends=True) + ["[]"]:
        if line.lstrip().startswith("[") and not line.lstrip().startswith("[["):
            merge(out, tomllib.loads("".join(chunk)))
            chunk = []
        chunk.append(line)
    return out


def selectors_of(start: str, read) -> set[str]:
    """Every dependency the manifest `start` declares, with those of the
    manifests it reaches by `path` inside the same archive; `read(path)` is a
    manifest's text."""
    selectors: set[str] = set()
    seen, todo = {start}, [start]
    while todo:
        inside = todo.pop()
        manifest = loads(read(inside))
        selectors.update(selector for selector, _ in platform_refs(manifest))
        for table in dependency_tables(manifest):
            for selector, spec in declared(table):
                selectors.add(selector)
                if isinstance(spec, dict) and isinstance(spec.get("path"), str):
                    nxt = posixpath.normpath(posixpath.join(posixpath.dirname(inside),
                                                            spec["path"], "mcpp.toml"))
                    if not nxt.startswith("..") and nxt not in seen:   # inside the archive
                        seen.add(nxt)
                        todo.append(nxt)
    return selectors


class NoManifest(Exception):
    """No manifest to read: the archive holds none where an optional one would
    be, or the url is a single file rather than an archive."""


def archive_selectors(location: str, get=fetch) -> set[str]:
    """The dependencies stated by the manifest at `location` and the manifests
    it reaches: from the repository's tree at the archive's ref, or, when the
    tree does not hold it (a release asset), from the archive. A manifest
    marked optional (`#?mcpp.toml`) that is not there raises NoManifest."""
    url, _, inside = location.partition("#")
    optional = inside.startswith("?")
    if not re.search(r"\.(tar\.gz|tgz|tar\.xz|tar\.bz2|zip)$", url):
        raise NoManifest(location)   # a single file: install() writes the manifest
    raw = raw_location(f"{url}#{inside.lstrip('?')}")
    if raw is None:
        raise ValueError(f"not a GitHub archive: {url}")
    prefix, start = raw
    try:
        return selectors_of(start, lambda path: get(f"{prefix}/{path}").decode())
    except urllib.error.HTTPError as e:
        if e.code != 404:
            raise
    files = archive_files(get(url))
    if start not in files:
        raise NoManifest(location)   # optional, or written by install() (marzer.tomlplusplus)
    return selectors_of(start, lambda path: files[path].decode())


# ── The selection ───────────────────────────────────────────────────────────

def members() -> list[Path]:
    workspace = tomllib.loads((ROOT / "mcpp.toml").read_text())["workspace"]["members"]
    return [ROOT / m for m in workspace if (ROOT / m / "mcpp.toml").is_file()]


def member_selectors(member: Path) -> set[str]:
    manifest = tomllib.loads((member / "mcpp.toml").read_text())
    return ({selector for table in dependency_tables(manifest) for selector, _ in declared(table)}
            | {selector for selector, _ in platform_refs(manifest)})


class Graph:
    """Edges of this index's packages; an archive's manifest is read once."""

    def __init__(self, index: Index, get=fetch, warn=lambda message: None,
                 cache: dict[str, list[str]] | None = None):
        self.index, self.get, self.warn = index, get, warn
        self.cache = cache if cache is not None else {}
        self.read: dict[str, set[str] | None] = {k: set(v) for k, v in self.cache.items()}
        self.edges: dict[Identity, set[Identity]] = {}

    def _read(self, location: str) -> set[str] | None:
        try:
            return archive_selectors(location, self.get)
        except NoManifest:
            return set()
        except Exception as e:   # noqa: BLE001 -- every failure is the same fact: an unseen edge
            self.warn(f"::warning::cannot read the manifest {location}: {e}")
            return None

    def prefetch(self, idents: set[Identity]) -> None:
        """Read, in parallel, the archive manifests of `idents` not read yet."""
        todo = sorted({loc for i in idents for loc in self.index.manifests.get(i, ())} - set(self.read))
        with concurrent.futures.ThreadPoolExecutor(16) as pool:
            for loc, selectors in zip(todo, pool.map(self._read, todo)):
                self.read[loc] = selectors
                if selectors is not None:
                    self.cache[loc] = sorted(selectors)

    def of(self, ident: Identity) -> set[Identity]:
        if ident not in self.edges:
            self.prefetch({ident})
            spellings = set(self.index.deps.get(ident, ()))
            for loc in self.index.manifests.get(ident, ()):
                spellings |= self.read[loc] or set()
            self.edges[ident] = {t for s in spellings for t in resolve(s, self.index.identities)} - {ident}
        return self.edges[ident]

    def closure(self, start: set[Identity]) -> set[Identity]:
        seen, todo = set(start), list(start)
        while todo:
            for nxt in self.of(todo.pop()):
                if nxt not in seen:
                    seen.add(nxt)
                    todo.append(nxt)
        return seen


def select(changed: list[str], base: str | None = None, get=fetch,
           warn=lambda message: print(message, file=sys.stderr),
           cache: dict[str, list[str]] | None = None) -> tuple[list[str], list[str]]:
    files = sorted(str(p.relative_to(ROOT)) for p in ROOT.glob("pkgs/*/*.lua"))
    index = Index(dump(files))
    changed_ids: dict[str, Identity] = {p: index.identity_of[p] for p in changed if p in index.identity_of}
    missing = [p for p in changed if p not in index.identity_of]
    if missing and base:
        changed_ids.update(deleted_identities(missing, base))
    for path in changed:
        if path not in changed_ids:
            warn(f"::warning::{path}: no identity read; no member selected for it")

    graph = Graph(index, get, warn, cache)
    direct = {m: {t for s in member_selectors(m) for t in resolve(s, index.identities)}
              for m in members()}
    # Read the archive manifests the members can reach a level at a time, each
    # level in parallel, before walking.
    reachable, frontier = set(), set().union(*direct.values())
    while frontier:
        graph.prefetch(frontier)
        reachable |= frontier
        frontier = {n for i in frontier for n in graph.of(i)} - reachable

    selected: list[str] = []
    reached: set[str] = set()
    for member, ids in direct.items():
        hits = graph.closure(ids) & set(changed_ids.values())
        if hits:
            selected.append(member.name)
            reached |= {p for p, i in changed_ids.items() if i in hits}
    return selected, [p for p in changed if p not in reached]


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--base")
    parser.add_argument("--cache", type=Path)
    parser.add_argument("descriptors", nargs="*")
    args = parser.parse_args(argv)
    cache = json.loads(args.cache.read_text()) if args.cache and args.cache.is_file() else {}
    selected, unreached = select(args.descriptors, args.base, cache=cache)
    if args.cache:
        args.cache.write_text(json.dumps(cache, indent=0, sort_keys=True))
    for path in unreached:
        print(f"note: no workspace member exercises {path}", file=sys.stderr)
    print(" ".join(selected))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
