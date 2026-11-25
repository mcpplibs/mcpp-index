#!/usr/bin/env python3
"""Put the unchanged checkout layout in a test home's single built-in index."""
import argparse
from pathlib import Path
import shutil
import tempfile


def prepare(source: Path, home: Path):
    assert (source / "index.toml").is_file() and (source / "pkgs").is_dir(), source
    parent = home / "indices"
    parent.mkdir(parents=True, exist_ok=True)
    target = parent / "mcpplibs"
    with tempfile.TemporaryDirectory(prefix=".candidate-index-", dir=parent) as directory:
        staged = Path(directory) / "index"
        staged.mkdir()
        shutil.copytree(source / "pkgs", staged / "pkgs")
        shutil.copyfile(source / "index.toml", staged / "index.toml")
        if target.is_symlink():
            target.unlink()
        elif target.exists():
            shutil.rmtree(target)
        staged.rename(target)
    print("Test home uses the complete unchanged candidate index:", target)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--home", required=True, type=Path)
    parser.add_argument("--source", default=Path(__file__).resolve().parents[1], type=Path)
    args = parser.parse_args()
    prepare(args.source.resolve(), args.home.resolve())
