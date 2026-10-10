#!/usr/bin/env python3
"""하네스 테스트 실행기. tool/test/*_test.py 를 실행하고, 발견된 테스트가 0개면 실패한다.

    python3 tool/test/run_tests.py [-v] [-k 패턴]
"""
import argparse
import sys
import unittest
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-v", "--verbose", action="store_true")
    parser.add_argument("-k", dest="pattern", help="이름에 이 문자열이 들어간 테스트만 실행")
    args = parser.parse_args()

    here = Path(__file__).resolve().parent
    loader = unittest.TestLoader()
    if args.pattern:
        loader.testNamePatterns = ["*{}*".format(args.pattern)]
    suite = loader.discover(str(here), pattern="*_test.py", top_level_dir=str(here))
    count = suite.countTestCases()
    if count == 0:
        print("[harness] ✗ 실행할 하네스 테스트를 찾지 못했습니다.", file=sys.stderr)
        return 1
    result = unittest.TextTestRunner(verbosity=2 if args.verbose else 1).run(suite)
    if not result.wasSuccessful():
        return 1
    print("[harness] ✓ 하네스 테스트 {}개 통과".format(result.testsRun))
    return 0


if __name__ == "__main__":
    sys.exit(main())
