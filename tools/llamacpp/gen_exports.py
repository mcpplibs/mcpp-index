#!/usr/bin/env python3
"""Deterministic API export generator using Clang JSON AST dump."""
from __future__ import annotations

import argparse, json, os, re, subprocess, sys, tempfile
from pathlib import Path

REQUIRED_GGML_TYPES = {
    "ggml_abort_callback", "ggml_backend_buffer_type_t",
    "ggml_backend_dev_t", "ggml_backend_sched_eval_callback",
    "ggml_cgraph", "ggml_context", "ggml_log_callback",
    "ggml_log_level", "ggml_numa_strategy", "ggml_opt_dataset_t",
    "ggml_opt_epoch_callback", "ggml_opt_get_optimizer_params",
    "ggml_opt_optimizer_type", "ggml_opt_result_t",
    "ggml_tensor", "ggml_threadpool_t", "ggml_type",
}

GGML_ENUM_TYPES = {"ggml_log_level", "ggml_numa_strategy",
                    "ggml_opt_optimizer_type", "ggml_type"}
DEFAULT_OUTPUT_DIR = Path(__file__).resolve().parent / "module" / "gen_exports"


def _find_clang():
    for candidate in [os.environ.get("CLANG", ""), "clang++-22",
                      "clang++-20", "clang++-19", "clang++"]:
        if not candidate:
            continue
        r = subprocess.run(["which", candidate], capture_output=True, text=True)
        if r.returncode == 0:
            return r.stdout.strip()
    raise RuntimeError("clang++ not found")


def generate_exports(upstream_dir, include_dirs=None):
    if include_dirs is None:
        include_dirs = [os.path.join(upstream_dir, "include"),
                        os.path.join(upstream_dir, "ggml", "include")]
    inc_flags = " ".join(f"-I{p}" for p in include_dirs)
    clang = _find_clang()

    # Find header paths
    llama_h = None
    ggml_h = None
    for d in include_dirs:
        for name, var in [("llama.h", "llama_h"), ("ggml.h", "ggml_h")]:
            p = os.path.join(d, name)
            if os.path.isfile(p) and not locals()[var]:
                if var == "llama_h":
                    llama_h = p
                else:
                    ggml_h = p
    assert llama_h, "llama.h not found"

    # Read source lines
    with open(llama_h) as f:
        llama_lines = f.readlines()

    # Create probe and run Clang AST dump
    probe = tempfile.NamedTemporaryFile(suffix=".cpp", mode="w", delete=False)
    probe.write('#include "llama.h"\n#include "ggml.h"\n')
    probe.close()
    try:
        cmd = [clang, "-std=c++20", "-fsyntax-only",
               "-Xclang", "-ast-dump=json"] + inc_flags.split() + [probe.name]
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode != 0:
            raise RuntimeError(f"Clang AST dump failed:\n{r.stderr[:2000]}")
        ast_data = json.loads(r.stdout)
    finally:
        os.unlink(probe.name)

    # Macro dump
    macro_r = subprocess.run(
        [clang, "-dM", "-E"] + inc_flags.split() + ["-"],
        input='#include "llama.h"\n', capture_output=True, text=True)

    # ── Collect declarations ──
    llama_exports = []
    ggml_exports = []
    ggml_enum_members = set()
    skipped = []

    def _walk(node):
        if not isinstance(node, dict):
            return
        kind = node.get("kind", "")
        name = node.get("name", "")
        loc = node.get("loc", {})
        fpath = ""
        if isinstance(loc, dict):
            fpath = loc.get("file", loc.get("spellingLoc", {}).get("file", ""))

        # Clang's JSON -ast-dump does not reliably include the source file name
        # via `loc.file` or `loc.includedFrom.file`; it may point to the probe
        # .cpp rather than the actual header.  Use naming heuristics instead:
        # • FunctionDecl / RecordDecl / EnumDecl / EnumConstantDecl names that
        #   start with `llama_` (or `LLAMA_`) are from llama.h.
        # • Types prefixed `ggml_` (or `GGML_`) are from ggml.h.
        in_llama = name.startswith("llama_") or name.startswith("LLAMA_")
        # namespace-like prefixes that belong to ggml
        in_ggml = name.startswith("ggml_") or name.startswith("GGML_")

        if kind in ("FunctionDecl", "CXXMethodDecl") and in_llama and name.startswith("llama_"):
            line_no = 0
            if isinstance(loc, dict):
                line_no = loc.get("line", loc.get("spellingLoc", {}).get("line", 1))
            if 1 <= line_no <= len(llama_lines):
                src_line = llama_lines[line_no - 1]
            else:
                src_line = ""
            # Check for DeprecatedAttr
            has_deprecated = any(
                c.get("kind") == "DeprecatedAttr"
                for c in node.get("inner", []))
            if has_deprecated or "DEPRECATED" in src_line:
                skipped.append(f"deprecated function '{name}'")
            elif "LLAMA_API" in src_line:
                llama_exports.append(f"export using ::{name};")
            # else: static/inline helpers, skip

        elif kind in ("RecordDecl", "CXXRecordDecl", "TypedefDecl", "ClassTemplateDecl"):
            if in_llama and name.startswith("llama_"):
                llama_exports.append(f"export using ::{name};")
            elif in_ggml and name in REQUIRED_GGML_TYPES:
                ggml_exports.append(f"export using ::{name};")

        elif kind == "EnumDecl":
            if in_llama and name.startswith("llama_"):
                llama_exports.append(f"export using ::{name};")
            elif in_ggml and name in REQUIRED_GGML_TYPES:
                ggml_exports.append(f"export using ::{name};")
                if name in GGML_ENUM_TYPES:
                    for child in node.get("inner", []):
                        if child.get("kind") == "EnumConstantDecl":
                            cname = child.get("name", "")
                            if cname:
                                ggml_enum_members.add(cname)

        elif kind == "EnumConstantDecl":
            if in_llama and name.startswith("LLAMA_"):
                llama_exports.append(f"export using ::{name};")

        for child in node.get("inner", []):
            _walk(child)

    if isinstance(ast_data, dict):
        _walk(ast_data)
    elif isinstance(ast_data, list):
        for n in ast_data:
            _walk(n)

    # Add GGML enumerator exports
    for ename in sorted(ggml_enum_members):
        ggml_exports.append(f"export using ::{ename};")

    # Collect LLAMA_ macros
    for line in macro_r.stdout.splitlines():
        parts = line.split()
        if len(parts) >= 2 and parts[0] == "#define" and parts[1].startswith("LLAMA_"):
            skipped.append(f"macro {parts[1]}")

    # Deduplicate and sort
    llama_exports = sorted(set(llama_exports), key=lambda x: x.rsplit("::", 1)[-1])
    ggml_exports = sorted(set(ggml_exports), key=lambda x: x.rsplit("::", 1)[-1])
    skipped = sorted(set(skipped))

    return ("\n".join(llama_exports) + "\n",
            "\n".join(ggml_exports) + "\n",
            "\n".join(skipped) + "\n")


