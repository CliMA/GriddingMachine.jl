import hashlib
import http.server
import subprocess
import sys
import tempfile
import threading
import unittest
from pathlib import Path
from urllib.parse import quote

ROOT = Path(__file__).parent


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass


class DownloadTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.source = self.root / "source with spaces"
        self.output = self.root / "output with spaces"
        self.source.mkdir()
        self.output.mkdir()
        self.payload = b"griddingmachine-cross-language-download\x00\x01\xff"
        self.fixture = self.source / "fixture with spaces.nc"
        self.fixture.write_bytes(self.payload)
        self.digest = hashlib.sha256(self.payload).hexdigest()
        self.server = http.server.ThreadingHTTPServer(
            ("127.0.0.1", 0),
            lambda *args, **kwargs: QuietHandler(
                *args, directory=str(self.root), **kwargs
            ),
        )
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        encoded_path = quote(self.fixture.relative_to(self.root).as_posix())
        self.url = f"http://127.0.0.1:{self.server.server_port}/{encoded_path}"

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=5)
        self.temporary.cleanup()

    def run_downloader(self, *arguments):
        return subprocess.run(
            [sys.executable, str(ROOT / "download.py"), *map(str, arguments)],
            cwd=ROOT.parent,
            check=False,
            capture_output=True,
            text=True,
        )

    def assert_download(self, path):
        self.assertTrue(path.is_file())
        self.assertEqual(path.read_bytes(), self.payload)
        self.assertEqual(hashlib.sha256(path.read_bytes()).hexdigest(), self.digest)
        self.assertEqual(list(path.parent.glob("*.part")), [])

    def test_direct_url_with_spaces_and_integrity_metadata(self):
        destination = self.output / "direct output with spaces.nc"
        result = self.run_downloader(
            "--url",
            self.url,
            "--output",
            destination,
            "--size",
            len(self.payload),
            "--sha256",
            self.digest,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_download(destination)

    def test_catalog_tag_and_mirror_fallback(self):
        destination = self.output / "catalog output with spaces.nc"
        catalog = self.root / "catalog with spaces.yaml"
        catalog.write_text(
            "TEST_FIXTURE:\n"
            '  PATH: "fixture.nc"\n'
            f'  - "http://127.0.0.1:{self.server.server_port}/missing.nc"\n'
            f'  - "{self.url}"\n'
            f"  SIZE: {len(self.payload)}\n"
            f'  SHA256: "{self.digest}"\n',
            encoding="utf-8",
        )
        result = self.run_downloader(
            "--tag",
            "TEST_FIXTURE",
            "--catalog",
            catalog,
            "--output",
            destination,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_download(destination)


if __name__ == "__main__":
    unittest.main(verbosity=2)
