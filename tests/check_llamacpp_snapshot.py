#!/usr/bin/env python3
"""Hard gate for the llama.cpp b10069 descriptor cohort."""
from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REPORT_PATH = ROOT / "tools/llamacpp/snapshots/b10069.json"
DESCRIPTORS = {
    "compat.ggml-base": ROOT / "pkgs/c/compat.ggml-base.lua",
    "compat.ggml-cpu": ROOT / "pkgs/c/compat.ggml-cpu.lua",
    "compat.llamacpp": ROOT / "pkgs/c/compat.llamacpp.lua",
    "compat.ggml-metal": ROOT / "pkgs/c/compat.ggml-metal.lua",
}

LUA_DUMP = r'''
local function hex(value)
    return (value:gsub('.', function(c) return string.format('%02x', string.byte(c)) end))
end
local function key(value)
    if type(value) == 'number' then return 'n' .. tostring(value) end
    return 's' .. hex(tostring(value))
end
local function path_string(path)
    local parts = {}
    for i, value in ipairs(path) do parts[i] = key(value) end
    return table.concat(parts, ',')
end
local function sorted_keys(value)
    local keys = {}
    for k, _ in pairs(value) do table.insert(keys, k) end
    table.sort(keys, function(a, b)
        if type(a) ~= type(b) then return type(a) < type(b) end
        if type(a) == 'number' then return a < b end
        return tostring(a) < tostring(b)
    end)
    return keys
end
local function walk(value, path)
    if type(value) == 'table' then
        print('T\t' .. path_string(path))
        for _, k in ipairs(sorted_keys(value)) do
            table.insert(path, k)
            walk(value[k], path)
            table.remove(path)
        end
        return
    end
    print('V\t' .. path_string(path) .. '\t' .. type(value) .. '\t' .. hex(tostring(value)))
end
local ok, err = pcall(dofile, arg[1])
if not ok then io.stderr:write(err .. '\n'); os.exit(2) end
if type(package) ~= 'table' then io.stderr:write('descriptor did not define package table\n'); os.exit(2) end
walk(package, {})
'''


