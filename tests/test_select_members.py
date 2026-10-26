#!/usr/bin/env python3
"""tests/select_members.py: a member is selected by the identities its declared
graph holds, never by a substring of a manifest."""
import io
import tarfile
import tomllib
import unittest
import urllib.error

import select_members as s


def not_found(url):
    raise urllib.error.HTTPError(url, 404, "Not Found", {}, None)


def tarball(files: dict[str, str]) -> bytes:
    out = io.BytesIO()
    with tarfile.open(fileobj=out, mode="w:gz") as t:
        for name, text in files.items():
            data = text.encode()
            info = tarfile.TarInfo(name)
            info.size = len(data)
            t.addfile(info, io.BytesIO(data))
    return out.getvalue()


class Declared(unittest.TestCase):
    def selectors(self, text):
        manifest = tomllib.loads(text)
        return {sel for table in s.dependency_tables(manifest) for sel, _ in s.declared(table)}

    def test_nesting_is_read_as_mcpp_reads_it(self):
        text = '''
[package]
name = "m"          # not a dependency, though a string
[dependencies]
cmdline = "0.0.2"
"mcpplibs.mwrap.ffmpeg" = "8.1.2"
openkal.workspace = true
[dependencies.compat]
fmt = "12.2.0"
zlib = { version = "1.3.1", features = ["x"] }
[dependencies.mcpplibs.mwrap]
imgui = "1.92.8"
[target.'cfg(os = "linux")'.dependencies.freedesktop]
wayland = "1.26.0"
[target.'cfg(os = "openkal")'.build-dependencies]
openkal-tools = { version = "0.1.0", tools = ["okld"] }
'''
        self.assertEqual(self.selectors(text), {
            "cmdline", "mcpplibs.mwrap.ffmpeg", "openkal", "compat.fmt", "compat.zlib",
            "mcpplibs.mwrap.imgui", "freedesktop.wayland", "openkal-tools"})

    def test_a_spelling_names_identities_of_this_index_only(self):
        ids = {("mcpplibs", "os"), ("compat", "openssl"), ("mcpplibs.mwrap", "ffmpeg"), ("compat", "os")}
        self.assertEqual(s.resolve("os", ids), {("mcpplibs", "os")})
        self.assertEqual(s.resolve("compat.openssl", ids), {("compat", "openssl")})
        self.assertEqual(s.resolve("compat:openssl@3.5.1", ids), {("compat", "openssl")})
        self.assertEqual(s.resolve("mcpplibs.mwrap.ffmpeg", ids), {("mcpplibs.mwrap", "ffmpeg")})
        self.assertEqual(s.resolve("xim:gcc@16.1.0", ids), set())
        self.assertEqual(s.resolve("macos", ids), set())

    def test_a_table_opened_twice_adds_to_itself(self):
        text = '[build]\nflags = ["a"]\n[dependencies]\nos = "0.1.0"\n[build]\nsources = ["b"]\n'
        self.assertEqual(s.loads(text), {"build": {"flags": ["a"], "sources": ["b"]},
                                         "dependencies": {"os": "0.1.0"}})


class Archives(unittest.TestCase):
    TOOLS = 'openkal-ld = { path = "../ld" }\nos = "0.1.0"\n'
    LD = 'openkal = "0.17.0"\n'

    def test_the_tree_at_the_tag_and_the_manifests_it_reaches_by_path(self):
        tree = {
            "https://raw.githubusercontent.com/o/r/0.1.0/tools/mcpp.toml": "[dependencies]\n" + self.TOOLS,
            "https://raw.githubusercontent.com/o/r/0.1.0/ld/mcpp.toml": "[dependencies]\n" + self.LD,
        }
        get = lambda url: tree[url].encode() if url in tree else not_found(url)
        got = s.archive_selectors("https://github.com/o/r/archive/refs/tags/0.1.0.tar.gz#tools/mcpp.toml", get)
        self.assertEqual(got, {"openkal-ld", "os", "openkal"})

    def test_a_release_asset_is_read_from_the_archive(self):
        asset = "https://github.com/o/r/releases/download/v1/r-1.tar.gz"
        data = tarball({"r-1/mcpp/mcpp.toml": "[dependencies.compat]\nzlib = \"1.3.1\"\n"})
        get = lambda url: data if url == asset else not_found(url)
        self.assertEqual(s.archive_selectors(asset + "#mcpp/mcpp.toml", get), {"compat.zlib"})

    def test_an_optional_manifest_that_is_absent_is_no_edge(self):
        asset = "https://github.com/o/r/releases/download/v1/r-1.tar.gz"
        data = tarball({"r-1/README": "x"})
        get = lambda url: data if url == asset else not_found(url)
        with self.assertRaises(s.NoManifest):
            s.archive_selectors(asset + "#?mcpp.toml", get)
        with self.assertRaises(s.NoManifest):
            s.archive_selectors("https://example.org/COPYING#mcpp.toml", get)


class ThisIndex(unittest.TestCase):
    """The selection on this repository's descriptors and members, with every
    archive manifest unreadable: what the descriptors themselves state."""

    def select(self, *paths):
        return set(s.select(list(paths), get=not_found, warn=lambda m: None, cache={})[0])

    def test_a_short_name_inside_other_words_selects_nothing(self):
        # `openkal` occurs in no member that does not declare a package of the family.
        for member in self.select("pkgs/o/openkal.lua"):
            text = (s.ROOT / "tests" / "examples" / member / "mcpp.toml").read_text()
            self.assertRegex(text, r"(?m)^\s*openkal(-[a-z-]+)?\s*[=.]")

    def test_a_dependency_stated_by_descriptors_reaches_its_consumers(self):
        selected = self.select("pkgs/c/compat.boost-config.lua")
        self.assertIn("boost-config", selected)
        self.assertIn("boost-asio", selected)      # boost-asio -> boost-config, by descriptor
        self.assertNotIn("fmt", selected)


if __name__ == "__main__":
    unittest.main()
