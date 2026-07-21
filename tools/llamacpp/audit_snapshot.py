#!/usr/bin/env python3
"""Read-only audit of a llama.cpp upstream snapshot."""
from __future__ import annotations

import argparse, hashlib, json, os, re, sys
from collections import OrderedDict
from pathlib import Path


def sha256_file(path: str | Path) -> str:
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def safe_extract_tar(archive, destination: str):
    import tarfile
    dest = os.path.realpath(destination)
    os.makedirs(dest, exist_ok=True)
    with tarfile.open(fileobj=archive, mode='r:*') as tf:
        for member in tf.getmembers():
            resolved = os.path.realpath(os.path.join(dest, member.name))
            if os.path.commonpath([dest, resolved]) != dest:
                raise ValueError(f"archive member escapes extraction directory: {member.name}")
        archive.seek(0)
        with tarfile.open(fileobj=archive, mode='r:*') as tf2:
            tf2.extractall(dest, filter='data')


def _tokenize_cmake(text: str):
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
        j = i
        while j < n and not text[j].isspace() and text[j] not in '()"':
            j += 1
        yield ('WORD', text[i:j])
        i = j


def extract_cmake_call(text: str, callee: str,
                       first_arg: str | None = None
                       ) -> tuple[str | None, list[str]]:
    tokens = list(_tokenize_cmake(text))
    for i, (typ, val) in enumerate(tokens):
        if typ != 'WORD' or val != callee:
            continue
        if i + 1 >= len(tokens) or tokens[i + 1] != ('(', '('):
            continue
        depth = 1
        j = i + 2
        args: list[str] = []
        while j < len(tokens) and depth > 0:
            typ2, val2 = tokens[j]
            if typ2 == '(':
                depth += 1
                if depth == 1:
                    j += 1
                    continue
            elif typ2 == ')':
                depth -= 1
                if depth == 0:
                    break
            if depth == 1 and typ2 in ('WORD', 'STR'):
                args.append(val2)
            j += 1
        if not args:
            continue
        if first_arg is not None and args[0] != first_arg:
            continue
        return (args[0], args[1:])
    return (None, [])


def _expand_glob(base: str, pattern: str) -> list[str]:
    directory = os.path.dirname(pattern)
    glob_pat = os.path.basename(pattern)
    full_dir = os.path.join(base, directory)
    if not os.path.isdir(full_dir):
        return []
    import fnmatch
    result = []
    for fn in sorted(os.listdir(full_dir)):
        if fnmatch.fnmatch(fn, glob_pat):
            result.append(os.path.join(directory, fn))
    return sorted(result)


def _read_cmake_forest(root: str) -> tuple[str, dict[str, str]]:
    top = os.path.join(root, 'CMakeLists.txt')
    with open(top, 'r') as f:
        top_text = f.read() if os.path.isfile(top) else ''
    subs: dict[str, str] = {}
    for dirpath, _dirnames, filenames in os.walk(root):
        if 'CMakeLists.txt' in filenames:
            sub = os.path.relpath(dirpath, root)
            if sub == '.':
                continue
            fp = os.path.join(dirpath, 'CMakeLists.txt')
            with open(fp, 'r') as f:
                subs[sub] = f.read()
    return top_text, subs


def _find_gpu_backend_calls(text: str, name: str) -> list[str]:
    """Find ggml_add_backend_library(NAME ...) calls, skipping function defs."""
    results = []
    for m in re.finditer(
        r'^\s*ggml_add_backend_library\s*\(\s*(' + re.escape(name) + r')\b',
        text, re.MULTILINE,
    ):
        before = text[:m.start()]
        opens = before.count('function(')
        closes = before.count('endfunction()')
        if opens == closes:  # not inside a function definition
            _, args = extract_cmake_call(
                text[m.start():], 'ggml_add_backend_library', name)
            if args:
                results.extend(args)
    return results


def _find_files(root: str, ext: str) -> list[str]:
    found = []
    for dirpath, _dirnames, filenames in os.walk(root):
        for fn in filenames:
            if fn.endswith(ext):
                rel = os.path.relpath(os.path.join(dirpath, fn), root)
                found.append(rel)
    return sorted(found)