class CheckError(RuntimeError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise CheckError(message)


def find_lua() -> str:
    override = os.environ.get("LUA")
    if override:
        require(not any(ch.isspace() for ch in override),
                "LUA must name one interpreter executable")
        resolved = shutil.which(override)
        require(resolved is not None, f"LUA interpreter not found: {override}")
        return resolved
    for candidate in ("lua5.4", "lua"):
        resolved = shutil.which(candidate)
        if resolved:
            return resolved
    raise CheckError("Lua interpreter not found (tried lua5.4, then lua; set LUA to override)")


def _decode_path(value: str) -> list[str | int]:
    if not value:
        return []
    result: list[str | int] = []
    for item in value.split(","):
        if item.startswith("n"):
            result.append(int(item[1:]))
        elif item.startswith("s"):
            result.append(bytes.fromhex(item[1:]).decode())
        else:
            raise CheckError(f"invalid Lua path token: {item}")
    return result


def load_descriptor(lua: str, path: Path) -> dict:
    result = subprocess.run(
        [lua, "-", str(path)], input=LUA_DUMP, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    )
    require(result.returncode == 0,
            f"cannot load {path.relative_to(ROOT)} with {lua}: {result.stderr.strip()}")
    root: dict = {}
    for raw in result.stdout.splitlines():
        columns = raw.split("\t")
        require(columns[0] in {"T", "V"}, f"invalid Lua row: {raw!r}")
        path_parts = _decode_path(columns[1])
        if not path_parts:
            continue
        current = root
        for key in path_parts[:-1]:
            current = current.setdefault(key, {})
        key = path_parts[-1]
        if columns[0] == "T":
            current.setdefault(key, {})
            continue
        require(len(columns) == 4, f"invalid Lua scalar row: {raw!r}")
        scalar_type = columns[2]
        value = bytes.fromhex(columns[3]).decode()
        if scalar_type == "boolean":
            scalar: object = value == "true"
        elif scalar_type == "number":
            scalar = float(value) if "." in value else int(value)
        else:
            scalar = value
        current[key] = scalar
    require(root.get("name") in DESCRIPTORS,
            f"unexpected descriptor identity in {path.relative_to(ROOT)}")
    return root


def array(value: object, context: str) -> list:
    require(isinstance(value, dict), f"{context} must be a Lua array")
    keys = sorted(value)
    require(keys == list(range(1, len(keys) + 1)), f"{context} is not a dense Lua array")
    return [value[key] for key in keys]


def get_path(value: dict, *path: str) -> object:
    current: object = value
    for key in path:
        require(isinstance(current, dict) and key in current,
                f"missing descriptor field: {'.'.join(path)}")
        current = current[key]
    return current


def iter_tables(value: object, path: tuple = ()):
    if not isinstance(value, dict):
        return
    yield path, value
    for key, child in value.items():
        if isinstance(child, dict):
            yield from iter_tables(child, path + (key,))


def normalized_source(source: str, package_name: str) -> str | None:
    if source == "mcpp_generated/ggml_cpp.cpp":
        return "ggml/src/ggml.cpp"
    if source == "mcpp_generated/ggml-cpu_cpp.cpp":
        return "ggml/src/ggml-cpu/ggml-cpu.cpp"
    if source == "mcpp_generated/ggml_metal_device_m.m":
        return "ggml/src/ggml-metal/ggml-metal-device.m"
    if source.startswith("mcpp_generated/") or "*" not in source:
        return None
    normalized = source.replace("*/", "", 1)
    require("*" not in normalized, f"wildcard source is not auditable: {package_name}: {source}")
    return normalized


def descriptor_sources(descriptor: dict) -> list[str]:
    sources: list[str] = []
    mcpp = get_path(descriptor, "mcpp")
    for path, table in iter_tables(mcpp):
        if path and path[-1] == "sources":
            sources.extend(array(table, f"{descriptor['name']}.mcpp.{'.'.join(map(str, path))}"))
    return sources


def check_cohort(descriptors: dict[str, dict], report: dict) -> None:
    identity = report["upstream"]
    tag = identity["tag"]
    expected_platforms = {
        "compat.ggml-base": {"linux", "macosx", "windows"},
        "compat.ggml-cpu": {"linux", "macosx", "windows"},
        "compat.llamacpp": {"linux", "macosx", "windows"},
        "compat.ggml-metal": {"macosx"},
    }
    for name, descriptor in descriptors.items():
        require(descriptor["name"] == name, f"descriptor name mismatch for {name}")
        xpm = get_path(descriptor, "xpm")
        require(set(xpm) == expected_platforms[name],
                f"{name} platform cohort drift: {sorted(xpm)}")
        for platform, versions in xpm.items():
            require(set(versions) == {tag},
                    f"{name}/{platform} must expose only {tag}")
            release = versions[tag]
            require(release.get("sha256") == identity["sha256"],
                    f"{name}/{platform}/{tag} SHA drift")
            url = release.get("url")
            global_url = url.get("GLOBAL") if isinstance(url, dict) else url
            require(global_url == identity["url"],
                    f"{name}/{platform}/{tag} URL drift")


def check_dependencies(descriptors: dict[str, dict], tag: str) -> None:
    edges: dict[str, set[str]] = {name: set() for name in descriptors}
    for name, descriptor in descriptors.items():
        for path, table in iter_tables(get_path(descriptor, "mcpp")):
            if not path or path[-1] != "deps":
                continue
            for dependency, version in table.items():
                require(version == tag,
                        f"{name} dependency {dependency} must be exactly {tag}")
                require(dependency in descriptors,
                        f"{name} has unexpected internal dependency {dependency}")
                edges[name].add(dependency)

    visiting: set[str] = set()
    visited: set[str] = set()

    def visit(name: str) -> None:
        require(name not in visiting, f"internal dependency cycle at {name}")
        if name in visited:
            return
        visiting.add(name)
        for dependency in edges[name]:
            visit(dependency)
        visiting.remove(name)
        visited.add(name)

    for name in edges:
        visit(name)


def check_sources(descriptors: dict[str, dict], report: dict) -> None:
    report_tus = set()
    for group, sources in report["sources"].items():
        for source in sources:
            if Path(source).suffix not in {".c", ".cc", ".cpp", ".m", ".mm"}:
                continue
            if group == "models" and not source.startswith("src/"):
                source = "src/" + source
            report_tus.add(source)

    owners: dict[str, set[str]] = {}
    for name, descriptor in descriptors.items():
        for source in descriptor_sources(descriptor):
            normalized = normalized_source(source, name)
            if normalized is None:
                continue
            require(normalized in report_tus,
                    f"{name} source is absent from snapshot report: {normalized}")
            owners.setdefault(normalized, set()).add(name)
    duplicate = {source: names for source, names in owners.items() if len(names) != 1}
    require(not duplicate, f"upstream TU ownership drift: {duplicate}")

    exact_groups = {
        "ggml_base": "compat.ggml-base",
        "ggml_registry": "compat.llamacpp",
        "llama_core": "compat.llamacpp",
        "models": "compat.llamacpp",
        "ggml_metal": "compat.ggml-metal",
    }
    for group, expected_owner in exact_groups.items():
        for source in report["sources"][group]:
            if Path(source).suffix not in {".c", ".cc", ".cpp", ".m", ".mm"}:
                continue
            if group == "models" and not source.startswith("src/"):
                source = "src/" + source
            require(owners.get(source) == {expected_owner},
                    f"{group} TU must have exactly one owner ({expected_owner}): {source}")

    core_sources = descriptor_sources(descriptors["compat.llamacpp"])
    require("*/src/models/*.cpp" not in core_sources,
            "compat.llamacpp must not use a model wildcard")
    actual_models = sorted(
        source.removeprefix("*/src/") for source in core_sources
        if source.startswith("*/src/models/")
    )
    require(actual_models == report["sources"]["models"],
            f"compat.llamacpp model TU drift: expected {len(report['sources']['models'])}, "
            f"got {len(actual_models)}")


def all_define_sites(descriptors: dict[str, dict]) -> dict[str, list[tuple[str, tuple, dict]]]:
    sites: dict[str, list[tuple[str, tuple, dict]]] = {}
    for name, descriptor in descriptors.items():
        for path, table in iter_tables(get_path(descriptor, "mcpp")):
            if "defines" not in table:
                continue
            for define in array(table["defines"], f"{name}.{path}.defines"):
                sites.setdefault(define, []).append((name, path, table))
    return sites


def check_registry_and_features(descriptors: dict[str, dict], report: dict) -> None:
    registry = set(report["sources"]["ggml_registry"])
    for name, descriptor in descriptors.items():
        owned = {
            normalized_source(source, name)
            for source in descriptor_sources(descriptor)
        }
        if name == "compat.llamacpp":
            require(registry <= owned, "compat.llamacpp must own all registry TUs")
        else:
            require(not registry.intersection(owned), f"{name} must not own registry TUs")

    sites = all_define_sites(descriptors)
    for macro in ("GGML_USE_CPU", "GGML_USE_METAL"):
        macro_sites = sites.get(macro, [])
        require(len(macro_sites) == 1, f"{macro} must have one registry-only owner")
        name, _path, table = macro_sites[0]
        require(name == "compat.llamacpp", f"{macro} must be owned by compat.llamacpp")
        require(table.get("glob") == "*/ggml/src/ggml-backend-reg.cpp",
                f"{macro} must be scoped to ggml-backend-reg.cpp")

    providers = []
    for name, descriptor in descriptors.items():
        provides = descriptor["mcpp"].get("provides")
        if provides and "ggml.accelerator" in array(provides, f"{name}.mcpp.provides"):
            providers.append(name)
    require(providers == ["compat.ggml-metal"],
            f"ggml.accelerator provider drift: {providers}")
    require(descriptors["compat.ggml-metal"]["mcpp"].get("deps")
            == {"compat.ggml-base": report["upstream"]["tag"]},
            "compat.ggml-metal dependency drift")
    metal_ldflags = array(
        descriptors["compat.ggml-metal"]["mcpp"].get("ldflags"),
        "compat.ggml-metal.ldflags",
    )
    expected_ldflags = [item for framework in report["metal"]["frameworks"]
                        for item in ("-framework", framework)]
    require(metal_ldflags == expected_ldflags, "Metal framework linkage drift")

    core = descriptors["compat.llamacpp"]["mcpp"]
    for platform in ("linux", "windows"):
        features = core.get(platform, {}).get("features", {})
        require("backend-metal" not in features,
                f"backend-metal must be absent from {platform} synthesis")
    feature = get_path(core, "macosx", "features", "backend-metal")
    require(feature.get("deps") == {"compat.ggml-metal": report["upstream"]["tag"]},
            "backend-metal provider dependency drift")
    require(array(feature.get("requires"), "backend-metal.requires") == ["ggml.accelerator"],
            "backend-metal capability requirement drift")
    flags = array(feature.get("flags"), "backend-metal.flags")
    require(len(flags) == 1
            and flags[0].get("glob") == "*/ggml/src/ggml-backend-reg.cpp"
            and array(flags[0].get("defines"), "backend-metal.flags.defines") == ["GGML_USE_METAL"],
            "backend-metal registry flag drift")


def check_cpu_private_macros(descriptors: dict[str, dict]) -> None:
    cpu = descriptors["compat.ggml-cpu"]["mcpp"]
    for field in ("cflags", "cxxflags"):
        require("-DGGML_USE_CPU_REPACK" in array(cpu[field], f"compat.ggml-cpu.{field}"),
                "CPU repack macro must remain a private compile flag")
    require(array(cpu["features"]["default"]["implies"], "cpu.default.implies") == ["llamafile"],
            "llamafile must remain default-on")
    llamafile_flags = array(cpu["features"]["llamafile"]["flags"], "cpu.llamafile.flags")
    require(llamafile_flags and all(
        "GGML_USE_LLAMAFILE" in array(flag["defines"], "cpu.llamafile.defines")
        for flag in llamafile_flags),
        "llamafile macro must remain feature-scoped")
    define_sites = all_define_sites(descriptors)
    require("GGML_USE_CPU_REPACK" not in define_sites,
            "CPU repack macro must not be an interface define")
    for name, descriptor in descriptors.items():
        interface = descriptor["mcpp"].get("interface_defines", {})
        text = repr(interface)
        require("GGML_USE_CPU_REPACK" not in text and "GGML_USE_LLAMAFILE" not in text,
                f"{name} leaks a CPU implementation macro")


def check_report_metadata_contracts(descriptors: dict[str, dict], report: dict) -> None:
    build_info = get_path(
        descriptors["compat.ggml-base"], "mcpp", "generated_files",
        "mcpp_generated/ggml_build_info.h",
    )
    require(f'#define GGML_VERSION "{report["upstream"]["tag"]}"' in build_info,
            "generated GGML version drift")
    require(f'#define GGML_COMMIT "{report["upstream"]["commit"]}"' in build_info,
            "generated GGML commit drift")

    windows_ldflags = array(
        get_path(descriptors["compat.ggml-cpu"], "mcpp", "windows", "ldflags"),
        "compat.ggml-cpu.windows.ldflags",
    )
    expected_windows = [f"-l{library}" for library in report["platform_links"]["windows_cpu"]]
    require(windows_ldflags == expected_windows, "Windows CPU linkage drift")

    cpp20_sources = []
    for flag in array(descriptors["compat.llamacpp"]["mcpp"]["flags"],
                      "compat.llamacpp.flags"):
        if flag.get("cxxflags") and "-std=c++20" in array(
                flag["cxxflags"], "compat.llamacpp.flags.cxxflags"):
            source = normalized_source(flag.get("glob", ""), "compat.llamacpp")
            require(source is not None, "C++20 exception must target one upstream TU")
            cpp20_sources.append(source)
    require(sorted(cpp20_sources) == report["dialect_exceptions"]["c++20"],
            "C++20 dialect exception drift")


def check_metal_build_contract(descriptors: dict[str, dict], report: dict) -> None:
    generated = get_path(descriptors["compat.ggml-metal"], "mcpp", "generated_files")
    source = generated.get("build.mcpp")
    require(isinstance(source, str) and source, "compat.ggml-metal build.mcpp is missing")
    compiler = shutil.which(os.environ.get("CXX", "c++"))
    require(compiler is not None, "host C++ compiler not found for build.mcpp contract")

    with tempfile.TemporaryDirectory(prefix="llamacpp-build-contract-") as td:
        root = Path(td)
        program = root / "build.cpp"
        executable = root / "build"
        program.write_text(source)
        compiled = subprocess.run(
            [compiler, "-std=c++17", str(program), "-o", str(executable)],
            text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        require(compiled.returncode == 0,
                f"cannot compile compat.ggml-metal build.mcpp: {compiled.stderr}")

        def run(target_os: str, target_arch: str, manifest: Path, output: Path):
            env = os.environ.copy()
            env.update({
                "MCPP_TARGET_OS": target_os,
                "MCPP_TARGET_ARCH": target_arch,
                "MCPP_MANIFEST_DIR": str(manifest),
                "MCPP_OUT_DIR": str(output),
            })
            return subprocess.run(
                [str(executable)], env=env, text=True,
                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            )

        missing = root / "manifest"
        missing.mkdir()
        output = root / "out"
        linux = run("linux", "x86_64", missing, output)
        require(linux.returncode != 0 and "requires target_os=macos" in linux.stderr,
                "build.mcpp must reject non-macOS targets")
        mac_x86 = run("macos", "x86_64", missing, output)
        require(mac_x86.returncode != 0 and "requires target_arch=aarch64" in mac_x86.stderr,
                "build.mcpp must reject non-aarch64 macOS targets")

        upstream = missing / "llama.cpp-b10069"
        metal_dir = upstream / "ggml/src/ggml-metal"
        metal_dir.mkdir(parents=True)
        common = upstream / "ggml/src/ggml-common.h"
        metal = metal_dir / "ggml-metal.metal"
        impl = metal_dir / "ggml-metal-impl.h"
        common.write_text("COMMON_PAYLOAD\n")
        impl.write_text("IMPL_PAYLOAD\n")
        metal.write_text("A __embed_ggml-common.h__ B #include \"ggml-metal-impl.h\" C\n")
        success = run("macos", "aarch64", missing, output)
        require(success.returncode == 0,
                f"build.mcpp macOS/aarch64 contract failed: {success.stderr}")
        assembly = output / "ggml-metal-embed.s"
        expected_lines = {
            f"mcpp:generated={assembly}",
            "mcpp:cfg=GGML_METAL_EMBED_LIBRARY",
        }
        for relative in report["metal"]["shader_inputs"]:
            expected_lines.add(f"mcpp:rerun-if-changed={upstream / relative}")
        actual_lines = success.stdout.splitlines()
        require(len(actual_lines) == len(expected_lines)
                and set(actual_lines) == expected_lines,
                f"build.mcpp stdout contract drift: {success.stdout!r}")
        merged_text = (output / "ggml-metal-embed.metal").read_text()
        require(merged_text.count("COMMON_PAYLOAD") == 1
                and merged_text.count("IMPL_PAYLOAD") == 1,
                "build.mcpp must embed each shader input exactly once")
        assembly_text = assembly.read_text()
        for marker in ("_ggml_metallib_start", ".incbin", "_ggml_metallib_end"):
            require(marker in assembly_text, f"build.mcpp assembly missing {marker}")


def main() -> int:
    try:
        report = json.loads(REPORT_PATH.read_text())
        lua = find_lua()
        descriptors = {name: load_descriptor(lua, path)
                       for name, path in DESCRIPTORS.items()}
        check_cohort(descriptors, report)
        check_dependencies(descriptors, report["upstream"]["tag"])
        check_sources(descriptors, report)
        check_registry_and_features(descriptors, report)
        check_cpu_private_macros(descriptors)
        check_report_metadata_contracts(descriptors, report)
        check_metal_build_contract(descriptors, report)
    except (CheckError, OSError, json.JSONDecodeError) as error:
        print(f"llama.cpp snapshot check failed: {error}", file=sys.stderr)
        return 1
    print("llama.cpp snapshot cohort matches b10069 report")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
