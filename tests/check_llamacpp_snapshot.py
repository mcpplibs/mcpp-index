#!/usr/bin/env python3
"""Hard gate for the ggml-org.llamacpp llama.cpp b10069 descriptor."""
from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
REPORT_PATH = ROOT / "tools/llamacpp/snapshots/b10069.json"
REPORT_PATH_B10107 = ROOT / "tools/llamacpp/snapshots/b10107.json"
DESCRIPTORS = {
    "ggml-org.llamacpp": ROOT / "pkgs/g/ggml-org.llamacpp.lua",
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


def _default_feature_closure(table: dict, context: str) -> set[str]:
    features = table.get("features", {})
    require(isinstance(features, dict), f"{context}.features must be a table")
    if "default" not in features:
        return set()

    default = features["default"]
    require(isinstance(default, dict),
            f"{context}.features.default must be a table")
    enabled: set[str] = set()
    pending = array(
        default.get("implies", {}),
        f"{context}.features.default.implies")
    require(all(isinstance(name, str) for name in pending),
            f"{context}.features.default.implies must contain feature names")
    while pending:
        feature_name = pending.pop()
        if feature_name == "default":
            continue
        if feature_name in enabled:
            continue
        require(feature_name in features,
                f"{context} implies unknown feature: {feature_name}")
        feature = features[feature_name]
        require(isinstance(feature, dict),
                f"{context}.features.{feature_name} must be a table")
        enabled.add(feature_name)

        implied_features = array(
            feature.get("implies", {}),
            f"{context}.features.{feature_name}.implies")
        require(all(isinstance(name, str) for name in implied_features),
                f"{context}.features.{feature_name}.implies must contain feature names")
        pending.extend(implied_features)
    return enabled


def descriptor_sources_for_platform(descriptor: dict, platform: str) -> list[str]:
    mcpp = get_path(descriptor, "mcpp")
    context = f"{descriptor['name']}.mcpp"
    platform_table = mcpp.get(platform, {})
    require(isinstance(platform_table, dict),
            f"{context}.{platform} must be a table")

    result: list[str] = []
    merged_fields: dict[str, dict[str, list]] = {}
    for table, scope_context in (
            (mcpp, context),
            (platform_table, f"{context}.{platform}")):
        if "sources" in table:
            result.extend(array(table["sources"], f"{scope_context}.sources"))
        features = table.get("features", {})
        require(isinstance(features, dict),
                f"{scope_context}.features must be a table")
        for feature_name, feature in features.items():
            require(isinstance(feature_name, str),
                    f"{scope_context}.features keys must be feature names")
            require(isinstance(feature, dict),
                    f"{scope_context}.features.{feature_name} must be a table")
            merged = merged_fields.setdefault(feature_name, {})
            for field in ("implies", "sources"):
                if field in feature:
                    merged.setdefault(field, []).extend(array(
                        feature[field],
                        f"{scope_context}.features.{feature_name}.{field}"))

    effective_features = {
        feature_name: {
            field: dict(enumerate(values, start=1))
            for field, values in fields.items()
        }
        for feature_name, fields in merged_fields.items()
    }
    effective = {"features": effective_features}
    for feature_name in _default_feature_closure(effective, context):
        feature = effective_features[feature_name]
        if "sources" in feature:
            result.extend(array(
                feature["sources"],
                f"{context}.features.{feature_name}.sources"))
    return result


def check_cohort(descriptors: dict[str, dict], report: dict) -> None:
    require(set(descriptors) == {"ggml-org.llamacpp"},
            f"descriptor cohort drift: {sorted(descriptors)}")
    descriptor = descriptors["ggml-org.llamacpp"]
    identity = report["upstream"]
    require(descriptor["name"] == "ggml-org.llamacpp", "descriptor name drift")
    xpm = get_path(descriptor, "xpm")
    require(set(xpm) == {"linux", "macosx", "windows"},
            f"ggml-org.llamacpp platform cohort drift: {sorted(xpm)}")
    # Validate xpm entries: must contain at least the snapshot tag
    tag = identity["tag"]
    for platform, versions in xpm.items():
        require(tag in versions,
                f"ggml-org.llamacpp/{platform} must expose {tag}")
        release = versions[tag]
        require(release.get("sha256") == identity["sha256"],
                f"ggml-org.llamacpp/{platform}/{tag} SHA drift")
        require(release.get("url") == identity["url"],
                f"ggml-org.llamacpp/{platform}/{tag} URL drift")


def check_dependencies(descriptors: dict[str, dict], tag: str) -> None:
    descriptor = descriptors["ggml-org.llamacpp"]
    mcpp = get_path(descriptor, "mcpp")
    require(mcpp.get("deps", {}) == {},
            "ggml-org.llamacpp must not depend on component packages")
    require(mcpp.get("provides", {}) in ({}, []),
            "ggml-org.llamacpp must not publish provider capabilities")
    for scope in ("linux", "macosx", "windows"):
        surface = mcpp.get(scope, {})
        require(isinstance(surface, dict), f"ggml-org.llamacpp {scope} scope must be a table")
        require(surface.get("deps", {}) == {},
                f"ggml-org.llamacpp/{scope} must not depend on component packages")
    feature = get_path(mcpp, "features", "backend-metal")
    require(feature.get("deps", {}) == {},
            "backend-metal must be an in-package feature")
    require(feature.get("requires", {}) in ({}, []),
            "backend-metal must not require a provider capability")


def _report_tus(report: dict) -> set[str]:
    result = set()
    for group, sources in report["sources"].items():
        for source in sources:
            if Path(source).suffix not in {".c", ".cc", ".cpp", ".m", ".mm"}:
                continue
            result.add("src/" + source if group == "models" else source)
    return result


def _group_tus(report: dict, groups: tuple[str, ...]) -> set[str]:
    return {
        ("src/" + source if group == "models" else source)
        for group in groups
        for source in report["sources"][group]
        if Path(source).suffix in {".c", ".cc", ".cpp", ".m", ".mm"}
    }


def check_sources(descriptors: dict[str, dict], report: dict,
                  secondary_reports: list[dict] | None = None) -> None:
    descriptor = descriptors["ggml-org.llamacpp"]
    report_tus = _report_tus(report)
    if secondary_reports:
        for sr in secondary_reports:
            report_tus |= _report_tus(sr)
    default_groups = ("ggml_base", "ggml_registry", "ggml_cpu_common",
                      "llama_core", "models")
    arch_groups = {
        "linux": ("ggml_cpu_x86",),
        "macosx": ("ggml_cpu_arm",),
        "windows": ("ggml_cpu_x86",),
    }
    for platform in ("linux", "macosx", "windows"):
        actual: set[str] = set()
        for source in descriptor_sources_for_platform(descriptor, platform):
            normalized = normalized_source(source, "ggml-org.llamacpp")
            if normalized is None:
                continue
            if normalized not in report_tus:
                # Model files may exist only in newer upstream versions
                # (e.g. laguna.cpp added in b10107, absent from b10069).
                # The final model-count check catches truly unknown files.
                if not normalized.startswith("src/models/"):
                    require(False,
                            f"ggml-org.llamacpp source is absent from snapshot "
                            f"report: {normalized}")
            require(normalized not in actual,
                    f"duplicate upstream TU ownership on {platform}: {normalized}")
            actual.add(normalized)
        expected = _group_tus(report, default_groups + arch_groups[platform])
        if secondary_reports:
            for sr in secondary_reports:
                expected |= _group_tus(sr, default_groups + arch_groups[platform])
        missing_from_descriptor = expected - actual
        extra_in_descriptor = actual - expected
        require(not missing_from_descriptor,
                f"default TU set drift on {platform}: missing={sorted(missing_from_descriptor)}")
        require(not extra_in_descriptor or all(
            source.startswith("src/models/") for source in extra_in_descriptor
        ), f"non-model default TU set drift on {platform}: extra={sorted(extra_in_descriptor)}")

    core_sources = descriptor_sources(descriptor)
    require("*/src/models/*.cpp" not in core_sources,
            "ggml-org.llamacpp must not use a model wildcard")
    actual_models = sorted(
        source.removeprefix("*/src/") for source in core_sources
        if source.startswith("*/src/models/")
    )
    # The descriptor may list models that exist only in newer upstream
    # versions (e.g. laguna.cpp added in b10107).  Collect every model
    # known to ANY snapshot so we only flag files that don't exist upstream.
    all_snapshot_models = set(report["sources"]["models"])
    if secondary_reports:
        for sr in secondary_reports:
            all_snapshot_models |= set(sr["sources"]["models"])
    unknown = sorted(set(actual_models) - all_snapshot_models)
    require(not unknown,
            f"ggml-org.llamacpp model TU not in any snapshot: {unknown}")

    metal_source_list = [
        normalized_source(source, "ggml-org.llamacpp")
        for source in array(
            get_path(descriptor, "mcpp", "features", "backend-metal", "sources"),
            "ggml-org.llamacpp.features.backend-metal.sources",
        )
    ]
    metal_sources = set(metal_source_list)
    metal_sources.discard(None)
    require(len(metal_sources) == len(metal_source_list),
            "duplicate Metal TU ownership")
    expected_metal = _group_tus(report, ("ggml_metal",))
    require(metal_sources == expected_metal,
            f"Metal TU set drift: missing={sorted(expected_metal - metal_sources)}, "
            f"extra={sorted(metal_sources - expected_metal)}")


def all_define_sites(descriptors: dict[str, dict]) -> dict[str, list[tuple[str, tuple, dict]]]:
    sites: dict[str, list[tuple[str, tuple, dict]]] = {}
    for name, descriptor in descriptors.items():
        for path, table in iter_tables(get_path(descriptor, "mcpp")):
            if "defines" not in table:
                continue
            for define in array(table["defines"], f"{name}.{path}.defines"):
                sites.setdefault(define, []).append((name, path, table))
    return sites


def all_macro_sites(descriptors: dict[str, dict]) -> dict[str, list[tuple[str, tuple, str, dict]]]:
    tracked = {
        "GGML_USE_CPU", "GGML_USE_METAL",
        "GGML_USE_CPU_REPACK", "GGML_USE_LLAMAFILE",
    }
    sites: dict[str, list[tuple[str, tuple, str, dict]]] = {}
    for name, descriptor in descriptors.items():
        for path, table in iter_tables(get_path(descriptor, "mcpp")):
            for field in ("cflags", "cxxflags", "defines",
                          "interface_defines", "public_defines"):
                if field not in table:
                    continue
                values = array(table[field], f"{name}.{path}.{field}")
                index = 0
                while index < len(values):
                    value = values[index]
                    require(isinstance(value, str), f"{name}.{path}.{field} must contain strings")
                    macro = value
                    if field in {"cflags", "cxxflags"}:
                        if value in {"-D", "/D"}:
                            index += 1
                            if index >= len(values):
                                break
                            macro = values[index]
                            require(isinstance(macro, str),
                                    f"{name}.{path}.{field} split define must be a string")
                        elif value.startswith("-D") or value.startswith("/D"):
                            macro = value[2:].strip()
                        else:
                            index += 1
                            continue
                    macro = macro.split("=", 1)[0]
                    if macro in tracked:
                        sites.setdefault(macro, []).append((name, path, field, table))
                    index += 1
    return sites


def check_registry_and_features(descriptors: dict[str, dict], report: dict) -> None:
    descriptor = descriptors["ggml-org.llamacpp"]
    registry = set(report["sources"]["ggml_registry"])
    owned = {normalized_source(source, "ggml-org.llamacpp")
             for source in descriptor_sources(descriptor)}
    require(registry <= owned, "ggml-org.llamacpp must own all registry TUs")

    sites = all_define_sites(descriptors)
    for macro in ("GGML_USE_CPU", "GGML_USE_METAL"):
        macro_sites = sites.get(macro, [])
        require(len(macro_sites) == 1, f"{macro} must have one registry-only owner")
        name, _path, table = macro_sites[0]
        require(name == "ggml-org.llamacpp", f"{macro} must be owned by ggml-org.llamacpp")
        require(table.get("glob") == "*/ggml/src/ggml-backend-reg.cpp",
                f"{macro} must be scoped to ggml-backend-reg.cpp")

    metal_ldflags = array(descriptor["mcpp"]["macosx"].get("ldflags"),
                          "ggml-org.llamacpp.macosx.ldflags")
    expected_ldflags = [item for framework in report["metal"]["frameworks"]
                        for item in ("-framework", framework)]
    require(metal_ldflags == ["-lpthread", "-lm"] + expected_ldflags,
            "Metal framework linkage drift")

    feature_sites = []
    mcpp = descriptor["mcpp"]
    features = get_path(mcpp, "features")
    require(set(features) == {"default", "backend-cpu", "backend-metal"},
            "ggml-org.llamacpp must declare exactly CPU and Metal backend features")
    default = get_path(features, "default")
    require(array(default.get("implies"), "features.default.implies") == ["backend-cpu"],
            "ggml-org.llamacpp default feature must select backend-cpu")
    require(get_path(features, "backend-cpu") == {},
            "backend-cpu must remain an explicit no-op feature")
    if "backend-metal" in mcpp.get("features", {}):
        feature_sites.append(("ggml-org.llamacpp", "common"))
    for platform in ("linux", "macosx", "windows"):
        if "backend-metal" in mcpp.get(platform, {}).get("features", {}):
            feature_sites.append(("ggml-org.llamacpp", platform))
    require(feature_sites == [("ggml-org.llamacpp", "common")],
            f"backend-metal feature placement drift: {feature_sites}")

    feature = get_path(mcpp, "features", "backend-metal")
    flags = array(feature.get("flags"), "backend-metal.flags")
    metal_flags = [flag for flag in flags if flag.get("defines")]
    require(len(metal_flags) == 1
            and metal_flags[0].get("glob") == "*/ggml/src/ggml-backend-reg.cpp"
            and array(metal_flags[0].get("defines"), "backend-metal.flags.defines")
            == ["GGML_USE_METAL"],
            "backend-metal registry flag drift")


def check_cpu_private_macros(descriptors: dict[str, dict]) -> None:
    cpu = descriptors["ggml-org.llamacpp"]["mcpp"]
    for field in ("cflags", "cxxflags"):
        require("-DGGML_USE_CPU_REPACK" in array(cpu[field], f"ggml-org.llamacpp.{field}"),
                "CPU repack macro must remain a private compile flag")
    llamafile_sites = all_macro_sites(descriptors).get("GGML_USE_LLAMAFILE", [])
    require(len(llamafile_sites) == 2 and all(
        name == "ggml-org.llamacpp" and path[:1] == ("flags",) and field == "defines"
        for name, path, field, _table in llamafile_sites
    ),
        "llamafile macro must remain CPU-source-scoped")
    require({table.get("glob") for _name, _path, _field, table in llamafile_sites} == {
        "*/ggml/src/ggml-cpu/**", "mcpp_generated/ggml-cpu_cpp.cpp",
    }, "GGML_USE_LLAMAFILE private glob drift")

    sites = all_macro_sites(descriptors)
    cpu_registry = sites.get("GGML_USE_CPU", [])
    require(len(cpu_registry) == 1, "GGML_USE_CPU must have one private registry site")
    name, path, field, table = cpu_registry[0]
    require(name == "ggml-org.llamacpp" and path[:1] == ("flags",)
            and field == "defines"
            and table.get("glob") == "*/ggml/src/ggml-backend-reg.cpp",
            "GGML_USE_CPU must remain on the core common registry flag")

    metal_registry = sites.get("GGML_USE_METAL", [])
    require(len(metal_registry) == 1, "GGML_USE_METAL must have one private registry site")
    name, path, field, table = metal_registry[0]
    require(name == "ggml-org.llamacpp"
            and path[:3] == ("features", "backend-metal", "flags")
            and field == "defines"
            and table.get("glob") == "*/ggml/src/ggml-backend-reg.cpp",
            "GGML_USE_METAL must remain on the backend-metal registry flag")


def check_report_metadata_contracts(descriptors: dict[str, dict], report: dict,
                                   secondary_reports: list[dict] | None = None) -> None:
    build_info = get_path(
        descriptors["ggml-org.llamacpp"], "mcpp", "generated_files",
        "mcpp_generated/ggml_build_info.h",
    )
    require(f'#define GGML_VERSION "{report["upstream"]["tag"]}"' in build_info,
            "generated GGML version drift")
    require(f'#define GGML_COMMIT "{report["upstream"]["commit"]}"' in build_info,
            "generated GGML commit drift")

    windows_ldflags = array(
        get_path(descriptors["ggml-org.llamacpp"], "mcpp", "windows", "ldflags"),
        "ggml-org.llamacpp.windows.ldflags",
    )
    expected_windows = [f"-l{library}" for library in report["platform_links"]["windows_cpu"]]
    require(windows_ldflags == expected_windows, "Windows CPU linkage drift")

    cpp20_sources = []
    for flag in array(descriptors["ggml-org.llamacpp"]["mcpp"]["flags"],
                      "ggml-org.llamacpp.flags"):
        if flag.get("cxxflags") and "-std=c++20" in array(
                flag["cxxflags"], "ggml-org.llamacpp.flags.cxxflags"):
            source = normalized_source(flag.get("glob", ""), "ggml-org.llamacpp")
            require(source is not None, "C++20 exception must target one upstream TU")
            cpp20_sources.append(source)
    # The descriptor may declare c++20 exceptions for models that exist
    # only in newer upstream versions (e.g. laguna.cpp added in b10107).
    # Collect every c++20 exception known to ANY snapshot.
    all_cpp20 = set(report["dialect_exceptions"]["c++20"])
    if secondary_reports:
        for sr in secondary_reports:
            all_cpp20 |= set(sr["dialect_exceptions"]["c++20"])
    unknown_cpp20 = sorted(set(cpp20_sources) - all_cpp20)
    require(not unknown_cpp20,
            f"C++20 dialect exception not in any snapshot: {unknown_cpp20}")
    missing_cpp20 = sorted(all_cpp20 - set(cpp20_sources))
    require(not missing_cpp20,
            f"C++20 dialect exception drift: missing={missing_cpp20}")


def check_metal_build_contract(descriptors: dict[str, dict], report: dict) -> None:
    generated = get_path(descriptors["ggml-org.llamacpp"], "mcpp", "generated_files")
    source = generated.get("build.mcpp")
    require(isinstance(source, str) and source, "ggml-org.llamacpp build.mcpp is missing")
    for tool in ("/usr/bin/xcrun", "/usr/bin/metal", "/usr/bin/metallib"):
        require(tool not in source,
                f"forbidden absolute tool: {tool} (absolute Xcode Metal tool path)")
    process_launch = re.search(
        r"\b(?:(?:[A-Za-z_]\w*)::)*(?:system|popen|exec\w*|posix_spawn\w*)\s*\(",
        source,
    )
    require(process_launch is None,
            "ggml-org.llamacpp build.mcpp contains a forbidden process launch API")
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
                f"cannot compile ggml-org.llamacpp build.mcpp: {compiled.stderr}")

        def run(target_os: str, target_arch: str, manifest: Path, output: Path,
                features: tuple[str, ...]):
            env = os.environ.copy()
            for name in tuple(env):
                if name == "MCPP_FEATURES" or name.startswith("MCPP_FEATURE_"):
                    env.pop(name)
            env.update({
                "MCPP_TARGET_OS": target_os,
                "MCPP_TARGET_ARCH": target_arch,
                "MCPP_MANIFEST_DIR": str(manifest),
                "MCPP_OUT_DIR": str(output),
                "MCPP_FEATURES": ",".join(features),
            })
            for feature in features:
                feature_env = re.sub(r"[^A-Za-z0-9]", "_", feature.upper())
                env[f"MCPP_FEATURE_{feature_env}"] = "1"
            return subprocess.run(
                [str(executable)], env=env, text=True,
                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            )

        missing = root / "manifest"
        missing.mkdir()
        output = root / "out"
        disabled = run("linux", "x86_64", missing, output, ())
        require(disabled.returncode == 0 and not (output / "ggml-metal-embed.s").exists(),
                "build.mcpp must no-op when backend-metal is disabled")
        cpu = run("linux", "x86_64", missing, output, ("backend-cpu",))
        require(cpu.returncode == 0 and not (output / "ggml-metal-embed.s").exists(),
                "build.mcpp must accept explicit backend-cpu")
        for feature_name in ("backend-cuda", "backend-xxx", "undeclared"):
            invalid = run("linux", "x86_64", missing, output, (feature_name,))
            require(invalid.returncode != 0
                    and f"unsupported feature '{feature_name}'" in invalid.stderr,
                    f"build.mcpp must reject undeclared feature {feature_name}")
        metal_features = ("backend-cpu", "backend-metal")
        linux = run("linux", "x86_64", missing, output, metal_features)
        require(linux.returncode != 0 and "requires target_os=macos" in linux.stderr,
                "build.mcpp must reject non-macOS targets")
        mac_x86 = run("macos", "x86_64", missing, output, metal_features)
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
        success = run("macos", "aarch64", missing, output, metal_features)
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


