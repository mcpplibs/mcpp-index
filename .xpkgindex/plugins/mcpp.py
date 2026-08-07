"""mcpp ecosystem plugin for xpkgindex.

Everything mcpp-specific about this index lives here: how a package is named,
how it is consumed (`import` / `#include` / a tool binary), what the `mcpp = {}`
extension block means, and which test project demonstrates it.

The core framework knows none of that — see
`.agents/docs/2026-08-06-xpkgindex-framework-and-site-redesign-design.md` §5.
"""

from __future__ import annotations

import glob
import json
import os
import re
from typing import Any, Dict, List, Optional

from xpkgindex.models import Block, Facet, FacetValue, Identity, RowSpec
from xpkgindex.plugins import Plugin

try:                                    # py3.11+
    import tomllib
except ModuleNotFoundError:             # pragma: no cover
    tomllib = None

# How a package is consumed. This is the axis a C++ user actually browses by,
# and unlike `categories` (which no descriptor in this repo sets) it is
# derivable from data that is already there.
def _t(en: str, zh: str, hant: str) -> Dict[str, str]:
    """A string the site renders in the reader's language.

    The framework resolves these maps per locale; anything left as a plain
    string stays as written. Identifiers are deliberately not run through
    here — `import`, `#include`, `modules`, `targets` are what you actually
    type or what mcpp.toml actually calls the field, and translating them
    would break the link to the file the block is describing.
    """
    return {"en": en, "zh": zh, "zh-Hant": hant}


SURFACES = [
    ("module", "import", "module"),
    ("header", "#include", "header"),
    ("tool", "tool", "tool"),
    ("external", _t("upstream mcpp.toml", "上游 mcpp.toml", "上游 mcpp.toml"), "neutral"),
]

_IMPORT_RE = re.compile(r"^\s*import\s+([A-Za-z_][\w.]*)\s*;", re.M)
_INCLUDE_RE = re.compile(r"^\s*#include\s+([<\"][^>\"]+[>\"])", re.M)
_TAG_RE = re.compile(r"/archive/refs/tags/(.+?)\.(?:tar\.gz|zip|tgz)$")
# Release assets carry the tag in the path instead — `tensorvia-cpu` publishes
# that way, and matching only archive URLs left it with no upstream data.
_RELEASE_TAG_RE = re.compile(r"/releases/download/([^/]+)/")
_IMPORT_IN_TEXT = re.compile(r"\bimport\s+([A-Za-z_][\w.]*)\s*;")
_EXPORT_MODULE_RE = re.compile(r"^\s*export\s+module\s+([A-Za-z_][\w.]*)\s*;", re.M)


def _project_export_module(text: str) -> str:
    """The module a `.cppm` interface unit exports — the authoritative name."""
    m = _EXPORT_MODULE_RE.search(text)
    return m.group(1) if m else ""

# mcpp resolves a bare package name in this namespace (issue #170's
# "tried: (mcpplibs, json)").
DEFAULT_NAMESPACE = "mcpplibs"


def _parse_repo(url: str):
    """-> (host, owner, name) for a repository URL."""
    parts = [p for p in (url or "").split("//")[-1].split("/") if p]
    if len(parts) < 3:
        return ("", "", "")
    name = parts[2][:-4] if parts[2].endswith(".git") else parts[2]
    return (parts[0], parts[1], name)


def _project_manifest(text: str) -> Dict[str, Any]:
    """Keep only the manifest fields the site renders.

    The cache is committed and reviewed in PRs, so it stores this projection
    rather than whole upstream files.
    """
    data: Dict[str, Any] = {}
    if tomllib is not None:
        try:
            data = tomllib.loads(text)
        except Exception:               # noqa: BLE001 - upstream may ship anything
            data = {}
    if not data:
        data = _manifest_fallback(text)

    pkg = data.get("package") or {}
    targets = data.get("targets") or {}
    build = data.get("build") or {}
    description = str(pkg.get("description") or "")

    # `modules` must be a list — `[modules]` is a *table* in some manifests and
    # picking up its keys produced `import sources;`.
    declared = pkg.get("modules") or data.get("modules") or []
    modules = [str(m) for m in declared] if isinstance(declared, list) else []
    source = "declared" if modules else ""

    # Neither `[package] name` nor the target name is the module name:
    # godot-cpp-m is named `godot-cpp-m` in both places and imported as
    # `godot_cpp`. The manifests that know say so in their own description, so
    # quote that instead of deriving a name that would be wrong.
    if not modules:
        m = _IMPORT_IN_TEXT.search(description)
        if m:
            modules = [m.group(1)]
            source = "description"

    sources = build.get("sources") or []
    sources = [str(s) for s in sources] if isinstance(sources, list) else []

    # `[lib] path = "src/x.cppm"` is the other way a manifest names its
    # library — tensorvia-cpu uses it instead of `[targets.x]`, and reading
    # only one shape left that package with no upstream data at all.
    lib = data.get("lib") or {}
    lib_path = str(lib.get("path") or "")
    if lib_path:
        sources.insert(0, lib_path)
        targets = dict(targets)
        targets.setdefault(str(pkg.get("name") or "lib"), {"kind": "lib"})

    # The cache stores facts from the manifest, not conclusions drawn from
    # them: `_is_modular` runs at build time, so its rules can change without
    # a network round trip to re-derive them for every package.
    return {
        "modules": modules,
        "modules_source": source,
        "sources": sources[:20],
        "name": str(pkg.get("name") or ""),
        "namespace": str(pkg.get("namespace") or ""),
        "targets": {k: {"kind": str((v or {}).get("kind", ""))}
                    for k, v in targets.items() if isinstance(v, dict)},
        "language": str(pkg.get("language") or pkg.get("standard") or ""),
        "version": str(pkg.get("version") or ""),
        "description": description,
        "license": str(pkg.get("license") or ""),
        "platforms": [str(p) for p in (pkg.get("platforms") or [])
                      if isinstance(pkg.get("platforms"), list)],
        "deps": [str(k) for k in (data.get("dependencies") or {}).keys()],
    }


