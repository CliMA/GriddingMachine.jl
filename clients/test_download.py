"""Regression tests for shared transactional and integrity-aware downloads."""

import concurrent.futures
import hashlib
import http.server
import importlib.util
import os
import subprocess
import sys
import tempfile
import threading
import unittest
from unittest import mock
from pathlib import Path
from urllib.parse import quote

ROOT = Path(__file__).resolve().parent
# Load the implementation without creating bytecode in the source checkout.
spec = importlib.util.spec_from_file_location("gm_download_core", ROOT / "download.py")
core = importlib.util.module_from_spec(spec)
sys.dont_write_bytecode = True
spec.loader.exec_module(core)


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass

    def do_GET(self):
        # Simulate a response interrupted after sending only part of its declared body.
        if self.path == "/truncated":
            self.send_response(200)
            self.send_header("Content-Length", "999")
            self.end_headers()
            self.wfile.write(b"partial")
            self.close_connection = True
            return
        super().do_GET()


class DownloadTests(unittest.TestCase):
    def setUp(self):
        # All network traffic uses a local fixture; no public dataset is downloaded.
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
            lambda *args, **kwargs: QuietHandler(*args, directory=str(self.root), **kwargs),
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
        # Invoke the CLI outside the repository to avoid accidental working-directory assumptions.
        return subprocess.run(
            [sys.executable, str(ROOT / "download.py"), *map(str, arguments)],
            # Exercise output reporting on a narrow terminal encoding as well.
            env={**os.environ, "PYTHONIOENCODING": "ascii"},
            cwd=self.root, check=False, capture_output=True, text=True,
        )

    def assert_download(self, path):
        self.assertEqual(path.read_bytes(), self.payload)
        self.assertEqual(hashlib.sha256(path.read_bytes()).hexdigest(), self.digest)
        self.assertEqual(list(path.parent.glob("*.part")), [])

    def catalog(self, mirrors, sha=None, size=None):
        # Emit the same URL-list schema as the public Artifacts.yaml.
        path = self.root / "catalog with spaces.yaml"
        path.write_text(
            'TEST_FIXTURE:\n  PATH: "public/v0"\n  URL:\n'
            + "".join(f'    - "{url}"\n' for url in mirrors)
            + f"  SIZE: {len(self.payload) if size is None else size}\n"
            + f'  SHA256: "{self.digest if sha is None else sha}"\n',
            encoding="utf-8",
        )
        return path

    def test_direct_url_with_spaces_and_integrity_metadata(self):
        destination = self.output / "direct output with spaces.nc"
        result = self.run_downloader(
            "--url", self.url, "--output", destination,
            "--size", len(self.payload), "--sha256", self.digest.upper(),
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_download(destination)

    def test_catalog_tag_and_mirror_fallback(self):
        catalog = self.catalog([self.url + ".missing", self.url])
        destination = self.output / "catalog result.nc"
        result = self.run_downloader("--tag", "TEST_FIXTURE", "--catalog", catalog, "--output", destination)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_download(destination)

    def test_failed_integrity_preserves_existing_file(self):
        # Check both SIZE and SHA256 failures, the original destructive-overwrite regression.
        for option, value in [("--size", 999), ("--sha256", "0" * 64)]:
            with self.subTest(option=option):
                destination = self.output / "existing.nc"
                destination.write_bytes(b"previous-valid-file")
                result = self.run_downloader("--url", self.url, "--output", destination, option, value)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(destination.read_bytes(), b"previous-valid-file")
                self.assertEqual(list(destination.parent.glob("*.part")), [])

    def test_all_mirrors_failed_preserves_existing_file(self):
        destination = self.output / "existing.nc"
        destination.write_bytes(b"previous-valid-file")
        catalog = self.catalog([self.url, self.url + ".missing"], sha="0" * 64)
        result = self.run_downloader("--tag", "TEST_FIXTURE", "--catalog", catalog, "--output", destination)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(destination.read_bytes(), b"previous-valid-file")
        self.assertEqual(list(destination.parent.glob("*.part")), [])

    def test_bad_content_falls_back_to_valid_mirror(self):
        # A reachable mirror with the wrong bytes must not prevent verified fallback.
        wrong = self.root / "wrong.nc"
        wrong.write_bytes(b"incorrect")
        url = f"http://127.0.0.1:{self.server.server_port}/wrong.nc"
        catalog = self.catalog([url, self.url])
        destination = self.output / "fallback.nc"
        result = self.run_downloader("--tag", "TEST_FIXTURE", "--catalog", catalog, "--output", destination)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_download(destination)

    def test_interrupted_response_preserves_existing_file(self):
        destination = self.output / "existing.nc"
        destination.write_bytes(b"previous-valid-file")
        url = f"http://127.0.0.1:{self.server.server_port}/truncated"
        result = self.run_downloader("--url", url, "--output", destination)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(destination.read_bytes(), b"previous-valid-file")
        self.assertEqual(list(destination.parent.glob("*.part")), [])

    def test_nested_output_directory_and_encoded_arguments(self):
        # Encoded clients must preserve literal punctuation, empty strings, and UTF-8 text.
        destination = self.output / "new directory" / "数据 & 20% ' !.nc"
        arguments = ["--url", self.url, "--output", str(destination), "--sha256", self.digest]
        encoded = ["x" + value.encode("utf-8").hex() for value in arguments]
        result = self.run_downloader("--encoded-args", *encoded)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_download(destination)

    def test_catalog_integrity_cannot_be_overridden(self):
        catalog = self.catalog([self.url])
        destination = self.output / "no-output.nc"
        result = self.run_downloader(
            "--tag", "TEST_FIXTURE", "--catalog", catalog, "--output", destination,
            "--sha256", "0" * 64,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("conflicts", result.stderr)
        self.assertFalse(destination.exists())

    def test_malformed_catalog_metadata_is_rejected(self):
        for size, sha in [(-1, self.digest), (42, "bad-sha")]:
            with self.subTest(size=size, sha=sha):
                catalog = self.catalog([self.url], size=size, sha=sha)
                result = self.run_downloader(
                    "--tag", "TEST_FIXTURE", "--catalog", catalog, "--output", self.output / "invalid.nc"
                )
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse((self.output / "invalid.nc").exists())

    def test_argument_validation(self):
        # Invalid sources and encoded tokens must fail before creating a destination.
        destination = self.output / "invalid.nc"
        for arguments in [
            ["--output", str(destination)],
            ["--url", self.url, "--tag", "TEST_FIXTURE", "--output", str(destination)],
            ["--tag", "TEST_FIXTURE", "--output", str(destination)],
            ["--encoded-args", "xzz"],
        ]:
            with self.subTest(arguments=arguments):
                self.assertNotEqual(self.run_downloader(*arguments).returncode, 0)
                self.assertFalse(destination.exists())

    def test_transient_windows_replacement_error_is_retried(self):
        # Model a scanner holding the destination once, followed by a successful promotion.
        destination = self.output / "retry.nc"
        destination.write_bytes(b"previous file")
        error = PermissionError("temporary Windows sharing violation")
        error.winerror = 32
        replace = core.os.replace
        calls = []

        def intermittent(source, target):
            calls.append(target)
            if len(calls) == 1:
                raise error
            replace(source, target)

        with mock.patch.object(core.os, "replace", side_effect=intermittent), mock.patch.object(core.time, "sleep"):
            core.download(self.url, destination, len(self.payload), self.digest)
        self.assertEqual(len(calls), 2)
        self.assert_download(destination)

    def test_persistent_replacement_error_preserves_previous_file(self):
        # Exhausting bounded retries must leave the previous file and clean the temporary file.
        destination = self.output / "locked.nc"
        destination.write_bytes(b"previous file")
        error = PermissionError("persistent Windows access denial")
        error.winerror = 5
        with mock.patch.object(core.os, "replace", side_effect=error) as replace, mock.patch.object(core.time, "sleep"):
            with self.assertRaises(PermissionError):
                core.download(self.url, destination, len(self.payload), self.digest)
            self.assertEqual(replace.call_count, 8)
        self.assertEqual(destination.read_bytes(), b"previous file")
        self.assertEqual(list(self.output.glob("*.part")), [])

    def test_concurrent_downloads_use_independent_temporary_files(self):
        destination = self.output / "concurrent.nc"
        # Concurrent valid transfers must not collide on a fixed .part filename.
        with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
            futures = [
                pool.submit(core.download, self.url, destination, len(self.payload), self.digest)
                for _ in range(4)
            ]
            for future in futures:
                future.result()
        self.assert_download(destination)


if __name__ == "__main__":
    unittest.main(verbosity=2)
