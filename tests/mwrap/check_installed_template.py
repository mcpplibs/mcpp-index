#!/usr/bin/env python3
"""Install real archives from the candidate or published index and run an unmodified template."""
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
    parser.add_argument("--deploy", action="store_true", help="pack, relocate and run the consumer; verify declared notices")
    parser.add_argument("--published-index", action="store_true", help="refresh the real public index instead of staging this checkout")
    parser.add_argument("--home", type=Path, help="reuse a dedicated test home across independent installed consumers")
    parser.add_argument("--run-arg", action="append", default=[])
    parser.add_argument("--legacy-exact-key", action="store_true",
                        help="allow only mcpp's nonnumeric exact-version diagnostic; fail other build warnings")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    identity, version = args.package.rsplit("@", 1)
    with tempfile.TemporaryDirectory(prefix="mwrap-installed-template-") as directory:
        temporary = Path(directory)
        home = args.home.resolve() if args.home else temporary / "home"
        if not args.published_index:
            index = home / "indices/mcpplibs"
            index.mkdir(parents=True)
            # Exactly the publication layout, with all namespaces in one built-in
            # index. No namespace views, source pre-seeding or dependency rewriting.
            shutil.copytree(root / "pkgs", index / "pkgs")
            shutil.copyfile(root / "index.toml", index / "index.toml")
        env = dict(os.environ, MCPP_HOME=str(home))
        commands = [[args.mcpp, "self", "config", "--mirror", "GLOBAL"]]
        if args.published_index:
            commands.append([args.mcpp, "index", "update"])
        commands += [[args.mcpp, "new", "--list-templates", args.package],
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
        build = [args.mcpp, "build", "--toolchain", args.toolchain]
        if not args.legacy_exact_key:
            build.append("--strict")
        else:
            assert not version[0].isdigit(), "This exception is only for upstream nonnumeric release keys"
        for command in (build, [args.mcpp, "run", "--toolchain", args.toolchain] +
                        (["--", *args.run_arg] if args.run_arg else [])):
            print("+", " ".join(command), flush=True)
            if args.legacy_exact_key and command is build:
                # This is a supported exact index key, not a numeric range.
                # --strict promotes its planner warning to an error. Preserve
                # that upstream identity, but reject every other warning,
                # including module/ABI compatibility degradations.
                result = subprocess.run(command, cwd=project, env=env, text=True,
                                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                print(result.stdout, end="", flush=True)
                result.check_returncode()
                allowed = f"[dependencies] {identity} = '{version}' is not a version RANGE "
                for line in result.stdout.splitlines():
                    if "warning:" in line:
                        assert line.split("warning:", 1)[1].strip().startswith(allowed), line
            else:
                subprocess.run(command, cwd=project, env=env, check=True)
        print("Verified real indexed archive installation and unmodified template consumer", flush=True)
        if identity == "mcpplibs.mwrap.opencv":
            # Keep the rendered application/manifest unchanged. Reuse this
            # fresh installation for the actual indexed API consumer as a test.
            tests = project / "tests"
            tests.mkdir(exist_ok=True)
            consumer = tests / "mwrap_indexed_api.cpp"
            assert not consumer.exists(), consumer
            shutil.copyfile(root / "tests/mwrap/opencv-cpu/tests/pipeline.cpp", consumer)
            command = [args.mcpp, "test", "mwrap_indexed_api", "--toolchain", args.toolchain, "--strict"]
            print("+", " ".join(command), flush=True)
            subprocess.run(command, cwd=project, env=env, check=True)
            print("Verified indexed OpenCV API consumer after the unmodified template run", flush=True)
        if args.deploy:
            mode = "self-contained" if sys.platform.startswith("linux") else "vendored"
            command = [args.mcpp, "pack", "--toolchain", args.toolchain, "--mode", mode,
                       "--format", "dir", "--output", "deployment-audit"]
            print("+", " ".join(command), flush=True)
            subprocess.run(command, cwd=project, env=env, check=True)
            bundle = project / "target/dist/deployment-audit"
            relocated = temporary / "relocated/bundle"
            shutil.copytree(bundle, relocated, symlinks=True)
            if identity == "mcpplibs.mwrap.onnxruntime":
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
                sdk_license = notices[0].with_name("LICENSE")
                assert sdk_license.is_file() and b"MIT License" in sdk_license.read_bytes(), sdk_license
                assert any(p.with_name("LICENSE").is_file() and
                           p.with_name("LICENSE").read_bytes() == sdk_license.read_bytes()
                           for p in installed), "SDK MIT license changed or was overwritten"
                commands = json.loads((project / "compile_commands.json").read_text(encoding="utf-8"))
                wrapper = next(Path(item["file"]).parent.parent for item in commands
                               if Path(item["file"]).name == "onnxruntime.cppm")
                declared = tomllib.loads((wrapper / "mcpp.toml").read_text(encoding="utf-8"))["runtime"]["deploy"]
                for entry in declared:
                    source = wrapper / entry["from"]
                    destination = notices[0].parent / Path(entry["to"]).relative_to("licenses/onnxruntime") / source.name
                    assert destination.is_file() and destination.read_bytes() == source.read_bytes(), destination
                assert b"Apache License" in (notices[0].parent / "wrapper/LICENSE").read_bytes()
                assert b"mcpp-community" in (notices[0].parent / "wrapper/NOTICE").read_bytes()
                print("Verified separate SDK MIT and wrapper Apache-2.0 licenses, NOTICE and retained upstream bytes", flush=True)
            elif identity == "mcpplibs.mwrap.opencv":
                commands = json.loads((project / "compile_commands.json").read_text(encoding="utf-8"))
                sources = [Path(item["file"]).parent.parent for item in commands
                           if Path(item["file"]).name == "core.cppm"]
                source = next(path for path in sources if (path / "upstream/opencv/LICENSE").is_file())
                notices = [source / "LICENSE", source / "NOTICE", source / "port/licenses/UPSTREAM_SOURCE_NOTICES.txt",
                           *[path for path in (source / "upstream/opencv").rglob("*")
                           if path.is_file() and any(word in path.name for word in ("LICENSE", "COPYING", "COPYRIGHT", "NOTICE"))]]
                roots = list(relocated.rglob("licenses/opencv"))
                assert len(roots) == 1, f"Missing OpenCV runtime license tree: {roots}"
                for notice in notices:
                    copied = roots[0] / notice.relative_to(source)
                    assert copied.is_file(), f"Missing retained OpenCV notice: {copied}"
                    assert copied.read_bytes() == notice.read_bytes(), copied
                print(f"Verified {len(notices)} byte-identical wrapper/upstream license files", flush=True)
            elif identity == "mcpplibs.mwrap.fribidi":
                # FriBidi is LGPL-2.1-or-later and linked statically: its license,
                # authors and README travel with the program, beside the wrapper's.
                # The installed archive in the test home's package store.
                sources = [path for store in (home / "xpkgs", home / "registry/data/xpkgs")
                           for path in store.glob(f"mcpplibs.mwrap-x-fribidi/{version}/*/src/fribidi.cppm")]
                assert len(sources) == 1, sources
                source = sources[0].parent.parent
                declared = tomllib.loads((source / "mcpp.toml").read_text(encoding="utf-8"))["runtime"]["deploy"]
                roots = list(relocated.rglob("licenses/fribidi"))
                assert len(roots) == 1, f"Missing FriBidi runtime license tree: {roots}"
                for entry in declared:
                    notice = source / entry["from"]
                    copied = roots[0].parent.parent / entry["to"] / notice.name
                    assert copied.is_file() and copied.read_bytes() == notice.read_bytes(), copied
                assert b"GNU LESSER GENERAL PUBLIC LICENSE" in (roots[0] / "upstream/fribidi/COPYING").read_bytes()
                assert b"Apache License" in (roots[0] / "LICENSE").read_bytes()
                assert b"mcpp-community" in (roots[0] / "NOTICE").read_bytes()
                print(f"Verified {len(declared)} byte-identical wrapper/FriBidi license files", flush=True)
            elif identity == "mcpplibs.mwrap.sheenbidi":
                # SheenBidi is Apache-2.0 and linked statically: its LICENSE and
                # README, and the Unicode License v3 of the data its tables are
                # generated from, travel with the program beside the wrapper's.
                sources = [path for store in (home / "xpkgs", home / "registry/data/xpkgs")
                           for path in store.glob(f"mcpplibs.mwrap-x-sheenbidi/{version}/*/src/sheenbidi.cppm")]
                assert len(sources) == 1, sources
                source = sources[0].parent.parent
                declared = tomllib.loads((source / "mcpp.toml").read_text(encoding="utf-8"))["runtime"]["deploy"]
                roots = list(relocated.rglob("licenses/sheenbidi"))
                assert len(roots) == 1, f"Missing SheenBidi runtime license tree: {roots}"
                for entry in declared:
                    notice = source / entry["from"]
                    copied = roots[0].parent.parent / entry["to"] / notice.name
                    assert copied.is_file() and copied.read_bytes() == notice.read_bytes(), copied
                assert b"Apache License" in (roots[0] / "upstream/sheenbidi/LICENSE").read_bytes()
                assert b"UNICODE LICENSE V3" in (roots[0] / "upstream/unicode/license.txt").read_bytes()
                assert b"Apache License" in (roots[0] / "LICENSE").read_bytes()
                notice = (roots[0] / "NOTICE").read_bytes()
                assert b"mcpp-community" in notice and b"Muhammad Tayyab Akram" in notice
                print(f"Verified {len(declared)} byte-identical wrapper/SheenBidi license files", flush=True)
            elif identity == "mcpplibs.mwrap.dr_libs":
                # dr_libs (Unlicense OR MIT-0) is linked statically: its README
                # and LICENSE travel with the program beside the wrapper's.
                sources = [path for store in (home / "xpkgs", home / "registry/data/xpkgs")
                           for path in store.glob(f"mcpplibs.mwrap-x-dr_libs/{version}/*/src/dr_libs.cppm")]
                assert len(sources) == 1, sources
                source = sources[0].parent.parent
                declared = tomllib.loads((source / "mcpp.toml").read_text(encoding="utf-8"))["runtime"]["deploy"]
                roots = list(relocated.rglob("licenses/dr_libs"))
                assert len(roots) == 1, f"Missing dr_libs runtime license tree: {roots}"
                for entry in declared:
                    notice = source / entry["from"]
                    copied = roots[0].parent.parent / entry["to"] / notice.name
                    assert copied.is_file() and copied.read_bytes() == notice.read_bytes(), copied
                upstream = (roots[0] / "upstream/dr_libs/LICENSE").read_bytes()
                assert b"unlicense.org" in upstream and b"MIT No Attribution" in upstream
                assert b"Apache License" in (roots[0] / "LICENSE").read_bytes()
                notice = (roots[0] / "NOTICE").read_bytes()
                assert b"mcpp-community" in notice and b"David Reid" in notice
                print(f"Verified {len(declared)} byte-identical wrapper/dr_libs license files", flush=True)
            elif identity == "mcpplibs.mwrap.opus":
                # libopus, opusfile and libogg are BSD-3-Clause and linked
                # statically: each one's README and COPYING (libopus's with its
                # patent license references) travel with the program beside the
                # wrapper's LICENSE and NOTICE.
                sources = [path for store in (home / "xpkgs", home / "registry/data/xpkgs")
                           for path in store.glob(f"mcpplibs.mwrap-x-opus/{version}/*/src/opus.cppm")]
                assert len(sources) == 1, sources
                source = sources[0].parent.parent
                declared = tomllib.loads((source / "mcpp.toml").read_text(encoding="utf-8"))["runtime"]["deploy"]
                roots = list(relocated.rglob("licenses/opus"))
                assert len(roots) == 1, f"Missing Opus runtime license tree: {roots}"
                for entry in declared:
                    notice = source / entry["from"]
                    copied = roots[0].parent.parent / entry["to"] / notice.name
                    assert copied.is_file() and copied.read_bytes() == notice.read_bytes(), copied
                for library in ("opus", "opusfile", "ogg"):
                    assert b"Redistribution and use in source and binary forms" in (
                        roots[0] / "upstream" / library / "COPYING").read_bytes(), library
                assert b"royalty-free patent licenses" in (roots[0] / "upstream/opus/COPYING").read_bytes()
                assert b"Apache License" in (roots[0] / "LICENSE").read_bytes()
                notice = (roots[0] / "NOTICE").read_bytes()
                assert b"mcpp-community" in notice and b"Xiph.Org" in notice
                print(f"Verified {len(declared)} byte-identical wrapper/libopus/opusfile/libogg license files", flush=True)
            elif identity == "mcpplibs.mwrap.box2d":
                # Box2D is MIT and linked statically: its LICENSE and README
                # travel with the program beside the wrapper's LICENSE/NOTICE.
                sources = [path for store in (home / "xpkgs", home / "registry/data/xpkgs")
                           for path in store.glob(f"mcpplibs.mwrap-x-box2d/{version}/*/src/box2d.cppm")]
                assert len(sources) == 1, sources
                source = sources[0].parent.parent
                declared = tomllib.loads((source / "mcpp.toml").read_text(encoding="utf-8"))["runtime"]["deploy"]
                roots = list(relocated.rglob("licenses/box2d"))
                assert len(roots) == 1, f"Missing Box2D runtime license tree: {roots}"
                for entry in declared:
                    notice = source / entry["from"]
                    copied = roots[0].parent.parent / entry["to"] / notice.name
                    assert copied.is_file() and copied.read_bytes() == notice.read_bytes(), copied
                assert b"MIT License" in (roots[0] / "upstream/box2d/LICENSE").read_bytes()
                assert b"Erin Catto" in (roots[0] / "upstream/box2d/LICENSE").read_bytes()
                assert b"Apache License" in (roots[0] / "LICENSE").read_bytes()
                notice = (roots[0] / "NOTICE").read_bytes()
                assert b"mcpp-community" in notice and b"Erin Catto" in notice
                print(f"Verified {len(declared)} byte-identical wrapper/Box2D license files", flush=True)
            elif identity == "mcpplibs.mwrap.libwebp":
                # libwebp (BSD-3-Clause with Google's patent grant) is linked
                # statically: the wrapper's LICENSE/NOTICE and libwebp's README,
                # COPYING, PATENTS and AUTHORS travel with the program, beside
                # the COPYING/PATENTS/AUTHORS compat.libwebp deploys itself.
                sources = [path for store in (home / "xpkgs", home / "registry/data/xpkgs")
                           for path in store.glob(f"mcpplibs.mwrap-x-libwebp/{version}/*/src/libwebp.cppm")]
                assert len(sources) == 1, sources
                source = sources[0].parent.parent
                declared = tomllib.loads((source / "mcpp.toml").read_text(encoding="utf-8"))["runtime"]["deploy"]
                roots = list(relocated.rglob("licenses/libwebp"))
                assert len(roots) == 1, f"Missing libwebp runtime license tree: {roots}"
                for entry in declared:
                    notice = source / entry["from"]
                    copied = roots[0].parent.parent / entry["to"] / notice.name
                    assert copied.is_file() and copied.read_bytes() == notice.read_bytes(), copied
                upstream = roots[0] / "upstream/libwebp"
                assert b"Google Inc." in (upstream / "COPYING").read_bytes()
                assert b"patent" in (upstream / "PATENTS").read_bytes()
                for name in ("COPYING", "PATENTS", "AUTHORS"):  # compat.libwebp's own deployment
                    assert (roots[0] / name).read_bytes() == (upstream / name).read_bytes(), name
                assert b"Apache License" in (roots[0] / "LICENSE").read_bytes()
                notice = (roots[0] / "NOTICE").read_bytes()
                assert b"mcpp-community" in notice and b"Google" in notice
                print(f"Verified {len(declared)} byte-identical wrapper/libwebp license files", flush=True)
            elif identity == "mcpplibs.mwrap.libvpx":
                # libvpx and libwebm (BSD-3-Clause with the WebM project's
                # patent grant) are linked statically: the wrapper's
                # LICENSE/NOTICE and each library's README, LICENSE, PATENTS
                # and AUTHORS travel with the program.
                sources = [path for store in (home / "xpkgs", home / "registry/data/xpkgs")
                           for path in store.glob(f"mcpplibs.mwrap-x-libvpx/{version}/*/src/libvpx.cppm")]
                assert len(sources) == 1, sources
                source = sources[0].parent.parent
                declared = tomllib.loads((source / "mcpp.toml").read_text(encoding="utf-8"))["runtime"]["deploy"]
                roots = list(relocated.rglob("licenses/libvpx"))
                assert len(roots) == 1, f"Missing libvpx runtime license tree: {roots}"
                for entry in declared:
                    notice = source / entry["from"]
                    copied = roots[0].parent.parent / entry["to"] / notice.name
                    assert copied.is_file() and copied.read_bytes() == notice.read_bytes(), copied
                assert b"The WebM Project authors" in (roots[0] / "upstream/libvpx/LICENSE").read_bytes()
                assert b"Google Inc." in (roots[0] / "upstream/libwebm/LICENSE.TXT").read_bytes()
                for patents in ("upstream/libvpx/PATENTS", "upstream/libwebm/PATENTS.TXT"):
                    assert b"patent" in (roots[0] / patents).read_bytes(), patents
                assert b"Apache License" in (roots[0] / "LICENSE").read_bytes()
                notice = (roots[0] / "NOTICE").read_bytes()
                assert b"mcpp-community" in notice and b"WebM Project" in notice
                print(f"Verified {len(declared)} byte-identical wrapper/libvpx/libwebm license files", flush=True)
            elif identity == "mcpplibs.mwrap.pocketpy":
                # PocketPy is MIT and linked statically: its LICENSE and README
                # travel with the program beside the wrapper's LICENSE/NOTICE.
                sources = [path for store in (home / "xpkgs", home / "registry/data/xpkgs")
                           for path in store.glob(f"mcpplibs.mwrap-x-pocketpy/{version}/*/src/pocketpy.cppm")]
                assert len(sources) == 1, sources
                source = sources[0].parent.parent
                declared = tomllib.loads((source / "mcpp.toml").read_text(encoding="utf-8"))["runtime"]["deploy"]
                roots = list(relocated.rglob("licenses/pocketpy"))
                assert len(roots) == 1, f"Missing PocketPy runtime license tree: {roots}"
                for entry in declared:
                    notice = source / entry["from"]
                    copied = roots[0].parent.parent / entry["to"] / notice.name
                    assert copied.is_file() and copied.read_bytes() == notice.read_bytes(), copied
                assert b"MIT License" in (roots[0] / "upstream/pocketpy/LICENSE").read_bytes()
                assert b"blueloveTH" in (roots[0] / "upstream/pocketpy/LICENSE").read_bytes()
                assert b"Apache License" in (roots[0] / "LICENSE").read_bytes()
                notice = (roots[0] / "NOTICE").read_bytes()
                assert b"mcpp-community" in notice and b"blueloveTH" in notice
                print(f"Verified {len(declared)} byte-identical wrapper/PocketPy license files", flush=True)
            elif identity == "mcpplibs.mwrap.miniaudio":
                # miniaudio (MIT No Attribution or the Unlicense) is linked
                # statically: its LICENSE and README travel with the program
                # beside the wrapper's Apache-2.0 LICENSE and NOTICE.
                sources = [path for store in (home / "xpkgs", home / "registry/data/xpkgs")
                           for path in store.glob(f"mcpplibs.mwrap-x-miniaudio/{version}/*/src/miniaudio.cppm")]
                assert len(sources) == 1, sources
                source = sources[0].parent.parent
                declared = tomllib.loads((source / "mcpp.toml").read_text(encoding="utf-8"))["runtime"]["deploy"]
                roots = list(relocated.rglob("licenses/miniaudio"))
                assert len(roots) == 1, f"Missing miniaudio runtime license tree: {roots}"
                for entry in declared:
                    notice = source / entry["from"]
                    copied = roots[0].parent.parent / entry["to"] / notice.name
                    assert copied.is_file() and copied.read_bytes() == notice.read_bytes(), copied
                upstream_license = (roots[0] / "upstream/miniaudio/LICENSE").read_bytes()
                assert b"MIT No Attribution" in upstream_license and b"unlicense" in upstream_license.lower()
                assert b"Apache License" in (roots[0] / "LICENSE").read_bytes()
                notice = (roots[0] / "NOTICE").read_bytes()
                assert b"mcpp-community" in notice and b"David Reid" in notice
                print(f"Verified {len(declared)} byte-identical wrapper/miniaudio license files", flush=True)
            elif identity == "mcpplibs.mwrap.freetype":
                # FreeType is linked statically under the FreeType License (FTL),
                # whose credit the documentation carries: the license selector, the
                # FTL and the notices of the BDF and PCF drivers travel with the
                # program, at distinct paths, beside the wrapper's.
                sources = [path for store in (home / "xpkgs", home / "registry/data/xpkgs")
                           for path in store.glob(f"mcpplibs.mwrap-x-freetype/{version}/*/src/freetype.cppm")]
                assert len(sources) == 1, sources
                source = sources[0].parent.parent
                declared = tomllib.loads((source / "mcpp.toml").read_text(encoding="utf-8"))["runtime"]["deploy"]
                roots = list(relocated.rglob("licenses/freetype"))
                assert len(roots) == 1, f"Missing FreeType runtime license tree: {roots}"
                for entry in declared:
                    notice = source / entry["from"]
                    copied = roots[0].parent.parent / entry["to"] / notice.name
                    assert copied.is_file() and copied.read_bytes() == notice.read_bytes(), copied
                upstream = roots[0] / "upstream/freetype"
                assert b"The FreeType Project LICENSE" in (upstream / "docs/FTL.TXT").read_bytes()
                assert b"Francesco Zappa Nardelli" in (upstream / "src/bdf/README").read_bytes()
                assert (upstream / "src/pcf/README").read_bytes() != (upstream / "src/bdf/README").read_bytes()
                assert b"Apache License" in (roots[0] / "LICENSE").read_bytes()
                notice = (roots[0] / "NOTICE").read_bytes()
                assert b"mcpp-community" in notice and b"The FreeType Project" in notice
                print(f"Verified {len(declared)} byte-identical wrapper/FreeType license files", flush=True)
            elif identity == "mcpplibs.mwrap.harfbuzz":
                # HarfBuzz is "Old MIT" and linked statically: its license, authors
                # and README travel with the program, beside the wrapper's.
                sources = [path for store in (home / "xpkgs", home / "registry/data/xpkgs")
                           for path in store.glob(f"mcpplibs.mwrap-x-harfbuzz/{version}/*/src/harfbuzz.cppm")]
                assert len(sources) == 1, sources
                source = sources[0].parent.parent
                declared = tomllib.loads((source / "mcpp.toml").read_text(encoding="utf-8"))["runtime"]["deploy"]
                roots = list(relocated.rglob("licenses/harfbuzz"))
                assert len(roots) == 1, f"Missing HarfBuzz runtime license tree: {roots}"
                for entry in declared:
                    notice = source / entry["from"]
                    copied = roots[0].parent.parent / entry["to"] / notice.name
                    assert copied.is_file() and copied.read_bytes() == notice.read_bytes(), copied
                assert b'"Old MIT" license' in (roots[0] / "upstream/harfbuzz/COPYING").read_bytes()
                assert b"Apache License" in (roots[0] / "LICENSE").read_bytes()
                assert b"mcpp-community" in (roots[0] / "NOTICE").read_bytes()
                print(f"Verified {len(declared)} byte-identical wrapper/HarfBuzz license files", flush=True)
            elif identity == "mcpplibs.mwrap.sdl3":
                # SDL is zlib-licensed and linked statically: its license and
                # README travel with the program, beside the wrapper's.
                sources = [path for store in (home / "xpkgs", home / "registry/data/xpkgs")
                           for path in store.glob(f"mcpplibs.mwrap-x-sdl3/{version}/*/src/sdl3.cppm")]
                assert len(sources) == 1, sources
                source = sources[0].parent.parent
                declared = tomllib.loads((source / "mcpp.toml").read_text(encoding="utf-8"))["runtime"]["deploy"]
                roots = list(relocated.rglob("licenses/sdl3"))
                assert len(roots) == 1, f"Missing SDL runtime license tree: {roots}"
                for entry in declared:
                    notice = source / entry["from"]
                    copied = roots[0].parent.parent / entry["to"] / notice.name
                    assert copied.is_file() and copied.read_bytes() == notice.read_bytes(), copied
                assert b"Sam Lantinga" in (roots[0] / "upstream/sdl3/LICENSE.txt").read_bytes()
                assert b"Apache License" in (roots[0] / "LICENSE").read_bytes()
                assert b"mcpp-community" in (roots[0] / "NOTICE").read_bytes()
                print(f"Verified {len(declared)} byte-identical wrapper/SDL license files", flush=True)
            else:
                raise ValueError(f"No deployment acceptance contract for {identity}")
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
            if identity == "mcpplibs.mwrap.opencv":
                encoded = (empty_home / "out.png").read_bytes()
                assert encoded[:8] == b"\x89PNG\r\n\x1a\n", "Relocated template did not create a PNG"
                assert int.from_bytes(encoded[16:20], "big") == 64
                assert int.from_bytes(encoded[20:24], "big") == 64
            print("Verified relocated application bundle and byte-identical notices", flush=True)


if __name__ == "__main__":
    main()