def _collect_dependencies(data: Any) -> Dict[str, Any]:
    """Every `dependencies` table in a manifest, at any nesting depth.

    Merged rather than replaced: a package may appear only under one
    platform's gate, and for "which test demonstrates this package" the gate
    does not matter.
    """
    out: Dict[str, Any] = {}

    def walk(node: Any) -> None:
        if not isinstance(node, dict):
            return
        for key, value in node.items():
            if key in ("dependencies", "dev-dependencies") and isinstance(value, dict):
                for dep_key, dep_val in value.items():
                    if isinstance(dep_val, dict) and isinstance(out.get(dep_key), dict):
                        out[dep_key].update(dep_val)
                    else:
                        out[dep_key] = dep_val
            elif isinstance(value, dict):
                walk(value)

    walk(data)
    return out


def _is_modular(manifest: Dict[str, Any]) -> bool:
    """Is this upstream package consumed with `import`?

    Form A means the upstream itself is an mcpp project, and mcpp is
    modules-first: a `lib`/`shared` target there is a module library even when
    the manifest never spells the module name out. The C-source packages that
    are only ever `#include`d live in this index as Form B `compat.*` entries
    instead, so they do not reach this function.
    """
    if manifest.get("modules"):
        return True
    if any(".cppm" in s for s in manifest.get("sources") or []):
        return True
    if "import " in (manifest.get("description") or ""):
        return True
    kinds = {(t or {}).get("kind", "") for t in (manifest.get("targets") or {}).values()}
    return bool(kinds & {"lib", "shared"})


def _manifest_fallback(text: str) -> Dict[str, Any]:
    """Enough of a TOML reader for `[package]` and `[targets.x]` on 3.9/3.10."""
    out: Dict[str, Any] = {"package": {}, "targets": {}, "dependencies": {}}
    section = ""
    for line in text.splitlines():
        line = line.split("#", 1)[0].strip()
        if line.startswith("[") and line.endswith("]"):
            section = line[1:-1]
            if section.startswith("targets."):
                out["targets"][section.split(".", 1)[1]] = {}
            continue
        if "=" not in line:
            continue
        key, _, value = line.partition("=")
        key, value = key.strip().strip('"'), value.strip().strip('"')
        if section == "package":
            out["package"][key] = value
        elif section.startswith("targets."):
            out["targets"][section.split(".", 1)[1]][key] = value
        elif section == "dependencies":
            out["dependencies"][key] = value
    return out


def _read_json(path: str) -> Dict[str, Any]:
    if not os.path.isfile(path):
        return {}
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:                   # noqa: BLE001 - a broken override file
        return {}                       # must not take the whole site down
    return data if isinstance(data, dict) else {}


def _line_kind(code: str):
    """-> (label, tone) inferred from the shape of the line itself."""
    if code.startswith("import "):
        return "import", "module"
    if code.startswith("#include"):
        return "#include", "header"
    return "tool", "tool"


def _read_toml(path: str) -> Dict[str, Any]:
    if not os.path.isfile(path):
        return {}
    if tomllib is not None:
        try:
            with open(path, "rb") as f:
                return tomllib.load(f)
        except Exception:               # noqa: BLE001
            return {}
    return _read_toml_fallback(path)


