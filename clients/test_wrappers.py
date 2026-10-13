"""Exercise native clients through the same loopback HTTP regression cases."""

import argparse
import hashlib
import http.server
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import threading
import unittest
from urllib.parse import quote

ROOT = Path(__file__).resolve().parent
PAYLOAD = b"griddingmachine-cross-language-download\x00\x01\xff"


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass


class WrapperTests(unittest.TestCase):
    executables = {}

    def setUp(self):
        # Install clients in a temporary bundle and run from an unrelated directory.
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.bundle = self.root / "installed clients with spaces"
        self.bundle.mkdir()
        for name in ("download.py", "gm_download.m", "gm_download.R"):
            shutil.copyfile(ROOT / name, self.bundle / name)
        self.native = {}
        for language in ("c", "fortran"):
            if language in self.executables:
                suffix = ".exe" if os.name == "nt" else ""
                target = self.bundle / (language + suffix)
                shutil.copy2(self.executables[language], target)
                self.native[language] = target
        self.work = self.root / "unrelated working directory"
        self.work.mkdir()
        self.payload_file = self.root / "fixture with spaces.nc"
        self.payload_file.write_bytes(PAYLOAD)
        self.digest = hashlib.sha256(PAYLOAD).hexdigest()
        self.server = http.server.ThreadingHTTPServer(
            ("127.0.0.1", 0),
            lambda *args, **kwargs: QuietHandler(*args, directory=str(self.root), **kwargs),
        )
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.url = f"http://127.0.0.1:{self.server.server_port}/{quote(self.payload_file.name)}"
        self.catalog = self.root / "catalog with spaces.yaml"
        self.catalog.write_text(
            'TEST_FIXTURE:\n  PATH: "public/v0"\n  URL:\n'
            f'    - "{self.url}.missing"\n    - "{self.url}"\n'
            f'  SIZE: {len(PAYLOAD)}\n  SHA256: "{self.digest}"\n',
            encoding="utf-8",
        )

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=5)
        self.temporary.cleanup()

    def invoke(self, language, output, tag=False, sha=None, explicit_script=False):
        # Use native parameter names but require equivalent shared-downloader behavior.
        env = os.environ.copy()
        env["GM_PYTHON"] = sys.executable
        env.pop("GM_DOWNLOADER", None)
        if explicit_script:
            env["GM_DOWNLOADER"] = str(ROOT / "download.py")
        if language in self.native:
            arguments = ["--tag", "TEST_FIXTURE", "--catalog", str(self.catalog), "--output", str(output)] if tag else [self.url, str(output)]
            if sha is not None:
                arguments += ["--size", str(len(PAYLOAD)), "--sha256", sha]
            command = [str(self.native[language]), *arguments]
        elif language == "r":
            # Source captures the wrapper location before the R process changes directory.
            literal = lambda value: json.dumps(str(value), ensure_ascii=False)
            call = (
                f'gm_download(output={literal(output)}, tag="TEST_FIXTURE", catalog={literal(self.catalog)}'
                if tag else f"gm_download({literal(self.url)}, {literal(output)}"
            )
            if sha is not None:
                call += f", size={len(PAYLOAD)}, sha256={literal(sha)}"
            driver = self.root / "driver.R"
            driver.write_text(
                f"# Load the installed client and then change the working directory.\n"
                f"source({literal(self.bundle / 'gm_download.R')})\n"
                f"setwd({literal(self.work)})\n{call})\n",
                encoding="utf-8",
            )
            command = [self.executables[language], "--vanilla", str(driver)]
        else:
            # The same .m entry point is exercised in Octave and optional MATLAB.
            literal = lambda value: "'" + str(value).replace("'", "''") + "'"
            call = (
                f"gm_download('', {literal(output)}, 'Tag', 'TEST_FIXTURE', 'Catalog', {literal(self.catalog)}"
                if tag else f"gm_download({literal(self.url)}, {literal(output)}"
            )
            if sha is not None:
                call += f", 'Size', {len(PAYLOAD)}, 'SHA256', {literal(sha)}"
            driver = self.root / "driver.m"
            driver.write_text(
                "% Load the installed function without relying on the caller's directory.\n"
                f"addpath({literal(self.bundle)});\ncd({literal(self.work)});\n{call});\n",
                encoding="utf-8",
            )
            command = (
                [self.executables[language], "-batch", f"run({literal(driver)})"]
                if language == "matlab" else
                [self.executables[language], "--no-gui", "--quiet", str(driver)]
            )
        return subprocess.run(command, cwd=self.work, env=env, capture_output=True, text=True, timeout=60)

    def check(self, language, scenario):
        # Absent runtimes are reported as skips; required-language checks run before the suite.
        if language not in self.executables:
            self.skipTest(f"{language} runtime was not supplied")
        name = "output & 20% ' !.nc"
        if os.name != "nt":
            name = "数据 " + name
        output = self.work / "new nested folder" / name
        failure = scenario in ("bad_sha", "bad_size")
        if failure:
            output.parent.mkdir()
            output.write_bytes(b"previous-valid-file")
        sha = "0" * 64 if scenario == "bad_sha" else self.digest if scenario == "integrity" else None
        if scenario == "bad_size":
            # Force catalog SIZE failure while leaving its checksum syntactically valid.
            self.catalog.write_text(self.catalog.read_text().replace(f"SIZE: {len(PAYLOAD)}", "SIZE: 999"))
        result = self.invoke(
            language, output, tag=scenario in ("tag", "bad_size"), sha=sha,
            explicit_script=scenario == "explicit_script",
        )
        if failure:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(output.read_bytes(), b"previous-valid-file")
        else:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(output.read_bytes(), PAYLOAD)
            self.assertEqual(hashlib.sha256(output.read_bytes()).hexdigest(), self.digest)
        self.assertEqual(list(output.parent.glob("*.part")), [])


# Register each language/case as a separate result so missing runtimes cannot hide failures.
for _language in ("c", "fortran", "r", "octave", "matlab"):
    for _scenario in ("legacy_url", "integrity", "tag", "bad_sha", "bad_size", "explicit_script"):
        def _test(self, language=_language, scenario=_scenario):
            self.check(language, scenario)
        setattr(WrapperTests, f"test_{_language}_{_scenario}", _test)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    for language in ("c", "fortran", "r", "octave", "matlab"):
        parser.add_argument("--" + language + "-exe", type=Path)
    parser.add_argument("--require-languages", default="")
    args, remaining = parser.parse_known_args()
    for language in ("c", "fortran", "r", "octave", "matlab"):
        value = getattr(args, language + "_exe")
        if value:
            WrapperTests.executables[language] = str(value.resolve())
    # Fail immediately rather than declaring success with required language tests skipped.
    for language in filter(None, args.require_languages.split(",")):
        if language not in WrapperTests.executables:
            parser.error("missing required runtime: " + language)
    unittest.main(argv=[sys.argv[0], *remaining], verbosity=2)
