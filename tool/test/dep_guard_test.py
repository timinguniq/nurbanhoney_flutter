"""tool/dep_guard.py 의 금지 의존성 규칙을 실제 import 사례로 검증한다."""
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from harness_support import REPO_ROOT, write

GUARD = REPO_ROOT / "tool" / "dep_guard.py"

PACKAGES = {
    "pubspec.yaml": "name: app\n",
    "domain/a_domain/pubspec.yaml": "name: a_domain\n",
    "data/a_repository/pubspec.yaml": "name: a_repository\n",
    "application/a_service/pubspec.yaml": "name: a_service\n",
}


class DepGuardTest(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)
        for rel, content in PACKAGES.items():
            write(self.root / rel, content)

    def tearDown(self):
        self._tmp.cleanup()

    def run_guard(self):
        return subprocess.run([sys.executable, str(GUARD), "--root", str(self.root)],
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              universal_newlines=True)

    def assertViolation(self, rel, source, expected):
        write(self.root / rel, source)
        result = self.run_guard()
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn(rel + ":", result.stderr)
        self.assertIn(expected, result.stderr)

    def assertAllowed(self, rel, source):
        write(self.root / rel, source)
        result = self.run_guard()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_allowed_downward_dependencies(self):
        write(self.root / "data/a_repository/lib/repo.dart",
              "import 'package:a_domain/a_domain.dart';\nimport 'package:flutter/foundation.dart';\n")
        write(self.root / "application/a_service/lib/service.dart",
              "import 'package:a_repository/a_repository.dart';\n"
              "import 'package:flutter_riverpod/flutter_riverpod.dart';\n")
        write(self.root / "lib/main.dart",
              "import 'package:a_service/a_service.dart';\nimport 'package:a_domain/a_domain.dart';\n"
              "import 'package:a_repository/a_repository.dart';\n")
        result = self.run_guard()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("패키지 4개", result.stdout)

    def test_domain_must_not_import_flutter(self):
        self.assertViolation("domain/a_domain/lib/model.dart",
                             "import 'package:flutter/material.dart';\n", "Flutter 패키지(flutter)")

    def test_domain_must_not_import_flutter_family_packages(self):
        self.assertViolation("domain/a_domain/lib/model.dart",
                             "import 'package:flutter_riverpod/flutter_riverpod.dart';\n",
                             "Flutter 패키지(flutter_riverpod)")

    def test_domain_must_not_import_riverpod(self):
        self.assertViolation("domain/a_domain/lib/model.dart",
                             'import "package:riverpod_annotation/riverpod_annotation.dart";\n',
                             "Riverpod 패키지(riverpod_annotation)")

    def test_domain_must_not_import_dart_ui(self):
        self.assertViolation("domain/a_domain/lib/model.dart", "import 'dart:ui';\n", "dart:ui")

    def test_domain_must_not_import_data(self):
        self.assertViolation("domain/a_domain/lib/model.dart",
                             "export 'package:a_repository/a_repository.dart';\n",
                             "domain 레이어는 data 레이어(a_repository)")

    def test_data_must_not_import_application(self):
        self.assertViolation("data/a_repository/lib/src/repo.dart",
                             "import 'dart:async';\n\nimport 'package:a_service/a_service.dart' show X;\n",
                             "data 레이어는 application 레이어(a_service)")

    def test_application_must_not_import_app(self):
        self.assertViolation("application/a_service/lib/service.dart",
                             "import 'package:app/main.dart';\n", "application 레이어는 app 레이어(app)")

    def test_violation_reports_line_number(self):
        write(self.root / "data/a_repository/lib/repo.dart",
              "// header\n\nimport 'package:app/main.dart';\n")
        result = self.run_guard()
        self.assertIn("data/a_repository/lib/repo.dart:3:", result.stderr)

    def test_relative_import_escaping_lib_is_rejected(self):
        self.assertViolation("domain/a_domain/lib/model.dart",
                             "import '../../../data/a_repository/lib/repo.dart';\n", "lib/ 경계")

    def test_relative_import_inside_lib_is_allowed(self):
        self.assertAllowed("domain/a_domain/lib/src/model.dart", "import '../a_domain.dart';\n")

    def test_test_directories_are_not_checked(self):
        self.assertAllowed("domain/a_domain/test/model_test.dart",
                           "import 'package:flutter_test/flutter_test.dart';\n")

    def test_commented_import_is_ignored(self):
        self.assertAllowed("domain/a_domain/lib/model.dart", "// import 'package:flutter/material.dart';\n")

    def test_import_inside_block_comment_is_ignored(self):
        self.assertAllowed("domain/a_domain/lib/model.dart",
                           "/*\nimport 'package:flutter/material.dart';\n/* nested */\n"
                           "import 'package:a_repository/a_repository.dart';\n*/\nclass A {}\n")

    def test_line_comment_does_not_open_block_comment(self):
        write(self.root / "domain/a_domain/lib/model.dart",
              "// see /* for details\nimport 'package:flutter/material.dart';\n")
        result = self.run_guard()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("domain/a_domain/lib/model.dart:2:", result.stderr)

    def test_block_comment_markers_inside_strings_are_not_comments(self):
        write(self.root / "domain/a_domain/lib/model.dart",
              "export 'src/a.dart' show A; // '/*'\nimport 'package:flutter/material.dart';\n")
        result = self.run_guard()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("domain/a_domain/lib/model.dart:2:", result.stderr)

    def test_second_directive_on_the_same_line_is_checked(self):
        write(self.root / "domain/a_domain/lib/model.dart",
              "import 'dart:async'; import 'package:flutter/material.dart';\n")
        result = self.run_guard()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("domain/a_domain/lib/model.dart:1: 'package:flutter/material.dart'", result.stderr)

    def test_directive_text_inside_strings_is_not_a_directive(self):
        self.assertAllowed("domain/a_domain/lib/model.dart",
                           "const template = \'\'\'\nimport 'package:flutter/material.dart';\n\'\'\';\n"
                           "const line = \"import 'package:a_service/a_service.dart';\";\n")

    def test_raw_string_uris_are_checked(self):
        self.assertViolation("domain/a_domain/lib/model.dart",
                             "import r'package:flutter/material.dart';\n", "Flutter 패키지(flutter)")
        self.assertViolation("domain/a_domain/lib/model.dart",
                             'export r"package:a_repository/a_repository.dart";\n', "data 레이어(a_repository)")

    def test_conditional_import_uris_are_checked(self):
        self.assertViolation("domain/a_domain/lib/model.dart",
                             "import 'src/stub.dart'\n    if (dart.library.ui) 'package:flutter/material.dart';\n",
                             "Flutter 패키지(flutter)")

    def test_missing_layer_directory_is_config_error(self):
        (self.root / "application/a_service/pubspec.yaml").unlink()
        (self.root / "application/a_service").rmdir()
        (self.root / "application").rmdir()
        result = self.run_guard()
        self.assertEqual(result.returncode, 2)
        self.assertIn("레이어 디렉터리가 없습니다", result.stderr)

    def test_pubspec_without_name_is_config_error(self):
        write(self.root / "data/a_repository/pubspec.yaml", "description: nameless\n")
        result = self.run_guard()
        self.assertEqual(result.returncode, 2)
        self.assertIn("name 이 없습니다", result.stderr)


if __name__ == "__main__":
    unittest.main()