def _read_toml_fallback(path: str) -> Dict[str, Any]:
    """Minimal `[dependencies.<ns>]` reader for interpreters without tomllib."""
    out: Dict[str, Any] = {"dependencies": {}}
    section = None
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if line.startswith("[") and line.endswith("]"):
                section = line[1:-1]
                continue
            if not section or "=" not in line or section.split(".")[0] != "dependencies":
                continue
            key = line.split("=", 1)[0].strip().strip('"')
            parts = section.split(".", 1)
            if len(parts) == 2:
                out["dependencies"].setdefault(parts[1], {})[key] = ""
            else:
                out["dependencies"][key] = ""
    return out


class McppPlugin(Plugin):
    api_version = 1
    name = "mcpp"

    def __init__(self) -> None:
        self.root = ""
        self.examples: Dict[str, List[Dict[str, str]]] = {}
        self.overrides: Dict[str, Any] = {}

    # ------------------------------------------------------------ index --
    def on_index(self, ctx) -> None:
        self.root = ctx.root

        # A descriptor without `namespace` resolves under mcpp's default one —
        # that is what "tried: (mcpplibs, json)" in issue #170 refers to.
        ctx.meta.set("default_namespace", "mcpplibs")

        index_toml = _read_toml(ctx.path("index.toml")).get("index", {})
        for key in ("spec", "min_mcpp", "latest_mcpp"):
            if index_toml.get(key):
                ctx.meta.set(key, index_toml[key])

        # Hand-curated interface lines, for the packages where no rule can
        # reach the answer: abseil's header is `absl/…`, bzip2's is `bzlib.h`,
        # xz's is `lzma.h` — none of them derivable from the package name.
        # Checked in beside the descriptors, so it is reviewed like data.
        curated = _read_json(ctx.path(".xpkgindex", "interfaces.json"))
        # Allow the file to carry a `_note` alongside the data.
        self.overrides = curated.get("interfaces", curated)

        self._scan_examples(ctx)
        if self.examples:
            ctx.meta.set("hero_stats", [
                {"label": _t("with examples", "带示例", "附範例"), "value": len(self.examples)},
            ])

    def _scan_examples(self, ctx) -> None:
        """Map packages to the test projects that consume them.

        This repo is also an mcpp workspace whose members are per-library test
        projects, so every association points at code that CI actually builds
        and runs — the detail page can show real usage instead of a snippet
        written for the website.
        """
        for toml_path in sorted(glob.glob(os.path.join(self.root, "tests", "examples",
                                                       "*", "mcpp.toml"))):
            data = _read_toml(toml_path)
            # Dependencies are often platform-gated —
            # `[target.'cfg(linux)'.dependencies.ocornut]` — so a top-level
            # lookup missed most of the module packages entirely, and with
            # them the real `import` lines their tests demonstrate.
            deps = _collect_dependencies(data)
            project = os.path.basename(os.path.dirname(toml_path))
            sources = sorted(glob.glob(os.path.join(os.path.dirname(toml_path),
                                                    "tests", "*.cpp")))
            if not sources:
                continue
            for key, value in deps.items():
                names = list(value.keys()) if isinstance(value, dict) else [key]
                prefix = f"{key}." if isinstance(value, dict) else ""
                for n in names:
                    # A bare dependency name resolves in the index's default
                    # namespace, so `tinyhttps = "…"` in a test project is the
                    # package this index publishes as `mcpplibs.tinyhttps`.
                    ids = [f"{prefix}{n}"] if prefix else [n, f"{DEFAULT_NAMESPACE}.{n}"]
                    entry = {
                        "project": project,
                        "path": os.path.relpath(sources[0], self.root).replace(os.sep, "/"),
                        # A project can hold several test files (archive has
                        # one per codec); all of them are candidates when
                        # looking for the line that belongs to this package.
                        "paths": [os.path.relpath(s, self.root).replace(os.sep, "/")
                                  for s in sources],
                        "count": str(len(sources)),
                    }
                    for pkg_id in ids:
                        self.examples.setdefault(pkg_id, []).append(entry)

    # --------------------------------------------------------- identity --
    def identity(self, raw: Dict[str, Any], path: str) -> Optional[Identity]:
        """mcpp resolves `namespace.name`, so the namespace IS the identity.

        Dropping it produced `mcpp add json@3.12.0` (issue #170) and collapsed
        three different `imgui` packages onto one page.
        """
        name = str(raw.get("name") or "")
        if not name:
            name = os.path.basename(path)[: -len(".lua")]
        return Identity.joined(str(raw.get("namespace") or ""), name, sep=".")

    # ---------------------------------------------------------- package --
    def on_package(self, pkg, raw: Dict[str, Any]) -> None:
        mcpp = raw.get("mcpp")
        ext: Dict[str, Any] = {}

        if isinstance(mcpp, str):
            # Form A: the upstream archive carries its own mcpp.toml at this glob.
            ext = {"form": "A", "manifest": mcpp}
        elif isinstance(mcpp, dict):
            ext = {
                "form": "B",
                "modules": mcpp.get("modules") or [],
                "targets": mcpp.get("targets") or {},
                "language": mcpp.get("language", ""),
                "import_std": mcpp.get("import_std"),
                "c_standard": mcpp.get("c_standard", ""),
                "include_dirs": mcpp.get("include_dirs") or [],
                "sources": mcpp.get("sources") or [],
                "generated_files": list((mcpp.get("generated_files") or {}).keys()),
                "features": mcpp.get("features") or {},
                "cflags": mcpp.get("cflags") or [],
                "deps": mcpp.get("deps") or {},
            }
            # Dependencies live in `mcpp.deps` for 21 packages here; the core
            # reader only sees `xpm.<platform>.deps`, so merge them in.
            for dep_ns, dep_val in (ext["deps"] or {}).items():
                names = list(dep_val.keys()) if isinstance(dep_val, dict) else [dep_ns]
                prefix = f"{dep_ns}." if isinstance(dep_val, dict) else ""
                for n in names:
                    ref = f"{prefix}{n}" if prefix else n
                    if ref not in pkg.deps:
                        pkg.deps.append(ref)
        else:
            ext = {"form": "A", "manifest": ""}

        # A package can be demonstrated by several test projects (grpc has one
        # for the module surface and one for codegen); keep them all, because
        # only one of them contains the line that shows how to consume it.
        examples = self.examples.get(pkg.identity.slug) or []
        if examples:
            ext["examples"] = examples
            ext["example"] = examples[0]
            pkg.extensions.setdefault("_badges", []).append(_t("✓ example", "✓ 有示例", "✓ 有範例"))

        mirrors = {m for v in pkg.versions for m in v.mirrors}
        if "CN" in mirrors:
            pkg.extensions.setdefault("_badges", []).append(_t("CN mirror", "国内镜像", "中國鏡像"))

        pkg.extensions["mcpp"] = ext
        # After the examples are attached: the surfaces depend on which
        # interface lines the examples can actually produce.
        self._recompute(pkg, ext)

    def _surfaces(self, ext: Dict[str, Any], lines: List[Dict[str, str]]) -> List[str]:
        """A package can be consumed in more than one way — but only ways it
        actually offers.

        `include_dirs` is not by itself a public header surface: on
        `boost-ext.ut` it exists "so the wrapper's `#include` resolves", an
        internal build detail, while `nlohmann.json` documents that
        `#include` stays available to users. The two are indistinguishable in
        the field, so for a module package the header surface has to be
        *demonstrated* — a real include line from its own test project or the
        curated table. A package with no module keeps the header surface from
        `include_dirs`, which is the only thing it can be.
        """
        out: List[str] = []
        modular = bool(ext.get("modules") or ext.get("modular"))
        if modular:
            out.append("module")

        shows_include = any(l["label"] == "#include" for l in lines)
        header_declared = bool(ext.get("include_dirs")
                               or (ext.get("form") == "B" and ext.get("sources")))
        if shows_include or (not modular and header_declared):
            out.append("header")

        kinds = {(t or {}).get("kind", "") for t in (ext.get("targets") or {}).values()
                 if isinstance(t, dict)}
        if "bin" in kinds or "binary" in kinds:
            out.append("tool")
        return out or ["external"]

    def _recompute(self, pkg, ext: Dict[str, Any]) -> None:
        """Interface lines and surfaces are derived together — the surfaces
        depend on which lines could actually be produced."""
        lines = self._interface_lines(pkg, ext)
        ext["interface_lines"] = lines
        surfaces = self._surfaces(ext, lines)
        ext["surface"] = surfaces[0]
        ext["surfaces"] = surfaces
        pkg.facets["surface"] = " ".join(surfaces)

    # ------------------------------------------------------------ remote --
    def enrich_remote(self, packages, http) -> None:
        """Fill in Form A packages from the upstream repo's own `mcpp.toml`.

        A Form A descriptor deliberately carries no build information — the
        upstream archive ships its manifest — so without this the site could
        only say "see upstream" for 18 packages, and every one of them showed
        up as `upstream mcpp.toml` rather than as the importable module it is.

        Only the manifest file is fetched (a few hundred bytes), never the
        tarball, and the URL contains the release tag, so a cached entry is
        reused until the package's version changes. `--refresh` re-fetches on
        demand.
        """
        for pkg in packages:
            ext = pkg.extensions.get("mcpp") or {}
            if ext.get("form") != "A":
                continue
            manifest, url = None, ""
            for candidate in self._manifest_urls(pkg, ext):
                manifest = http.get_text(candidate, _project_manifest)
                if manifest:
                    url = candidate
                    break
            if not manifest:
                continue

            ext["upstream"] = manifest
            ext["manifest_url"] = url

            # A lib target's module interface unit is the authority: mcpp
            # defaults the unit to `src/<target>.cppm`, and the `export module`
            # inside it overrides the target name — libxpkg's `[targets.xpkg]`
            # exports `mcpplibs.xpkg`, not `xpkg`. Reading the declaration
            # beats every heuristic, and it is one small file per package.
            if not manifest.get("modules"):
                found, source_path = self._module_from_interface_unit(
                    http, manifest, url)
                if found:
                    manifest["modules"] = [found]
                    manifest["modules_source"] = "export"
                    manifest["modules_path"] = source_path

            if manifest.get("modules"):
                ext["modules"] = manifest["modules"]
            if manifest.get("targets"):
                ext["targets"] = manifest["targets"]
            if manifest.get("language"):
                ext["language"] = manifest["language"]
            # Modular without a known name: the package IS importable, so it
            # belongs in the `import` facet; the row shows the shape and the
            # detail page says the manifest never names it.
            ext["modular"] = _is_modular(manifest)
            for dep in manifest.get("deps") or []:
                if dep not in pkg.deps:
                    pkg.deps.append(dep)

            self._recompute(pkg, ext)

    def _module_from_interface_unit(self, http, manifest: Dict[str, Any],
                                    manifest_url: str):
        """Fetch the lib target's `.cppm` and read its `export module`.

        Candidates, in order of authority: a concrete `.cppm` the manifest
        names, then mcpp's documented default `src/<target>.cppm`, then the
        package name. A 404 is cached like any other answer, so a miss costs
        one request per package and never repeats.
        """
        base = manifest_url.rsplit("/", 1)[0]
        candidates: List[str] = []
        for s in manifest.get("sources") or []:
            if s.endswith(".cppm") and "*" not in s:
                candidates.append(s)
        for target in manifest.get("targets") or {}:
            candidates.append(f"src/{target}.cppm")
        if manifest.get("name"):
            candidates.append(f"src/{manifest['name']}.cppm")

        seen = set()
        for path in candidates:
            if path in seen:
                continue
            seen.add(path)
            module = http.get_text(f"{base}/{path}", _project_export_module)
            if module:
                return module, path
        return "", ""

    def _manifest_urls(self, pkg, ext: Dict[str, Any]) -> List[str]:
        """Candidate raw URLs of the upstream manifest, most reliable first.

        The tag is read out of the descriptor's own download URL rather than
        guessed from the version, because the two differ (`v1.2.3` vs
        `1.2.3`). Both publishing shapes are handled — tag archives and
        release assets — and the bare/`v`-prefixed version are kept as a last
        resort, where a miss is a cached 404 rather than wrong data.
        """
        host, owner, name = _parse_repo(pkg.repo)
        if host != "github.com" or not (owner and name):
            return []

        tags: List[str] = []
        for version in pkg.versions:
            for url in version.urls.values():
                if f"/{owner}/{name}/" not in url:
                    continue
                for pattern in (_TAG_RE, _RELEASE_TAG_RE):
                    m = pattern.search(url)
                    if m and m.group(1) not in tags:
                        tags.append(m.group(1))
        if pkg.latest:
            for guess in (f"v{pkg.latest}", pkg.latest):
                if guess not in tags:
                    tags.append(guess)

        path = (ext.get("manifest") or "mcpp.toml").lstrip("*/")
        return [f"https://raw.githubusercontent.com/{owner}/{name}/{tag}/{path}"
                for tag in tags]

    # ------------------------------------------------------------ facets --
    def facets(self) -> List[Facet]:
        return [Facet(key="surface", label=_t("how you use it", "怎么用", "怎麼用"), weight=10, values=[
            FacetValue(key=key, label=label, tone=tone) for key, label, tone in SURFACES
        ])]

    # -------------------------------------------------------------- row --
    # Line 2 of every row answers one question — how do I consume this — and
    # line 3 answers another — how do I add it. Packages whose descriptor
    # never names a module or header still get line 2, as a muted placeholder
    # showing the shape, so the three lines keep the same meaning in every
    # row instead of shifting depending on what data happens to exist.
    ROW_BY_SURFACE = {
        "module":   ("import", "module", "import …;"),
        "header":   ("#include", "header", "#include <…>"),
        "tool":     ("tool", "tool", "$ …"),
        "external": ("import", "module", "import …;"),
    }

    def row(self, pkg) -> RowSpec:
        ext = pkg.extensions.get("mcpp", {})
        surfaces = ext.get("surfaces") or [ext.get("surface", "")]
        iface = pkg.interface
        code = iface.data.get("code", "") if iface else ""

        # The pill follows the line actually shown. Taking it from the first
        # surface instead put `tool` beside an `#include` on packages that
        # ship both a library and a binary.
        if iface:
            lead, tone = iface.data.get("label", ""), iface.data.get("tone", "neutral")
            primary = {"import": "module", "#include": "header"}.get(lead, "tool")
            placeholder = ""
        else:
            primary = surfaces[0]
            lead, tone, placeholder = self.ROW_BY_SURFACE.get(primary, ("", "neutral", ""))

        # A package consumable more than one way says so in the row, so the
        # listing does not imply the shown line is the only option.
        badges = list(pkg.extensions.get("_badges", []))
        for other in reversed(surfaces):
            if other == primary:
                continue
            label = self.ROW_BY_SURFACE.get(other, ("", "", ""))[0]
            if label and label not in badges:
                badges.insert(0, label)

        return RowSpec(
            tone=tone,
            lead=lead,
            code=code or placeholder,
            code_muted=not code,
            note=_t("This descriptor does not name the module or header — "
                    "open the package for its build details.",
                    "这个描述符没有写明模块名或头文件 —— 打开包页面看它的构建信息。",
                    "這個描述符沒有寫明模組名或標頭檔 —— 開啟套件頁面看它的建置資訊。"),
            badges=badges,
        )

    # ------------------------------------------------------------ blocks --
    def detail_blocks(self, pkg) -> List[Block]:
        ext = pkg.extensions.get("mcpp", {})
        blocks: List[Block] = []

        iface = self._interface(pkg, ext)
        if iface:
            blocks.append(iface)

        example = ext.get("example")
        if example:
            code = self._example_code(example["path"])
            if code:
                blocks.append(Block(
                    kind="code", title=_t("Usage", "用法", "用法"), weight=20,
                    data={
                        "code": code,
                        "caption": _t(
                            "From this repository's own test project — "
                            "built and run by CI, not written for the website.",
                            "来自本仓库自己的测试项目 —— CI 真的编译并运行过,不是为了网站写的。",
                            "來自本倉庫自己的測試專案 —— CI 真的編譯並執行過,不是為了網站寫的。"),
                        "source": _t(
                            f"{example['path']} · project tests/examples/{example['project']}",
                            f"{example['path']} · 项目 tests/examples/{example['project']}",
                            f"{example['path']} · 專案 tests/examples/{example['project']}"),
                    }))

        if ext.get("form") == "B":
            items = []
            if ext.get("modules"):
                items.append({"key": "modules", "value": ", ".join(ext["modules"]), "mono": True})
            targets = ", ".join(
                f"{n} ({(t or {}).get('kind', '?')})" for n, t in (ext.get("targets") or {}).items()
                if isinstance(t, dict))
            if targets:
                items.append({"key": "targets", "value": targets, "mono": True})
            if ext.get("language"):
                items.append({"key": "language", "value": ext["language"], "mono": True})
            if ext.get("c_standard"):
                items.append({"key": "C standard", "value": ext["c_standard"], "mono": True})
            if ext.get("import_std") is not None:
                items.append({"key": "import std", "value": "yes" if ext["import_std"] else "no"})
            if ext.get("include_dirs"):
                items.append({"key": "include dirs",
                              "value": ", ".join(ext["include_dirs"]), "mono": True})
            if items:
                blocks.append(Block(kind="kv", title=_t("Build", "构建", "建置"),
                                    data={"items": items}, weight=30))

            feats = ext.get("features") or {}
            if feats:
                rows = []
                for fname, fdata in feats.items():
                    detail = ""
                    if isinstance(fdata, dict):
                        detail = ", ".join(f"{k}" for k in fdata.keys())
                    rows.append([fname, detail])
                blocks.append(Block(kind="table", title=_t("Features", "特性", "功能"), weight=40,
                                    data={"head": [_t("feature", "特性", "功能"),
                                                   _t("declares", "声明了", "宣告了")],
                                          "rows": rows}))

            if ext.get("sources"):
                blocks.append(Block(kind="list", title=_t(f"Sources ({len(ext['sources'])})",
                                             f"源文件 ({len(ext['sources'])})",
                                             f"原始檔 ({len(ext['sources'])})"),
                                    collapsed=True, weight=50,
                                    data={"items": ext["sources"]}))
            if ext.get("generated_files"):
                blocks.append(Block(kind="list", title=_t("Generated files", "生成的文件", "產生的檔案"), collapsed=True,
                                    weight=60, data={"items": ext["generated_files"]}))
        else:
            upstream = ext.get("upstream") or {}
            if upstream:
                items = []
                if upstream.get("modules"):
                    items.append({"key": "modules", "value": ", ".join(upstream["modules"]),
                                  "mono": True})
                targets = ", ".join(f"{n} ({t.get('kind', '?')})"
                                    for n, t in (upstream.get("targets") or {}).items())
                if targets:
                    items.append({"key": "targets", "value": targets, "mono": True})
                if upstream.get("language"):
                    items.append({"key": "language", "value": upstream["language"], "mono": True})
                if upstream.get("version"):
                    items.append({"key": "manifest version", "value": upstream["version"],
                                  "mono": True})
                if upstream.get("deps"):
                    items.append({"key": "dependencies",
                                  "value": ", ".join(upstream["deps"]), "mono": True})
                items.append({"key": _t("source", "来源", "來源"),
                              "value": ext.get("manifest_url", ""), "mono": True})
                blocks.append(Block(kind="kv",
                                    title=_t("Build · upstream manifest",
                                             "构建 · 上游清单", "建置 · 上游資訊清單"),
                                    data={"items": items}, weight=30))
            else:
                at = f" at {ext['manifest']}" if ext.get("manifest") else ""
                at_zh = f"(在 {ext['manifest']})" if ext.get("manifest") else ""
                blocks.append(Block(
                    kind="callout", title=_t("Build", "构建", "建置"), weight=30,
                    data={"text": _t(
                        "Form A package: the upstream archive ships its own mcpp.toml"
                        + at + ". Its contents have not been fetched into this build — "
                        "run the index's refresh action to pull them in.",
                        "A 型包:上游压缩包自带 mcpp.toml" + at_zh
                        + "。本次构建没有抓取它的内容 —— 跑一次索引的刷新动作就能拉进来。",
                        "A 型套件:上游壓縮檔自帶 mcpp.toml" + at_zh
                        + "。本次建置沒有抓取它的內容 —— 執行一次索引的重新整理動作就能拉進來。")}))
        return blocks

    def _interface_lines(self, pkg, ext: Dict[str, Any]) -> List[Dict[str, str]]:
        """Every way this package can be consumed, most idiomatic first.

        A module package that also exposes its headers offers both, and the
        detail page should say so instead of picking one and hiding the other.
        """
        # A curated entry wins over every derivation: it exists precisely
        # because the derivations cannot reach the answer.
        manual = self.overrides.get(pkg.identity.slug)
        if manual:
            codes = manual if isinstance(manual, list) else [manual]
            out = []
            for code in codes:
                label, tone = _line_kind(str(code))
                out.append({"code": str(code), "label": label, "tone": tone,
                            "note": _t("Curated in .xpkgindex/interfaces.json.",
                                       "人工维护在 .xpkgindex/interfaces.json。",
                                       "人工維護在 .xpkgindex/interfaces.json。")})
            return out

        lines: List[Dict[str, str]] = []
        modules = ext.get("modules") or []
        note = ""
        source = (ext.get("upstream") or {}).get("modules_source")
        if modules and source == "description":
            note = _t("Module name taken from the upstream manifest's own description.",
                      "模块名取自上游清单自己的 description。",
                      "模組名取自上游資訊清單自己的 description。")
        elif modules and source == "export":
            path = (ext.get("upstream") or {}).get("modules_path", "")
            note = _t(f"Module name read from the upstream `export module` declaration in {path}.",
                      f"模块名读自上游 {path} 里的 `export module` 声明。",
                      f"模組名讀自上游 {path} 裡的 `export module` 宣告。")

        # A Form A manifest often never names its module, but a test project
        # that consumes the package writes the import for real — and CI
        # compiles it. That is a better source than any derivation.
        if not modules:
            hit = self._scan_examples_for(ext, pkg.identity.name, self._import_line)
            if hit:
                modules = [hit]
                note = _t("Module name taken from this index's own test project "
                          "for the package.",
                          "模块名取自本索引给这个包写的测试项目。",
                          "模組名取自本索引給這個套件寫的測試專案。")

        if modules:
            lines.append({"code": f"import {modules[0]};", "label": "import",
                          "tone": "module", "note": note})

        include = self._scan_examples_for(ext, pkg.identity.name, self._include_line,
                                          repoint=not modules)
        if include:
            lines.append({"code": include, "label": "#include", "tone": "header", "note": ""})

        if not lines:
            programs = [n for n, t in (ext.get("targets") or {}).items()
                        if isinstance(t, dict) and t.get("kind") in ("bin", "binary")]
            if programs:
                lines.append({"code": f"$ {programs[0]}", "label": "tool",
                              "tone": "tool", "note": ""})
        return lines

    def _scan_examples_for(self, ext: Dict[str, Any], pkg_name: str, extract,
                           repoint: bool = True) -> str:
        """Run `extract` over every test file of every associated project.

        When one matches, the Usage block is repointed at that exact file, so
        the snippet shown is the one that demonstrates this package rather
        than whichever project sorted first.
        """
        for example in ext.get("examples") or ([ext["example"]] if ext.get("example") else []):
            for candidate in example.get("paths") or [example.get("path", "")]:
                if not candidate:
                    continue
                found = extract(candidate, pkg_name)
                if found:
                    if repoint:
                        ext["example"] = dict(example, path=candidate)
                    return found
        return ""

    def _include_line(self, rel: str, pkg_name: str) -> str:
        line = self._first_interface_line(rel, pkg_name, allow_fallback=False)
        return line if line.startswith("#include") else ""

    def _import_line(self, rel: str, pkg_name: str) -> str:
        """The module this package's own test imports, if it names one."""
        line = self._first_interface_line(rel, pkg_name, allow_fallback=False)
        if line.startswith("import "):
            return line[len("import "):].rstrip(";")
        return ""

    def _interface(self, pkg, ext: Dict[str, Any]) -> Optional[Block]:
        """How this package is consumed — the primary line plus any others.

        Only ever taken from real data: a declared (or upstream-manifest)
        module name, or an include from the package's own test project. Never
        invented — a wrong `#include` on a package page is worse than none.
        """
        lines = ext.get("interface_lines")
        if lines is None:
            lines = self._interface_lines(pkg, ext)
        if not lines:
            # No usable line, but the example may still point at the file that
            # demonstrates this package; keep the association for the Usage block.
            example = ext.get("example")
            if example:
                for candidate in example.get("paths") or [example["path"]]:
                    if self._first_interface_line(candidate, pkg.identity.name,
                                                  allow_fallback=False):
                        example["path"] = candidate
                        break
            return None

        primary, rest = lines[0], lines[1:]
        return Block(kind="code", weight=10, data={
            "role": "interface",
            "code": primary["code"], "tone": primary["tone"],
            "label": primary["label"], "note": primary["note"],
            "alt": rest,
        })

    # ----------------------------------------------------------- helpers --
    def _example_code(self, rel: str, max_lines: int = 22) -> str:
        path = os.path.join(self.root, rel)
        if not os.path.isfile(path):
            return ""
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            lines = f.read().splitlines()
        if len(lines) > max_lines:
            lines = lines[:max_lines] + ["// …"]
        return "\n".join(lines).strip()

    def _first_interface_line(self, rel: str, pkg_name: str = "",
                              allow_fallback: bool = True) -> str:
        """Pick the line that belongs to *this* package.

        One example project often covers several packages — tests/examples/
        archive exercises zlib, bzip2, lz4, xz and zstd together — so taking
        the first include would put `#include <bzlib.h>` on the zlib page.
        Prefer a line whose identifier matches the package name, and only
        fall back to the first one when nothing matches.
        """
        path = os.path.join(self.root, rel)
        if not os.path.isfile(path):
            return ""
        with open(path, "r", encoding="utf-8", errors="replace") as f:
            text = f.read()

        def norm(s: str) -> str:
            return s.lower().replace("-", "").replace("_", "")

        key = norm(pkg_name or "")
        modules = [m for m in _IMPORT_RE.findall(text) if m != "std"]
        includes = _INCLUDE_RE.findall(text)

        def stem_of(inc: str) -> str:
            return os.path.splitext(os.path.basename(inc.strip('<>"')))[0]

        # Two passes, exact before fuzzy and across ALL candidates each time.
        # Doing it candidate-by-candidate would let a fuzzy hit win before the
        # exact one is even considered: `bzlib` ends with `zlib`, so zlib's
        # page got `#include <bzlib.h>`.
        def pick(test) -> str:
            if not key:
                return ""
            for mod in modules:
                if test(norm(mod.split(".")[-1])) or test(norm(mod)):
                    return f"import {mod};"
            for inc in includes:
                path = inc.strip('<>"')
                # Both the file stem and the leading directory: Eigen ships
                # `<Eigen/Dense>`, where the package name is the directory.
                parts = [stem_of(inc)] + path.split("/")[:-1]
                if any(test(norm(p)) for p in parts if p):
                    return f"#include {inc}"
            return ""

        found = pick(lambda c: c == key)
        if found:
            return found
        # Boundary match, for `libarchive` → `archive.h` and friends.
        found = pick(lambda c: c.startswith(key) or key.startswith(c)
                     or c.endswith(key) or key.endswith(c))
        if found:
            return found

        # No name match. Trust the example only when it is unambiguous — a
        # shared project (archive covers zlib, bzip2, lz4, xz, zstd) would
        # otherwise attribute one package's header to another. `xz` ships
        # `lzma.h`, so it legitimately ends up with no interface line rather
        # than a wrong one.
        if allow_fallback:
            if len(modules) == 1 and not includes:
                return f"import {modules[0]};"
            if len(includes) == 1 and not modules:
                return f"#include {includes[0]}"
        return ""
