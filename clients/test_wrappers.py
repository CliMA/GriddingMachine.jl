import argparse
import hashlib
import http.server
import os
import subprocess
import sys
import tempfile
import threading
import unittest
from pathlib import Path
from urllib.parse import quote


ROOT = Path(__file__).resolve().parent.parent
PAYLOAD = b"griddingmachine-cross-language-download\x00\x01\xff"


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass


def python3_shim(directory):
    directory.mkdir()
    if os.name == "nt":
        shim = directory / "python3.bat"
        shim.write_text(f'@"{sys.executable}" %*\n', encoding="utf-8")
    else:
        shim = directory / "python3"
        shim.write_text(f'#!/bin/sh\nexec "{sys.executable}" "$@"\n', encoding="utf-8")
        shim.chmod(0o755)


class WrapperTests(unittest.TestCase):
    executables = {}

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        source = self.root / "source with spaces"
        source.mkdir()
        self.fixture = source / "fixture with spaces.nc"
        self.fixture.write_bytes(PAYLOAD)
        self.digest = hashlib.sha256(PAYLOAD).hexdigest()
        self.server = http.server.ThreadingHTTPServer(
            ("127.0.0.1", 0),
            lambda *args, **kwargs: QuietHandler(
                *args, directory=str(self.root), **kwargs
            ),
        )
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        encoded = quote(self.fixture.relative_to(self.root).as_posix())
        self.url = f"http://127.0.0.1:{self.server.server_port}/{encoded}"
        self.shim = self.root / "python shim"
        python3_shim(self.shim)

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=5)
        self.temporary.cleanup()

    def check_wrapper(self, language):
        executable = self.executables[language]
        output = self.root / "output with spaces" / f"{language} result.nc"
        output.parent.mkdir(exist_ok=True)
        environment = os.environ.copy()
        environment["PATH"] = (
            str(Path(sys.executable).parent)
            + os.pathsep
            + str(self.shim)
            + os.pathsep
            + environment["PATH"]
        )
        environment.pop("GM_PYTHON", None)
        result = subprocess.run(
            [str(executable), self.url, str(output)],
            cwd=ROOT,
            env=environment,
            check=False,
            capture_output=True,
            text=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(output.read_bytes(), PAYLOAD)
        self.assertEqual(hashlib.sha256(output.read_bytes()).hexdigest(), self.digest)
        self.assertEqual(list(output.parent.glob("*.part")), [])

    def test_c_wrapper(self):
        if "c" not in self.executables:
            self.skipTest("C executable was not supplied")
        self.check_wrapper("c")

    def test_fortran_wrapper(self):
        if "fortran" not in self.executables:
            self.skipTest("Fortran executable was not supplied")
        self.check_wrapper("fortran")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--c-exe", type=Path)
    parser.add_argument("--fortran-exe", type=Path)
    arguments, remaining = parser.parse_known_args()
    if arguments.c_exe:
        WrapperTests.executables["c"] = arguments.c_exe.resolve()
    if arguments.fortran_exe:
        WrapperTests.executables["fortran"] = arguments.fortran_exe.resolve()
    unittest.main(argv=[sys.argv[0], *remaining], verbosity=2)
