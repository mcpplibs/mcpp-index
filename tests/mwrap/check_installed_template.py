#!/usr/bin/env python3
"""Install real archives from the unchanged candidate index and run a template."""
import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import tomllib


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mcpp", default="mcpp")
    parser.add_argument("--toolchain", default="llvm@23.1.3")
    parser.add_argument("--package", default="mcpplibs.mwrap.onnxruntime@1.25.1")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    identity, version = args.package.rsplit("@", 1)
    with tempfile.TemporaryDirectory(prefix="mwrap-installed-template-") as directory:
        temporary = Path(directory)
        home = temporary / "home"
        index = home / "indices/mcpplibs"
        index.mkdir(parents=True)
        # Exactly the publication layout, with all namespaces in one built-in
        # index. No namespace views, source pre-seeding or dependency rewriting.
        shutil.copytree(root / "pkgs", index / "pkgs")
        shutil.copyfile(root / "index.toml", index / "index.toml")
        env = dict(os.environ, MCPP_HOME=str(home))
        commands = [[args.mcpp, "self", "config", "--mirror", "GLOBAL"],
                    [args.mcpp, "new", "--list-templates", args.package],
                    [args.mcpp, "new", "installed-quickstart", "--template", args.package]]
        for command in commands:
            print("+", " ".join(command), flush=True)
            subprocess.run(command, cwd=temporary, env=env, check=True)
        project = temporary / "installed-quickstart"
        manifest = tomllib.loads((project / "mcpp.toml").read_text(encoding="utf-8"))
        dependency = manifest["dependencies"][identity]
        actual_version = dependency if isinstance(dependency, str) else dependency["version"]
        assert actual_version == version, dependency
        if isinstance(dependency, dict):
            assert "path" not in dependency and "git" not in dependency, dependency
        for command in ([args.mcpp, "build", "--strict", "--toolchain", args.toolchain],
                        [args.mcpp, "run", "--toolchain", args.toolchain]):
            print("+", " ".join(command), flush=True)
            subprocess.run(command, cwd=project, env=env, check=True)
        print("Verified real indexed archive installation and unmodified template consumer", flush=True)


if __name__ == "__main__":
    main()
