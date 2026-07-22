"""Unit tests for audit_snapshot.py — verified against a miniature CMake tree."""
import contextlib
import io
import json
import os
import sys
import tarfile
import tempfile
import unittest
from pathlib import Path
from unittest import mock

# Ensure the tools/llamacpp directory is on the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '.'))
import audit_snapshot


class TestExtractCmakeCall(unittest.TestCase):
    """Balanced-paren CMake extraction."""

    def test_simple_add_library(self):
        text = 'add_library(ggml-base ggml.c ggml.cpp ggml-backend.cpp)'
        name, sources = audit_snapshot.extract_cmake_call(text, 'add_library', 'ggml-base')
        self.assertEqual(name, 'ggml-base')
        self.assertEqual(sources, ['ggml.c', 'ggml.cpp', 'ggml-backend.cpp'])

    def test_ggml_add_backend_library(self):
        text = '''ggml_add_backend_library(ggml-metal
    ggml-metal.cpp
    ggml-metal-device.m
    ggml-metal-device.cpp)'''
        name, sources = audit_snapshot.extract_cmake_call(text, 'ggml_add_backend_library', 'ggml-metal')
        self.assertEqual(name, 'ggml-metal')
        self.assertEqual(sources, ['ggml-metal.cpp', 'ggml-metal-device.m', 'ggml-metal-device.cpp'])

    def test_multiline_file_glob(self):
        text = '''file(GLOB LLAMA_MODELS_SOURCES "models/*.cpp")
add_library(llama llama.cpp ${LLAMA_MODELS_SOURCES})'''
        # Should handle the GLOB but not expand it here
        name, sources = audit_snapshot.extract_cmake_call(text, 'add_library', 'llama')
        self.assertEqual(name, 'llama')
        # GLOB variable reference is preserved as-is for later expansion
        self.assertIn('${LLAMA_MODELS_SOURCES}', ' '.join(sources))

    def test_balanced_nested_parens(self):
        text = 'target_compile_definitions(ggml PRIVATE GGML_BUILD=1 GGML_SHARED=0 $<$<CONFIG:Debug>:GGML_DEBUG>)'
        name, args = audit_snapshot.extract_cmake_call(text, 'target_compile_definitions', 'ggml')
        self.assertIn('GGML_BUILD=1', args)
        self.assertIn('$<$<CONFIG:Debug>:GGML_DEBUG>', ' '.join(args))


class TestSafeExtract(unittest.TestCase):
    """Archive extraction safety."""

    def test_rejects_escape_attempt(self):
        import tarfile, io
        with tempfile.TemporaryDirectory() as dest:
            # Create an in-memory tarball with a path-escape entry
            buf = io.BytesIO()
            with tarfile.open(fileobj=buf, mode='w') as tf:
                info = tarfile.TarInfo(name='../evil.txt')
                info.size = 5
                tf.addfile(info, io.BytesIO(b'EVIL\n'))
            buf.seek(0)
            with self.assertRaises(ValueError):
                audit_snapshot.safe_extract_tar(buf, dest)


