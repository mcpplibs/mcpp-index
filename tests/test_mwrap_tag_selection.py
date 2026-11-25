"""Keep legacy and mwrap release streams separate in the real pinned updater."""
import unittest
from xpkgindex_update.manifest import tag_version


class WrapperTagSelection(unittest.TestCase):
    def test_mwrap_series_preserves_numeric_and_build_versions(self):
        for version in ('5.0.0', '8.1.2', 'b10069', 'b10069.1'):
            with self.subTest(version=version):
                self.assertEqual(tag_version('mwrap-${version}', 'mwrap-' + version), version)

    def test_legacy_releases_never_become_mwrap_candidates(self):
        for tag in ('v8.1.2', '8.1.2', 'b10069', 'v1.83.0-4'):
            self.assertIsNone(tag_version('mwrap-${version}', tag))

    def test_mwrap_tags_never_become_legacy_candidates(self):
        for template in ('v${version}', '${version}'):
            for tag in ('mwrap-8.1.2', 'mwrap-b10069'):
                self.assertIsNone(tag_version(template, tag))

    def test_rc_requires_manual_provider_compatibility_review(self):
        self.assertIsNone(tag_version('mwrap-${version}', 'mwrap-10.0.0-rc1'))


if __name__ == '__main__':
    unittest.main()
