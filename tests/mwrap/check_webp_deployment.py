#!/usr/bin/env python3
"""Install the actual OpenCV/WebP archives and verify a relocated consumer."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mcpp", default="mcpp")
    parser.add_argument("--toolchain", default="llvm@23.1.3")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    with tempfile.TemporaryDirectory(prefix="mwrap-webp-deployment-") as directory:
        temporary = Path(directory)
        home = temporary / "home"
        index = home / "indices/mcpplibs"
        index.mkdir(parents=True)
        shutil.copytree(root / "pkgs", index / "pkgs")
        shutil.copyfile(root / "index.toml", index / "index.toml")
        project = temporary / "consumer"
        shutil.copytree(root / "tests/mwrap/opencv-webp", project)
        manifest = project / "mcpp.toml"
        # The fresh home has the complete unchanged publication index. Keep
        # dependency identities/features intact; remove test-view routing only.
        text = re.sub(r"(?ms)^\[indices\]\n.*?(?=^\[|\Z)", "[indices]\n\n", manifest.read_text())
        manifest.write_text(text)
        (project / "src").mkdir()
        shutil.copyfile(project / "tests/pipeline.cpp", project / "src/main.cpp")
        env = dict(os.environ, MCPP_HOME=str(home))
        commands = [
            [args.mcpp, "self", "config", "--mirror", "GLOBAL"],
            [args.mcpp, "build", "--toolchain", args.toolchain, "--strict"],
            [args.mcpp, "run", "--toolchain", args.toolchain],
            [args.mcpp, "pack", "--toolchain", args.toolchain, "--mode", "self-contained",
             "--format", "dir", "--output", "webp-deployment"],
        ]
        for command in commands:
            print("+", " ".join(command), flush=True)
            subprocess.run(command, cwd=project, env=env, check=True)
        bundle = project / "target/dist/webp-deployment"
        relocated = temporary / "relocated"
        shutil.copytree(bundle, relocated, symlinks=True)
        entries = json.loads((project / "compile_commands.json").read_text())
        sdk = next(parent for entry in entries for parent in Path(entry["file"]).parents
                   if parent.name == "libwebp-1.5.0")
        notices = list(relocated.rglob("licenses/libwebp"))
        assert len(notices) == 1, f"Missing/ambiguous WebP notices: {notices}"
        for name in ("COPYING", "PATENTS", "AUTHORS"):
            assert (notices[0] / name).read_bytes() == (sdk / name).read_bytes(), name
        source = next(Path(entry["file"]).parent.parent for entry in entries
                      if Path(entry["file"]).name == "core.cppm")
        originals = [source / "LICENSE", source / "port/licenses/UPSTREAM_SOURCE_NOTICES.txt",
                     *[path for path in (source / "upstream/opencv").rglob("*")
                     if path.is_file() and any(word in path.name for word in ("LICENSE", "COPYING", "COPYRIGHT", "NOTICE"))]]
        notices = list(relocated.rglob("licenses/opencv"))
        assert len(notices) == 1, f"Missing/ambiguous OpenCV notices: {notices}"
        for original in originals:
            assert (notices[0] / original.relative_to(source)).read_bytes() == original.read_bytes(), original
        runtime = {key: value for key, value in os.environ.items()
                   if key not in {"MCPP_HOME", "XLINGS_HOME", "LD_LIBRARY_PATH", "LD_PRELOAD",
                                  "DYLD_LIBRARY_PATH", "DYLD_FALLBACK_LIBRARY_PATH"}}
        empty_home = temporary / "empty-home"
        empty_home.mkdir()
        runtime.update(HOME=str(empty_home), USERPROFILE=str(empty_home))
        if sys.platform.startswith("linux"):
            runtime["PATH"] = "/usr/bin:/bin"
            launcher = relocated / "run.sh"
        else:
            filename = "opencv-webp" + (".exe" if os.name == "nt" else "")
            launcher = relocated / "bin" / filename
            if not launcher.exists():
                launcher = relocated / filename
            if os.name == "nt":
                system_root = os.environ.get("SystemRoot", r"C:\Windows")
                runtime["PATH"] = os.pathsep.join([system_root, str(Path(system_root) / "System32")])
        subprocess.run([str(launcher)], cwd=empty_home, env=runtime, check=True)
        if sys.platform.startswith("linux"):
            listing = subprocess.run([str(relocated / "lib/ld-linux-x86-64.so.2"),
                                      "--library-path", str(relocated / "lib"), "--list",
                                      str(relocated / "bin/opencv-webp")],
                                     cwd=empty_home, env=runtime, text=True, capture_output=True, check=True)
            for line in listing.stdout.splitlines():
                if "=>" in line:
                    resolved = line.split("=>", 1)[1].strip().split(" ", 1)[0]
                    if resolved.startswith("/"):
                        assert Path(resolved).resolve().is_relative_to(relocated.resolve()), line
        print(f"Verified relocated WebP consumer and {len(originals) + 3} byte-identical notices", flush=True)


if __name__ == "__main__":
    main()
