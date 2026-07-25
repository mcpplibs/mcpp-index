from __future__ import annotations

import contextlib
import io
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

TOOL_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(TOOL_DIR))

import gen_exports


class TestGenerateExports(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = self.tmp.name
        os.makedirs(os.path.join(self.root, "include"))
        with open(
            os.path.join(self.root, "include", "llama.h"),
            "w",
            encoding="utf-8",
        ) as fixture:
            fixture.write(
                """\
#define LLAMA_API
struct llama_model;
enum llama_mode { LLAMA_MODE_A, LLAMA_MODE_B };
LLAMA_API void llama_live(struct llama_model *);
#define LLAMA_NUMBER 7
"""
            )
        os.makedirs(os.path.join(self.root, "ggml", "include"))
        with open(
            os.path.join(self.root, "ggml", "include", "ggml.h"),
            "w",
            encoding="utf-8",
        ) as fixture:
            fixture.write(
                """\
enum ggml_log_level { GGML_LOG_LEVEL_NONE, GGML_LOG_LEVEL_INFO };
typedef void (*ggml_log_callback)(enum ggml_log_level, const char *, void *);
"""
            )

    def tearDown(self):
        self.tmp.cleanup()

    def test_generate_exports_finds_llama_types(self):
        llama, _, _ = gen_exports.generate_exports(
            upstream_dir=self.root,
            include_dirs=[
                os.path.join(self.root, "include"),
                os.path.join(self.root, "ggml", "include"),
            ],
        )
        self.assertIn("export using ::llama_model;", llama)
        self.assertIn("export using ::llama_live;", llama)
        self.assertIn("export using ::LLAMA_MODE_A;", llama)

    def test_generate_exports_skips_macros(self):
        _, _, skipped = gen_exports.generate_exports(
            upstream_dir=self.root,
            include_dirs=[
                os.path.join(self.root, "include"),
                os.path.join(self.root, "ggml", "include"),
            ],
        )
        self.assertIn("LLAMA_NUMBER", skipped)

    def test_generate_exports_includes_required_ggml_types(self):
        _, ggml, _ = gen_exports.generate_exports(
            upstream_dir=self.root,
            include_dirs=[
                os.path.join(self.root, "include"),
                os.path.join(self.root, "ggml", "include"),
            ],
        )
        self.assertIn("export using ::ggml_log_level;", ggml)
        self.assertIn("export using ::GGML_LOG_LEVEL_INFO;", ggml)
        self.assertIn("export using ::ggml_log_callback;", ggml)


class TestCheckMode(unittest.TestCase):
    GENERATED = {
        "llama.inc": "export using ::llama_model;\n",
        "required_ggml.inc": "export using ::ggml_context;\n",
        "llama.skipped.txt": "macro LLAMA_API\n",
    }

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.output_dir = Path(self.tmp.name) / "generated"
        self.output_dir.mkdir()

    def tearDown(self):
        self.tmp.cleanup()

    def test_default_output_is_the_checked_in_module_snapshot(self):
        self.assertEqual(
            gen_exports.DEFAULT_OUTPUT_DIR,
            TOOL_DIR / "module/gen_exports",
        )

    def write_outputs(self, names=None):
        selected = names if names is not None else self.GENERATED.keys()
        for name in selected:
            (self.output_dir / name).write_text(
                self.GENERATED[name], encoding="utf-8"
            )

    def run_check(self):
        generated_tuple = (
            self.GENERATED["llama.inc"],
            self.GENERATED["required_ggml.inc"],
            self.GENERATED["llama.skipped.txt"],
        )
        stderr = io.StringIO()
        with mock.patch.object(
            gen_exports, "generate_exports", return_value=generated_tuple
        ), contextlib.redirect_stderr(stderr):
            result = gen_exports.main(
                [
                    "--upstream",
                    self.tmp.name,
                    "--output-dir",
                    str(self.output_dir),
                    "--check",
                ]
            )
        return result, stderr.getvalue()

    def snapshot(self):
        return {
            path.name: path.read_bytes()
            for path in sorted(self.output_dir.iterdir())
            if path.is_file()
        }

    def test_check_accepts_matching_outputs_without_writing(self):
        self.write_outputs()
        before = self.snapshot()
        result, stderr = self.run_check()
        self.assertEqual(result, 0)
        self.assertIn("All exports match.", stderr)
        self.assertEqual(self.snapshot(), before)

    def test_check_rejects_stale_output_without_writing(self):
        self.write_outputs()
        stale = self.output_dir / "llama.inc"
        stale.write_text("stale\n", encoding="utf-8")
        before = self.snapshot()
        result, stderr = self.run_check()
        self.assertEqual(result, 1)
        self.assertIn("llama.inc differs", stderr)
        self.assertEqual(self.snapshot(), before)

    def test_check_rejects_missing_output_without_writing(self):
        self.write_outputs(["llama.inc", "required_ggml.inc"])
        before = self.snapshot()
        result, stderr = self.run_check()
        self.assertEqual(result, 1)
        self.assertIn("llama.skipped.txt does not exist", stderr)
        self.assertEqual(self.snapshot(), before)


if __name__ == "__main__":
    unittest.main()
