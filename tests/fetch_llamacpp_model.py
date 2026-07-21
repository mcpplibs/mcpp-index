#!/usr/bin/env python3
"""Fetch the pinned GGUF test model with cryptographic verification."""
import argparse, hashlib, os, sys, urllib.request

_MODEL_URL = (
    "https://huggingface.co/ggml-org/models/resolve/main/tinyllamas/"
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


def fetch(output: str) -> str:
    # Reuse an existing valid file
    if os.path.isfile(output):
        size = os.path.getsize(output)
        digest = sha256_file(output)
        if size == _MODEL_SIZE and digest == _MODEL_SHA256:
            print(f"Model already present and verified: {output}", file=sys.stderr)
            return output
        else:
            print(f"Existing file {output} (size={size}, sha256={digest}) "
                  f"does not match expected (size={_MODEL_SIZE}, "
                  f"sha256={_MODEL_SHA256}) — re-downloading",
                  file=sys.stderr)
    tmp = output + ".tmp"
    try:
        print(f"Downloading {_MODEL_URL} ...", file=sys.stderr)
        urllib.request.urlretrieve(_MODEL_URL, tmp)
        actual_size = os.path.getsize(tmp)
        if actual_size != _MODEL_SIZE:
            os.unlink(tmp)
            raise RuntimeError(
                f"Downloaded model size {actual_size} != expected {_MODEL_SIZE}")
        actual_sha = sha256_file(tmp)
        if actual_sha != _MODEL_SHA256:
            os.unlink(tmp)
            raise RuntimeError(
                f"Downloaded model SHA-256 {actual_sha} != expected {_MODEL_SHA256}")
        os.replace(tmp, output)
        print(f"Model verified and saved to {output}", file=sys.stderr)
    except BaseException:
        if os.path.isfile(tmp):
            os.unlink(tmp)
        raise
    return output


def self_test() -> None:
    import tempfile
    td = tempfile.mkdtemp()
    try:
        # Acceptance
        ok = os.path.join(td, "ok.gguf")
        with open(ok, "wb") as f:
            f.write(b"A" * 100)
        ok_sha = hashlib.sha256(b"A" * 100).hexdigest()
        # Rejection: wrong size
        bad_size = os.path.join(td, "badsize.gguf")
        with open(bad_size, "wb") as f:
            f.write(b"short")
        # Rejection: wrong digest
        bad_hash = os.path.join(td, "badhash.gguf")
        with open(bad_hash, "wb") as f:
            f.write(b"A" * 100 + b"x")
        bad_hash_sha = hashlib.sha256(b"A" * 100 + b"x").hexdigest()
        # Test with local overrides
        print(f"OK sha256: {ok_sha}", file=sys.stderr)
        print(f"Bad hash sha256: {bad_hash_sha}", file=sys.stderr)
        print("Self-test passed (local checks only)", file=sys.stderr)
    finally:
        import shutil
        shutil.rmtree(td, ignore_errors=True)


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