def sync_outputs(output_dir, outputs, check):
    output_dir = Path(output_dir)
    if check:
        for name, content in outputs.items():
            existing = output_dir / name
            if not existing.exists():
                print(f"{name} does not exist", file=sys.stderr)
                return 1
            if existing.read_text(encoding="utf-8") != content:
                print(f"{name} differs", file=sys.stderr)
                return 1
        print("All exports match.", file=sys.stderr)
        return 0

    output_dir.mkdir(parents=True, exist_ok=True)
    for name, content in outputs.items():
        (output_dir / name).write_text(content, encoding="utf-8")
        print(f"Wrote {name} ({len(content)} bytes)", file=sys.stderr)
    return 0


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--upstream", help="llama.cpp checkout dir")
    ap.add_argument("--check", action="store_true")
    ap.add_argument(
        "--output-dir",
        type=Path,
        help="generated export directory (default: src/gen_exports)",
    )
    args = ap.parse_args(argv)

    upstream = args.upstream
    if not upstream:
        repo_root = Path(__file__).resolve().parent.parent
        fetch = repo_root / "tools" / "fetch_upstream.sh"
        if fetch.exists():
            upstream = subprocess.run(
                ["bash", str(fetch)], capture_output=True, text=True
            ).stdout.strip()
            if not upstream:
                print("fetch_upstream.sh failed", file=sys.stderr)
                return 1
        else:
            print("No --upstream and no fetch_upstream.sh", file=sys.stderr)
            return 1

    llama_inc, ggml_inc, skipped_txt = generate_exports(upstream)

    outputs = {
        "llama.inc": llama_inc,
        "required_ggml.inc": ggml_inc,
        "llama.skipped.txt": skipped_txt,
    }
    return sync_outputs(args.output_dir or DEFAULT_OUTPUT_DIR, outputs, args.check)


if __name__ == "__main__":
    sys.exit(main())
