#!/usr/bin/env python3
"""Install real archives from the unchanged candidate index and run a template."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import tomllib


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mcpp", default="mcpp")
    parser.add_argument("--toolchain", default="llvm@23.1.3")
    parser.add_argument("--package", default="mcpplibs.mwrap.onnxruntime@1.25.1")
    parser.add_argument("--deploy", action="store_true", help="pack, relocate and run the consumer; verify SDK notices")
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
        if args.deploy:
            mode = "self-contained" if sys.platform.startswith("linux") else "vendored"
            command = [args.mcpp, "pack", "--toolchain", args.toolchain, "--mode", mode,
                       "--format", "dir", "--output", "deployment-audit"]
            print("+", " ".join(command), flush=True)
            subprocess.run(command, cwd=project, env=env, check=True)
            bundle = project / "target/dist/deployment-audit"
            relocated = temporary / "relocated/bundle"
            shutil.copytree(bundle, relocated, symlinks=True)
            notices = list(relocated.rglob("licenses/onnxruntime/ThirdPartyNotices.txt"))
            assert len(notices) == 1 and notices[0].stat().st_size, notices
            installed = []
            for entry in json.loads((project / "compile_commands.json").read_text(encoding="utf-8")):
                arguments = entry["arguments"]
                for number, argument in enumerate(arguments):
                    directory = (arguments[number + 1] if argument in ("-I", "/I") else
                                 argument[2:] if argument.startswith(("-I", "/I")) else "")
                    include = Path(directory)
                    if directory and (include / "onnxruntime_c_api.h").is_file():
                        installed.append(include.parent / "ThirdPartyNotices.txt")
            expected = hashlib.sha256(notices[0].read_bytes()).hexdigest()
            assert any(p.is_file() and hashlib.sha256(p.read_bytes()).hexdigest() == expected
                       for p in installed), installed
            runtime_env = {key: value for key, value in os.environ.items()
                           if key not in {"MCPP_HOME", "XLINGS_HOME", "LD_LIBRARY_PATH", "LD_PRELOAD",
                                          "DYLD_LIBRARY_PATH", "DYLD_FALLBACK_LIBRARY_PATH"}}
            empty_home = temporary / "empty-home"
            empty_home.mkdir()
            runtime_env.update(HOME=str(empty_home), USERPROFILE=str(empty_home))
            if sys.platform.startswith("linux"):
                runtime_env["PATH"] = "/usr/bin:/bin"
                launcher = relocated / "run.sh"
            else:
                filename = "installed-quickstart" + (".exe" if os.name == "nt" else "")
                launcher = relocated / "bin" / filename
                if not launcher.exists():
                    launcher = relocated / filename
                if os.name == "nt":
                    system_root = os.environ.get("SystemRoot", r"C:\Windows")
                    runtime_env["PATH"] = os.pathsep.join([system_root, str(Path(system_root) / "System32")])
            subprocess.run([str(launcher)], cwd=empty_home, env=runtime_env, check=True)
            if sys.platform.startswith("linux"):
                loader = relocated / "lib/ld-linux-x86-64.so.2"
                listing = subprocess.run([str(loader), "--library-path", str(relocated / "lib"),
                                          "--list", str(relocated / "bin/installed-quickstart")],
                                         cwd=empty_home, env=runtime_env, text=True, capture_output=True, check=True)
                for line in listing.stdout.splitlines():
                    if "=>" not in line:
                        continue
                    resolved = line.split("=>", 1)[1].strip().split(" ", 1)[0]
                    if resolved.startswith("/"):
                        assert Path(resolved).resolve().is_relative_to(relocated.resolve()), line
            print("Verified relocated inference bundle and byte-identical SDK notices", flush=True)


if __name__ == "__main__":
    main()