def collect_snapshot(root, tag, commit, url, archive_sha256):
    top_text, sub_cmakes = _read_cmake_forest(root)
    if not top_text and not sub_cmakes:
        raise FileNotFoundError(f"No CMakeLists.txt found under {root}")

    def _extract_from_forest(callee, first_arg, cmake_dir='.'):
        for subdir, text in sub_cmakes.items():
            name, args = extract_cmake_call(text, callee, first_arg)
            if name is not None:
                return name, [os.path.join(subdir, a) for a in args]
        name, args = extract_cmake_call(top_text, callee, first_arg)
        if name is not None:
            return name, args
        return None, []

    _, ggml_base = _extract_from_forest('add_library', 'ggml-base')
    _, ggml_registry = _extract_from_forest('add_library', 'ggml')
    _, ggml_metal = _extract_from_forest('ggml_add_backend_library', 'ggml-metal')
    _, ggml_cpu = _extract_from_forest('ggml_add_backend_library', 'ggml-cpu')
    _, llama = _extract_from_forest('add_library', 'llama')

    # Expand GLOB in llama sources
    llama_expanded: list[str] = []
    model_files: list[str] = []
    for src in llama:
        if '${LLAMA_MODELS_SOURCES}' in src:
            for subdir, text in sub_cmakes.items():
                _, glob_args = extract_cmake_call(text, 'file', 'GLOB')
                if (glob_args and len(glob_args) >= 2 and
                        glob_args[0] == 'LLAMA_MODELS_SOURCES'):
                    pattern = glob_args[1].strip('"')
                    model_dir = os.path.join(root, subdir)
                    model_files = _expand_glob(model_dir, pattern)
                    break
            if not model_files:
                _, glob_args = extract_cmake_call(top_text, 'file', 'GLOB')
                if glob_args and len(glob_args) >= 2:
                    model_files = _expand_glob(root, glob_args[1])
        elif src.endswith('.cpp') or src.endswith('.c'):
            llama_expanded.append(src)

    # CPU sources
    # CPU sources: always use rglob for comprehensive listing
    cpu_common_raw = [
        os.path.relpath(p, root)
        for p in Path(root).glob('ggml/src/ggml-cpu*/**/*.cpp')
    ] + [
        os.path.relpath(p, root)
        for p in Path(root).glob('ggml/src/ggml-cpu*/**/*.c')
    ]
    cpu_arch_x86 = [os.path.relpath(p, root)
                    for p in Path(root).rglob('ggml-cpu-amx*.cpp')]
    cpu_arch_arm = [os.path.relpath(p, root)
                    for p in Path(root).rglob('ggml-cpu-aarch64*.cpp')]
    cpu_filtered = [s for s in cpu_common_raw
                    if 'ggml-cpu' in s or s not in ggml_base]

    # Registry macros
    registry: dict[str, str] = {}
    for candidate in ['ggml/src/ggml-backend-reg.cpp', 'ggml-backend-reg.cpp']:
        reg_path = os.path.join(root, candidate)
        if os.path.isfile(reg_path):
            with open(reg_path, 'r') as f:
                reg_text = f.read()
            for macro in ['GGML_USE_CPU', 'GGML_USE_METAL', 'GGML_USE_CUDA',
                           'GGML_USE_VULKAN', 'GGML_USE_SYCL', 'GGML_USE_CANN']:
                # Match within a single #ifdef ... #endif block only
                block_pat = re.compile(
                    r'#ifdef\s+' + macro + r'\b[^\n]*\n(.*?)#endif',
                    re.DOTALL)
                for block_m in block_pat.finditer(reg_text):
                    inner = block_m.group(1)
                    rm = re.search(r'register_backend\((\w+)\(\)\)', inner)
                    if rm:
                        registry[macro] = rm.group(1)
                        break
            break

    # Metal shader inputs
    metal_inputs: list[str] = []
    for candidate_dir in [os.path.join(root, 'ggml', 'src', 'ggml-metal'),
                          os.path.join(root, 'ggml-metal')]:
        if os.path.isdir(candidate_dir):
            for pat in ['ggml-common.h', 'ggml-metal.metal', 'ggml-metal-impl.h']:
                for base in [candidate_dir, os.path.dirname(candidate_dir)]:
                    full = os.path.join(base, pat)
                    if os.path.isfile(full):
                        rel = os.path.relpath(full, root)
                        if rel not in metal_inputs:
                            metal_inputs.append(rel)
                        break
            if metal_inputs:
                break
    metal_inputs.sort()

    # C++20 exceptions
    cpp20_exceptions = []
    for p in ['src/models/dflash.cpp', 'src/models/eagle3.cpp',
              'src/models/t5.cpp']:
        if os.path.isfile(os.path.join(root, p)):
            cpp20_exceptions.append(p)

    # Public header hashes
    header_hashes = {}
    for hdr in ['llama.h', 'ggml.h', 'ggml-cpu.h']:
        p = os.path.join(root, 'include', hdr)
        if os.path.isfile(p):
            header_hashes[hdr] = sha256_file(p)

    return OrderedDict([
        ('schema', 1),
        ('upstream', OrderedDict([
            ('tag', tag), ('commit', commit),
            ('url', url), ('sha256', archive_sha256),
        ])),
        ('sources', OrderedDict([
            ('ggml_base', sorted(set(ggml_base))),
            ('ggml_registry', sorted(set(ggml_registry))),
            ('ggml_cpu_common', sorted(set(cpu_filtered))),
            ('ggml_cpu_x86', sorted(set(cpu_arch_x86))),
            ('ggml_cpu_arm', sorted(set(cpu_arch_arm))),
            ('llama_core', sorted(set(llama_expanded))),
            ('models', sorted(set(model_files))),
            ('ggml_metal', sorted(set(ggml_metal))),
        ])),
        ('registry', registry),
        ('metal', OrderedDict([
            ('frameworks', ['Foundation', 'Metal', 'MetalKit']),
            ('shader_inputs', metal_inputs),
        ])),
        ('dialect_exceptions', OrderedDict([
            ('c++20', cpp20_exceptions),
        ])),
        ('platform_links', {'windows_cpu': ['advapi32']}),
        ('public_header_sha256', header_hashes),
    ])


def compare_reports(old: dict, new: dict) -> list[str]:
    diffs = []
    for key in ['sources', 'registry', 'metal', 'dialect_exceptions',
                 'platform_links', 'public_header_sha256']:
        if old.get(key) != new.get(key):
            diffs.append(f"{key} changed")
    return diffs


def main() -> int:
    ap = argparse.ArgumentParser(description='Audit a llama.cpp snapshot')
    src = ap.add_mutually_exclusive_group(required=True)
    src.add_argument('--upstream', help='Local llama.cpp checkout directory')
    src.add_argument('--url', help='URL of the source tarball')
    ap.add_argument('--sha256', help='Expected SHA-256 of the tarball')
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
        import tempfile, urllib.request
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
        entries = os.listdir(extract_root)
        dirs = [e for e in entries
                if os.path.isdir(os.path.join(extract_root, e))]
        root = os.path.join(extract_root, dirs[0]) if dirs else extract_root

    report = collect_snapshot(
        root=root, tag=args.tag, commit=args.commit,
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
