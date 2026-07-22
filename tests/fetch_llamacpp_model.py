#!/usr/bin/env python3
"""Fetch the pinned GGUF test model with cryptographic verification."""
import argparse
import hashlib
import os
import sys
import urllib.request
from pathlib import Path

_MODEL_URL = (
    "https://huggingface.co/ggml-org/models-moved/resolve/"
    "499bc8821c6b12b4e53c5bffcb21ec206f212d81/tinyllamas/"
    "stories15M-q4_0.gguf"
)
_MODEL_SIZE = 19077344
_MODEL_SHA256 = "66967fbece6dbe97886593fdbb73589584927e29119ec31f08090732d1861739"


def sha256_file(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(1 << 20):
            h.update(chunk)
    return h.hexdigest()


def fetch(output: str, *, url: str = _MODEL_URL,
          expected_size: int = _MODEL_SIZE,
          expected_sha256: str = _MODEL_SHA256) -> str:
    output = os.path.abspath(output)
    os.makedirs(os.path.dirname(output), exist_ok=True)

    if os.path.isfile(output):
        size = os.path.getsize(output)
        digest = sha256_file(output)
        if size == expected_size and digest == expected_sha256:
            print(f"Model already present and verified: {output}", file=sys.stderr)
            return output
        print(f"Existing file {output} (size={size}, sha256={digest}) "
              f"does not match expected (size={expected_size}, "
              f"sha256={expected_sha256}); re-downloading",
              file=sys.stderr)

    tmp = output + ".tmp"
    try:
        if os.path.exists(tmp):
            os.unlink(tmp)
        print(f"Downloading {url} ...", file=sys.stderr)
        with urllib.request.urlopen(url) as response, open(tmp, "wb") as target:
            while chunk := response.read(1 << 20):
                target.write(chunk)
        actual_size = os.path.getsize(tmp)
        if actual_size != expected_size:
            raise RuntimeError(
                f"Downloaded model size {actual_size} != expected {expected_size}")
        actual_sha = sha256_file(tmp)
        if actual_sha != expected_sha256:
            raise RuntimeError(
                f"Downloaded model SHA-256 {actual_sha} != expected {expected_sha256}")
        os.replace(tmp, output)
        print(f"Model verified and saved to {output}", file=sys.stderr)
    except BaseException:
        if os.path.isfile(tmp):
            os.unlink(tmp)
        raise
    return output


def self_test() -> None:
    import tempfile
    with tempfile.TemporaryDirectory() as td:
        payload = b"local pinned model payload\0" * 64
        source = os.path.join(td, "source.gguf")
        with open(source, "wb") as f:
            f.write(payload)
        url = Path(source).as_uri()
        size = len(payload)
        digest = hashlib.sha256(payload).hexdigest()

        output = os.path.join(td, "model.gguf")
        fetch(output, url=url, expected_size=size,
              expected_sha256=digest)
        fetch(output, url="https://invalid.example/reuse.gguf",
              expected_size=size, expected_sha256=digest)

        for label, rejected_size, rejected_digest in (
                ("size", size + 1, digest),
                ("digest", size, "0" * 64)):
            rejected = os.path.join(td, f"reject-{label}.gguf")
            try:
                fetch(rejected, url=url, expected_size=rejected_size,
                      expected_sha256=rejected_digest)
            except RuntimeError:
                if os.path.exists(rejected) or os.path.exists(rejected + ".tmp"):
                    raise AssertionError(f"{label} rejection left output bytes")
            else:
                raise AssertionError(f"{label} mismatch was accepted")

        with open(output, "wb") as f:
            f.write(b"invalid existing output")
        fetch(output, url=url, expected_size=size,
              expected_sha256=digest)
        if sha256_file(output) != digest or os.path.exists(output + ".tmp"):
            raise AssertionError("atomic replacement did not produce verified output")

        print("Self-test passed", file=sys.stderr)


def main() -> int:
    ap = argparse.ArgumentParser(description="Fetch pinned GGUF test model")
    ap.add_argument("--output", help="Output path for the model file")
    ap.add_argument("--self-test", action="store_true",
                    help="Run local self-test only")
    args = ap.parse_args()
    if args.self_test:
        self_test()
        return 0
    if not args.output:
        ap.error("--output is required (or use --self-test)")
    path = fetch(args.output)
    print(os.path.abspath(path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