def check_module_contract(descriptors: dict[str, dict]) -> None:
    mcpp = get_path(descriptors["ggml-org.llamacpp"], "mcpp")
    require(mcpp.get("targets") == {"llama": {"kind": "lib"}},
            "ggml-org.llamacpp must expose exactly one llama target")
    require(array(mcpp.get("modules"), "ggml-org.llamacpp.modules") == ["llama"],
            "ggml-org.llamacpp must expose exactly the llama module")
    generated = get_path(mcpp, "generated_files")
    for generated_name, source_name in (
            ("mcpp_generated/llama.cppm", "llama.cppm"),
            ("mcpp_generated/gen_exports/required_ggml.inc", "gen_exports/required_ggml.inc"),
            ("mcpp_generated/gen_exports/llama.inc", "gen_exports/llama.inc"),
    ):
        expected = (ROOT / "tools/llamacpp/module" / source_name).read_text()
        require(generated.get(generated_name) == expected,
                f"generated module input drift: {generated_name}")
    module = generated["mcpp_generated/llama.cppm"]
    require("export module llama;" in module
            and "#include <llama.h>" in module
            and "#include \"gen_exports/llama.inc\"" in module,
            "llama module wrapper contract drift")


def main() -> int:
    try:
        report = json.loads(REPORT_PATH.read_text())
        secondary_reports = []
        if REPORT_PATH_B10107.is_file():
            secondary_reports.append(json.loads(REPORT_PATH_B10107.read_text()))
        lua = find_lua()
        descriptors = {name: load_descriptor(lua, path)
                       for name, path in DESCRIPTORS.items()}
        check_cohort(descriptors, report)
        check_dependencies(descriptors, report["upstream"]["tag"])
        check_sources(descriptors, report, secondary_reports)
        check_registry_and_features(descriptors, report)
        check_cpu_private_macros(descriptors)
        check_report_metadata_contracts(descriptors, report, secondary_reports)
        check_metal_build_contract(descriptors, report)
        check_module_contract(descriptors)
    except (CheckError, OSError, json.JSONDecodeError) as error:
        print(f"llama.cpp snapshot check failed: {error}", file=sys.stderr)
        return 1
    print("ggml-org.llamacpp llama.cpp descriptor matches b10069 report")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