class TestCollectSnapshotMiniTree(unittest.TestCase):
    """Full snapshot from a synthetic tree."""

    maxDiff = None

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = self.tmp.name
        os.makedirs(os.path.join(self.root, 'ggml', 'src'), exist_ok=True)
        os.makedirs(os.path.join(self.root, 'ggml', 'src', 'ggml-cpu', 'arch', 'x86'), exist_ok=True)
        os.makedirs(os.path.join(self.root, 'ggml', 'src', 'ggml-cpu', 'arch', 'arm'), exist_ok=True)
        os.makedirs(os.path.join(self.root, 'ggml', 'src', 'ggml-metal'), exist_ok=True)
        os.makedirs(os.path.join(self.root, 'src', 'models'), exist_ok=True)
        os.makedirs(os.path.join(self.root, 'include'), exist_ok=True)

        # Write CMake snippet
        with open(os.path.join(self.root, 'CMakeLists.txt'), 'w') as f:
            f.write('''add_library(ggml-base ggml.c ggml.cpp ggml-backend.cpp)
add_library(ggml ggml-backend-dl.cpp ggml-backend-reg.cpp)
ggml_add_backend_library(ggml-metal
    ggml-metal.cpp
    ggml-metal-device.m
    ggml-metal-device.cpp)
file(GLOB LLAMA_MODELS_SOURCES "src/models/*.cpp")
add_library(llama llama.cpp ${LLAMA_MODELS_SOURCES})
''')
        cpu_cmake = os.path.join(
            self.root, 'ggml', 'src', 'ggml-cpu', 'CMakeLists.txt')
        with open(cpu_cmake, 'w') as f:
            f.write('''function(ggml_add_cpu_backend_variant_impl tag_name)
    list(APPEND GGML_CPU_SOURCES
        ggml-cpu/ggml-cpu.c
        ggml-cpu/ggml-cpu.cpp
        ggml-cpu/ops.cpp)
    if (GGML_SYSTEM_ARCH STREQUAL "ARM")
        list(APPEND GGML_CPU_SOURCES ggml-cpu/arch/arm/quants.c)
    elseif (GGML_SYSTEM_ARCH STREQUAL "x86")
        list(APPEND GGML_CPU_SOURCES ggml-cpu/arch/x86/quants.c)
    endif()
endfunction()
''')
        # Create source files
        for src in ['ggml.c', 'ggml.cpp', 'ggml-backend.cpp',
                    'ggml-backend-dl.cpp', 'ggml-backend-reg.cpp',
                    'ggml-metal.cpp', 'ggml-metal-device.m', 'ggml-metal-device.cpp',
                    'llama.cpp']:
            open(os.path.join(self.root, src), 'w').close()
        for src in [
                'ggml/src/ggml-cpu/ggml-cpu.c',
                'ggml/src/ggml-cpu/ggml-cpu.cpp',
                'ggml/src/ggml-cpu/ops.cpp',
                'ggml/src/ggml-cpu/arch/x86/quants.c',
                'ggml/src/ggml-cpu/arch/arm/quants.c']:
            open(os.path.join(self.root, src), 'w').close()
        # Create model files (sorted names for deterministic order)
        for name in ['a.cpp', 'z.cpp']:
            open(os.path.join(self.root, 'src', 'models', name), 'w').close()
        # Create registry fixture
        reg_path = os.path.join(self.root, 'ggml-backend-reg.cpp')
        with open(reg_path, 'w') as f:
            f.write('''
#ifdef GGML_USE_CPU
    register_backend(ggml_backend_cpu_reg());
#endif
#ifdef GGML_USE_METAL
    register_backend(ggml_backend_metal_reg());
#endif
''')
        # Create metal shader input files
        for name in ['ggml-common.h', 'ggml-metal.metal', 'ggml-metal-impl.h']:
            sub = 'ggml-metal' if name != 'ggml-common.h' else ''
            p = os.path.join(self.root, 'ggml', 'src', sub, name)
            os.makedirs(os.path.dirname(p), exist_ok=True)
            with open(p, 'w') as f:
                f.write('/* placeholder */\n')
        # Create public headers
        for name in ['llama.h', 'ggml.h', 'ggml-cpu.h']:
            with open(os.path.join(self.root, 'include', name), 'w') as f:
                f.write(f'/* {name} placeholder */\n')

        # Create the metal shader with markers
        metal_path = os.path.join(self.root, 'ggml', 'src', 'ggml-metal', 'ggml-metal.metal')
        with open(metal_path, 'w') as f:
            f.write('''
#include "ggml-common.h"
// ... metal shader code ...
// replacement marker for build system
''')

    def tearDown(self):
        self.tmp.cleanup()

    def test_collect_snapshot_sources(self):
        report = audit_snapshot.collect_snapshot(
            self.root,
            tag='test',
            commit='deadbeef',
            url='https://example.com/test.tar.gz',
            archive_sha256='abc123')
        # sorted() gives ASCII order: '-' < '.', so ggml-backend*.cpp comes first
        self.assertEqual(report['sources']['ggml_base'],
                         ['ggml-backend.cpp', 'ggml.c', 'ggml.cpp'])
        self.assertEqual(report['sources']['ggml_registry'],
                         ['ggml-backend-dl.cpp', 'ggml-backend-reg.cpp'])
        # Models: glob expanded and sorted
        self.assertEqual(report['sources']['models'],
                         ['src/models/a.cpp', 'src/models/z.cpp'])
        # Metal: 3 source files
        # sorted order for ggml_metal sources
        self.assertEqual(report['sources']['ggml_metal'],
                         ['ggml-metal-device.cpp', 'ggml-metal-device.m', 'ggml-metal.cpp'])
        self.assertEqual(report['sources']['ggml_cpu_common'], [
            'ggml/src/ggml-cpu/ggml-cpu.c',
            'ggml/src/ggml-cpu/ggml-cpu.cpp',
            'ggml/src/ggml-cpu/ops.cpp',
        ])
        self.assertEqual(report['sources']['ggml_cpu_x86'], [
            'ggml/src/ggml-cpu/arch/x86/quants.c',
        ])
        self.assertEqual(report['sources']['ggml_cpu_arm'], [
            'ggml/src/ggml-cpu/arch/arm/quants.c',
        ])
        # Registry markers
        self.assertEqual(report['registry']['GGML_USE_CPU'], 'ggml_backend_cpu_reg')
        self.assertEqual(report['registry']['GGML_USE_METAL'], 'ggml_backend_metal_reg')
        # Shader inputs (sorted, deduplicated)
        self.assertIn('ggml/src/ggml-common.h', report['metal']['shader_inputs'])
        self.assertIn('ggml/src/ggml-metal/ggml-metal.metal', report['metal']['shader_inputs'])
        self.assertIn('ggml/src/ggml-metal/ggml-metal-impl.h', report['metal']['shader_inputs'])

    def test_rejects_unknown_cpu_source_variable(self):
        cpu_cmake = Path(self.root) / 'ggml/src/ggml-cpu/CMakeLists.txt'
        with cpu_cmake.open('a') as f:
            f.write('\nlist(APPEND GGML_CPU_SOURCES ${NEW_DEFAULT_CPU_SOURCES})\n')

        with self.assertRaisesRegex(
                ValueError, 'unexpected CPU source variable.*NEW_DEFAULT_CPU_SOURCES'):
            audit_snapshot.collect_snapshot(
                self.root,
                tag='test',
                commit='deadbeef',
                url='https://example.com/test.tar.gz',
                archive_sha256='abc123')

    def test_rejects_unresolved_cpu_translation_unit(self):
        cpu_cmake = Path(self.root) / 'ggml/src/ggml-cpu/CMakeLists.txt'
        with cpu_cmake.open('a') as f:
            f.write(
                '\nlist(APPEND GGML_CPU_SOURCES ggml-cpu/generated-default.cpp)\n')

        with self.assertRaisesRegex(
                ValueError, 'unresolved CPU source.*generated-default.cpp'):
            audit_snapshot.collect_snapshot(
                self.root,
                tag='test',
                commit='deadbeef',
                url='https://example.com/test.tar.gz',
                archive_sha256='abc123')

    def _write_archive_and_report(self):
        fixture_dir = tempfile.TemporaryDirectory()
        archive = Path(fixture_dir.name) / 'llama.cpp-test.tar.gz'
        with tarfile.open(archive, 'w:gz') as tf:
            tf.add(self.root, arcname='llama.cpp-test')
        digest = audit_snapshot.sha256_file(archive)
        url = archive.as_uri()
        report = audit_snapshot.collect_snapshot(
            self.root,
            tag='test',
            commit='deadbeef',
            url=url,
            archive_sha256=digest,
        )
        report_path = Path(fixture_dir.name) / 'snapshot.json'
        report_path.write_text(json.dumps(report, indent=2) + '\n')
        return fixture_dir, report_path

    def test_check_only_uses_identity_from_report(self):
        fixture_dir, report_path = self._write_archive_and_report()
        self.addCleanup(fixture_dir.cleanup)
        with mock.patch.object(
                sys, 'argv', ['audit_snapshot.py', '--check', str(report_path)]):
            self.assertEqual(audit_snapshot.main(), 0)

    def test_check_supports_local_upstream_override(self):
        fixture_dir, report_path = self._write_archive_and_report()
        self.addCleanup(fixture_dir.cleanup)
        with mock.patch.object(
                sys, 'argv', ['audit_snapshot.py', '--check', str(report_path),
                              '--upstream', self.root]):
            self.assertEqual(audit_snapshot.main(), 0)

    def test_check_supports_url_and_sha_override(self):
        fixture_dir, report_path = self._write_archive_and_report()
        self.addCleanup(fixture_dir.cleanup)
        report = json.loads(report_path.read_text())
        original = Path(report['upstream']['url'].removeprefix('file://'))
        controlled = original.with_name('controlled-source.tar.gz')
        controlled.write_bytes(original.read_bytes())
        with mock.patch.object(
                sys, 'argv', ['audit_snapshot.py', '--check', str(report_path),
                              '--url', controlled.as_uri(), '--sha256',
                              report['upstream']['sha256']]):
            self.assertEqual(audit_snapshot.main(), 0)

    def test_check_rejects_incomplete_report_identity(self):
        fixture_dir, report_path = self._write_archive_and_report()
        self.addCleanup(fixture_dir.cleanup)
        report = json.loads(report_path.read_text())
        del report['upstream']['sha256']
        report_path.write_text(json.dumps(report))
        stderr = io.StringIO()
        with mock.patch.object(
                sys, 'argv', ['audit_snapshot.py', '--check', str(report_path),
                              '--upstream', self.root]), \
                contextlib.redirect_stderr(stderr), \
                self.assertRaises(SystemExit):
            audit_snapshot.main()
        self.assertIn('missing upstream identity fields: sha256', stderr.getvalue())

    def test_check_rejects_conflicting_explicit_identity(self):
        fixture_dir, report_path = self._write_archive_and_report()
        self.addCleanup(fixture_dir.cleanup)
        stderr = io.StringIO()
        with mock.patch.object(
                sys, 'argv', ['audit_snapshot.py', '--check', str(report_path),
                              '--upstream', self.root, '--tag', 'other']), \
                contextlib.redirect_stderr(stderr), \
                self.assertRaises(SystemExit):
            audit_snapshot.main()
        self.assertIn('--tag conflicts with report identity', stderr.getvalue())

    def test_check_requires_complete_url_override(self):
        fixture_dir, report_path = self._write_archive_and_report()
        self.addCleanup(fixture_dir.cleanup)
        stderr = io.StringIO()
        with mock.patch.object(
                sys, 'argv', ['audit_snapshot.py', '--check', str(report_path),
                              '--url', 'file:///controlled.tar.gz']), \
                contextlib.redirect_stderr(stderr), \
                self.assertRaises(SystemExit):
            audit_snapshot.main()
        self.assertIn('--sha256 is required when using --url', stderr.getvalue())


if __name__ == '__main__':
    unittest.main()
