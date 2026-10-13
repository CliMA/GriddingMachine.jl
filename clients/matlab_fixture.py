#!/usr/bin/env python3
"""Serve temporary loopback fixtures for one licensed MATLAB validation session."""

import argparse
import hashlib
import http.server
import json
import os
from pathlib import Path
import shutil
import sys

# Keep imports and all generated files out of the repository checkout.
sys.dont_write_bytecode = True
from test_wrappers import PAYLOAD

ROOT = Path(__file__).resolve().parent


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    # Expected failed-first-mirror requests should not obscure MATLAB test output.
    def log_message(self, format, *args):
        pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', type=Path, required=True)
    args = parser.parse_args()
    directory = args.directory.resolve()
    directory.mkdir(parents=True, exist_ok=True)
    bundle = directory / 'installed clients with spaces'
    bundle.mkdir(exist_ok=True)
    for name in ('gm_download.m', 'download.py'):
        shutil.copyfile(ROOT / name, bundle / name)
    # The served fixture is binary and includes bytes that text transfers would corrupt.
    fixture = directory / 'fixture with spaces.nc'
    fixture.write_bytes(PAYLOAD)
    digest = hashlib.sha256(PAYLOAD).hexdigest()
    handler = lambda *a, **kw: QuietHandler(*a, directory=str(directory), **kw)
    with http.server.ThreadingHTTPServer(('127.0.0.1', 0), handler) as server:
        url = f'http://127.0.0.1:{server.server_port}/fixture%20with%20spaces.nc'
        catalog = directory / 'catalog with spaces.yaml'
        catalog.write_text(
            'TEST_FIXTURE:\n  PATH: "public/v0"\n  URL:\n'
            f'    - "{url}.missing"\n    - "{url}"\n'
            f'  SIZE: {len(PAYLOAD)}\n  SHA256: "{digest}"\n', encoding='utf-8')
        bad_catalog = directory / 'catalog wrong size.yaml'
        bad_catalog.write_text(catalog.read_text().replace(f'SIZE: {len(PAYLOAD)}', 'SIZE: 999'))
        work = directory / 'unrelated working directory'
        work.mkdir(exist_ok=True)
        # Publish readiness only after the socket and every required input exist.
        metadata = {
            'url': url, 'size': len(PAYLOAD), 'sha256': digest, 'payload': list(PAYLOAD),
            'catalog': str(catalog), 'bad_catalog': str(bad_catalog), 'bundle': str(bundle),
            'work': str(work), 'script': str(ROOT / 'download.py'), 'pid': os.getpid(),
        }
        pending = directory / 'fixture.json.pending'
        pending.write_text(json.dumps(metadata), encoding='utf-8')
        pending.replace(directory / 'fixture.json')
        server.serve_forever()


if __name__ == '__main__':
    main()
