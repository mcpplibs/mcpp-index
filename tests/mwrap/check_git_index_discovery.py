#!/usr/bin/env python3
"""Discover all seven mwrap templates through the real Git index, without an artifact fallback."""
import argparse
import os
from pathlib import Path
import re
import subprocess
import tempfile
import tomllib


PACKAGES = {
    "opencv": "5.0.0", "onnxruntime": "1.25.1", "llamacpp": "b10069",
    "ffmpeg": "8.1.2", "grpc": "1.83.0", "imgui": "1.92.8", "godot_cpp": "10.0.0",
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mcpp", default="mcpp")
    parser.add_argument("--expected-rev", required=True, help="merged index commit that must be present")
    args = parser.parse_args()
    source = Path(__file__).resolve().parents[2]
    with tempfile.TemporaryDirectory(prefix="mwrap-git-index-final-") as directory:
        root = Path(directory)
        home = root / "home"
        env = dict(os.environ, MCPP_HOME=str(home))

        def run(*arguments):
            print("+", args.mcpp, *arguments, flush=True)
            subprocess.run([args.mcpp, *arguments], cwd=root, env=env, check=True)

        run("self", "config", "--mirror", "GLOBAL")
        config = home / "config.toml"
        text = config.read_text()
        # Use the supported global registry setting, not project [indices]:
        # mcpp new intentionally discovers templates from global registries.
        marker = '[index.repos."mcpplibs"]'
        start = text.index(marker)
        end = text.find("\n[", start + len(marker))
        if end < 0:
            end = len(text)
        block = text[start:end]
        block = re.sub(r"(?m)^artifact\s*=.*\n", "", block)
        block = re.sub(r"(?m)^source\s*=.*\n", "", block)
        block += '\nsource = "git"\n'
        config.write_text(text[:start] + block + text[end:])
        repo = tomllib.loads(config.read_text())["index"]["repos"]["mcpplibs"]
        assert repo["source"] == "git" and "artifact" not in repo
        run("index", "update")
        checkout = home / "indices/mcpplibs"
        assert (checkout / ".git").exists(), "Expected an actual Git clone, not an unpacked artifact"
        subprocess.run(["git", "-C", str(checkout), "merge-base", "--is-ancestor", args.expected_rev, "HEAD"], check=True)
        revision = subprocess.check_output(["git", "-C", str(checkout), "rev-parse", "HEAD"], text=True).strip()
        print("Verified actual Git index checkout", revision, flush=True)
        for name, version in PACKAGES.items():
            relative = Path("pkgs/mwrap") / (name + ".lua")
            assert (checkout / relative).read_bytes() == (source / relative).read_bytes(), relative
            identity = "mcpplibs.mwrap." + name
            selector = identity + "@" + version
            run("new", "--list-templates", selector)
            project_name = "git-" + name.replace("_", "-")
            run("new", project_name, "--template", selector)
            manifest = tomllib.loads((root / project_name / "mcpp.toml").read_text())
            dependency = manifest["dependencies"][identity]
            actual = dependency if isinstance(dependency, str) else dependency["version"]
            assert actual == version, (identity, dependency)
            print("Verified Git-index identity and unmodified scaffold", selector, flush=True)
        missing = subprocess.run([args.mcpp, "new", "--list-templates", "mcpplibs.mwrap.definitely_missing@1.0.0"],
                                 cwd=root, env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        assert missing.returncode != 0 and "not found for exact identity" in missing.stdout, missing.stdout
        print("Verified seven Git-index discoveries and rejection of an absent identity", flush=True)


if __name__ == "__main__":
    main()
