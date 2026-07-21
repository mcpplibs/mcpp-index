#!/usr/bin/env python3
"""Read-only audit of a llama.cpp upstream snapshot.
Produces a deterministic JSON report of source sets, registry macros,
Metal shader inputs, platform links, dialect exceptions, and public-header
hashes.  Never edits a package descriptor.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from collections import OrderedDict
from pathlib import Path


# ── helpers ────────────────────────────────────────────────────────────────

def sha256_file(path: str | Path) -> str:
    """Return the lowercase hex SHA-256 of *path*."""
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def safe_extract_tar(archive, destination: str):
    """Extract *archive* (file-object) into *destination*, rejecting any
    member whose resolved path would escape *destination*."""
    import tarfile
    dest = os.path.realpath(destination)
    os.makedirs(dest, exist_ok=True)
    with tarfile.open(fileobj=archive, mode='r:*') as tf:
        for member in tf.getmembers():
            resolved = os.path.realpath(os.path.join(dest, member.name))
            if os.path.commonpath([dest, resolved]) != dest:
                raise ValueError(
                    f"archive member escapes extraction directory: {member.name}")
        # Re-open for safe extraction
        archive.seek(0)
        with tarfile.open(fileobj=archive, mode='r:*') as tf2:
            tf2.extractall(dest, filter='data')


# ── CMake extraction (balanced-paren, multi-line) ──────────────────────────

def _tokenize_cmake(text: str):
    """Yield (type, value) tokens from *text* ignoring comments."""
    # remove line comments (very basic – good enough for the cmake subsets we see)
    lines = []
    for ln in text.splitlines():
        idx = ln.find('#')
        lines.append(ln[:idx] if idx >= 0 else ln)
    text = ' '.join(lines)
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        if c.isspace():
            i += 1
            continue
        if c == '"':
            j = i + 1
            while j < n:
                if text[j] == '\\':
                    j += 2
                elif text[j] == '"':
                    j += 1
                    break
                else:
                    j += 1
            yield ('STR', text[i+1:j-1])
            i = j
            continue
        if c in '()':
            yield (c, c)
            i += 1
            continue
        # bare word / variable reference
        j = i
        while j < n and not text[j].isspace() and text[j] not in '()"':
            j += 1
        yield ('WORD', text[i:j])
        i = j


def extract_cmake_call(text: str, callee: str, first_arg: str | None = None
                       ) -> tuple[str | None, list[str]]:
    """Return (name, [arg...]) for the first *callee*(name arg...)."""
    tokens = list(_tokenize_cmake(text))
    for i, (typ, val) in enumerate(tokens):
        if typ != 'WORD' or val != callee: continue
        if i + 1 >= len(tokens) or tokens[i + 1] != ('(', '('): continue
        depth = 1
        j = i + 2
        args: list[str] = []
        while j < len(tokens) and depth > 0:
            typ2, val2 = tokens[j]
            if typ2 == '(':
                depth += 1
                if depth == 1:  j += 1; continue
            elif typ2 == ')':
                depth -= 1
                if depth == 0: break
            if depth == 1 and typ2 in ('WORD', 'STR'): args.append(val2)
            j += 1
        if not args: continue
        if first_arg is not None and args[0] != first_arg: continue
        return (args[0], args[1:])
    return (None, [])


# ── source collection ─────────────────────────────────────────────────────

def _find_files(root: str, ext: str) -> list[str]:
    """Walk *root* and return relative paths of files matching *ext*."""
    found = []
    for dirpath, _dirnames, filenames in os.walk(root):
        for fn in filenames:
            if fn.endswith(ext):
                rel = os.path.relpath(os.path.join(dirpath, fn), root)
                found.append(rel)
    return sorted(found)


def _expand_glob(root: str, pattern: str) -> list[str]:
    """Expand a single file-level GLOB pattern relative to *root*."""
    directory = os.path.dirname(pattern)
    glob_pat = os.path.basename(pattern)
    full_dir = os.path.join(root, directory)
    if not os.path.isdir(full_dir):
        return []
    import fnmatch
    result = []
    for fn in sorted(os.listdir(full_dir)):
        if fnmatch.fnmatch(fn, glob_pat):
            result.append(os.path.join(directory, fn))
    return sorted(result)


# ── public API ─────────────────────────────────────────────────────────────

def collect_snapshot(
    root: str,
    tag: str,
    commit: str,
    url: str,
    archive_sha256: str,
) -> dict:
    """Walk a local llama.cpp checkout at *root* and produce the audit report."""
    cmake_path = os.path.join(root, 'CMakeLists.txt')
    if not os.path.isfile(cmake_path):
        raise FileNotFoundError(f"CMakeLists.txt not found at {cmake_path}")
    with open(cmake_path, 'r') as f:
        cmake_text = f.read()

    # ── source sets (from CMake add_library / ggml_add_backend_library) ──
    _, ggml_base = extract_cmake_call(cmake_text, 'add_library', 'ggml-base')
    _, ggml_registry = extract_cmake_call(cmake_text, 'add_library', 'ggml')
    _, ggml_metal = extract_cmake_call(cmake_text, 'ggml_add_backend_library', 'ggml-metal')
    _, llama = extract_cmake_call(cmake_text, 'add_library', 'llama')

    # Expand GLOB in llama sources
    llama_expanded: list[str] = []
    model_files: list[str] = []
    for src in llama:
        if '${LLAMA_MODELS_SOURCES}' in src or src.endswith('.cpp') is False and '*' in src:
            # Extract GLOB pattern from CMakeLists.txt
            _, glob_args = extract_cmake_call(cmake_text, 'file', 'GLOB')
            if glob_args and len(glob_args) >= 2:
                pattern = glob_args[1]
                model_files = _expand_glob(root, pattern)
        elif src.endswith('.cpp') or src.endswith('.c'):
            llama_expanded.append(src)

    # CPU sources (ggml-cpu target extraction from actual upstream CMake)
    _, cpu_common = extract_cmake_call(cmake_text, 'add_library', 'ggml-cpu')
    if not cpu_common:
        # Try alternative name patterns used in different upstream versions
        _, cpu_common = extract_cmake_call(cmake_text, 'add_library', 'ggml')
    # Fallback: scan ggml/src for cpu-backend-impl source files
    cpu_common = cpu_common if cpu_common else [
        os.path.relpath(p, root)
        for p in Path(root).rglob('ggml-cpu*.cpp')
    ]
    cpu_arch_x86 = [os.path.relpath(p, root) for p in Path(root).rglob('ggml-cpu-amx*.cpp')]
    cpu_arch_arm = [os.path.relpath(p, root) for p in Path(root).rglob('ggml-cpu-neon*.cpp')]

    # ── registry macros ──
    registry: dict[str, str] = {}
    reg_path = os.path.join(root, 'ggml-backend-reg.cpp')
    if os.path.isfile(reg_path):
        with open(reg_path, 'r') as f:
            reg_text = f.read()
        for macro in ['GGML_USE_CPU', 'GGML_USE_METAL', 'GGML_USE_CUDA',
                       'GGML_USE_VULKAN', 'GGML_USE_SYCL', 'GGML_USE_CANN']:
            pat = re.compile(
                r'#ifdef\s+' + macro + r'\s+.*?register_backend\((\w+)\(\)\)',
                re.DOTALL)
            m = pat.search(reg_text)
            if m:
                registry[macro] = m.group(1)

    # ── Metal shader inputs ──
    metal_dir = os.path.join(root, 'ggml', 'src', 'ggml-metal')
    metal_inputs: list[str] = []
    if os.path.isdir(metal_dir):
        metal_patterns = ['ggml-common.h', 'ggml-metal.metal', 'ggml-metal-impl.h']
        for pat in metal_patterns:
            # Check both locations (some versions have ggml-common.h in parent dir)
            for base in [metal_dir, os.path.dirname(metal_dir)]:
                full = os.path.join(base, pat)
                if os.path.isfile(full):
                    rel = os.path.relpath(full, root)
                    if rel not in metal_inputs:
                        metal_inputs.append(rel)
                    break
    metal_inputs.sort()

    # ── Metal frameworks ──
    metal_frameworks = ['Foundation', 'Metal', 'MetalKit']

    # ── C++20 dialect exceptions (model files requiring C++20 for concepts) ──
    cpp20_exceptions = []
    for p in ['src/models/dflash.cpp', 'src/models/eagle3.cpp', 'src/models/t5.cpp']:
        if os.path.isfile(os.path.join(root, p)):
            cpp20_exceptions.append(p)

    # ── Platform links ──
    platform_links = {'windows_cpu': ['advapi32']}

    # ── Public header hashes ──
    header_hashes = {}
    for hdr in ['llama.h', 'ggml.h', 'ggml-cpu.h']:
        p = os.path.join(root, 'include', hdr)
        if os.path.isfile(p):
            header_hashes[hdr] = sha256_file(p)

    return OrderedDict([
        ('schema', 1),
        ('upstream', OrderedDict([
            ('tag', tag),
            ('commit', commit),
            ('url', url),
            ('sha256', archive_sha256),
        ])),
        ('sources', OrderedDict([
            ('ggml_base', sorted(set(ggml_base))),
            ('ggml_registry', sorted(set(ggml_registry))),
            ('ggml_cpu_common', sorted(set(
                [s for s in cpu_common if s not in ggml_base]))),
            ('ggml_cpu_x86', sorted(set(cpu_arch_x86))),
            ('ggml_cpu_arm', sorted(set(cpu_arch_arm))),
            ('llama_core', sorted(set(llama_expanded))),
            ('models', sorted(set(model_files))),
            ('ggml_metal', sorted(set(ggml_metal))),
        ])),
        ('registry', registry),
        ('metal', OrderedDict([
            ('frameworks', metal_frameworks),
            ('shader_inputs', metal_inputs),
        ])),
        ('dialect_exceptions', OrderedDict([
            ('c++20', cpp20_exceptions),
        ])),
        ('platform_links', platform_links),
        ('public_header_sha256', header_hashes),
    ])


def compare_reports(old: dict, new: dict) -> list[str]:
    """Return a list of human-readable differences between two reports."""
    diffs = []
    for key in ['sources', 'registry', 'metal', 'dialect_exceptions',
                 'platform_links']:
        if old.get(key) != new.get(key):
            diffs.append(f"{key} changed")
    for key in ['public_header_sha256']:
        if old.get(key) != new.get(key):
            diffs.append(f"{key} changed")
    return diffs


# ── CLI ────────────────────────────────────────────────────────────────────

def main() -> int:
    ap = argparse.ArgumentParser(description='Audit a llama.cpp snapshot')
    src = ap.add_mutually_exclusive_group(required=True)
    src.add_argument('--upstream', help='Local llama.cpp checkout directory')
    src.add_argument('--url', help='URL of the source tarball')
    ap.add_argument('--sha256', help='Expected SHA-256 of the tarball (required with --url)')
    ap.add_argument('--tag', required=True, help='Upstream tag')
    ap.add_argument('--commit', required=True, help='Upstream commit SHA')
    out = ap.add_mutually_exclusive_group()
    out.add_argument('--output', help='Write JSON report to this file')
    out.add_argument('--check', help='Regenerate and compare with this report file')
    out.add_argument('--compare', help='Compare OLD_REPORT with a new generation')
    args = ap.parse_args()

    if args.url and not args.sha256:
        ap.error('--sha256 is required when using --url')

    root: str
    if args.upstream:
        root = os.path.abspath(args.upstream)
    else:
        # Download and verify tarball
        import tempfile
        import urllib.request
        print(f"Downloading {args.url} ...", file=sys.stderr)
        tmpdir = tempfile.mkdtemp(prefix='llamacpp-audit-')
        tarball = os.path.join(tmpdir, 'source.tar.gz')
        urllib.request.urlretrieve(args.url, tarball)
        actual = sha256_file(tarball)
        if actual != args.sha256:
            os.unlink(tarball)
            sys.exit(f"SHA-256 mismatch: expected {args.sha256}, got {actual}")
        extract_root = os.path.join(tmpdir, 'extracted')
        os.makedirs(extract_root, exist_ok=True)
        with open(tarball, 'rb') as f:
            safe_extract_tar(f, extract_root)
        # The tarball typically contains a single top-level directory
        entries = os.listdir(extract_root)
        dirs = [e for e in entries if os.path.isdir(os.path.join(extract_root, e))]
        root = os.path.join(extract_root, dirs[0]) if dirs else extract_root

    report = collect_snapshot(
        root=root,
        tag=args.tag,
        commit=args.commit,
        url=args.url or 'file://' + root,
        archive_sha256=args.sha256 or 'unknown',
    )

    if args.output:
        with open(args.output, 'w') as f:
            json.dump(report, f, indent=2)
            f.write('\n')
        print(f"Snapshot written to {args.output}", file=sys.stderr)
    elif args.check:
        with open(args.check, 'r') as f:
            expected = json.load(f, object_pairs_hook=OrderedDict)
        if expected == report:
            print("Snapshot matches.", file=sys.stderr)
        else:
            print("Snapshot differs:", file=sys.stderr)
            for diff in compare_reports(expected, report):
                print(f"  - {diff}", file=sys.stderr)
            return 1
    elif args.compare:
        with open(args.compare, 'r') as f:
            old = json.load(f, object_pairs_hook=OrderedDict)
        diffs = compare_reports(old, report)
        if diffs:
            for d in diffs:
                print(d)
        else:
            print("No differences.")
    else:
        json.dump(report, sys.stdout, indent=2)
        print()

    return 0


if __name__ == '__main__':
    sys.exit(main())
