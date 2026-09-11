#!/usr/bin/env python3
"""Small dependency-free downloader for GriddingMachine catalog entries.

The script is intentionally usable from C, Fortran, R, MATLAB and Octave.
It accepts an explicit URL as well as a tag from Artifacts.yaml; the latter
uses a conservative parser for the catalog's PATH/URL fields.
"""
import argparse, hashlib, re, sys, urllib.request

def entry(catalog, tag):
    text = open(catalog, encoding="utf-8").read()
    m = re.search(r"(?m)^" + re.escape(tag) + r":\s*$", text)
    if not m: raise ValueError("tag not found: " + tag)
    block = text[m.end():]
    nxt = re.search(r"(?m)^[A-Za-z0-9_.-]+:\s*$", block)
    block = block[:nxt.start()] if nxt else block
    urls = re.findall(r'(?m)^\s*-\s*["\']([^"\']+)["\']\s*$', block)
    path = re.search(r'(?m)^\s*PATH:\s*["\']([^"\']+)', block)
    size = re.search(r'(?m)^\s*SIZE:\s*(\d+)', block)
    sha = re.search(r'(?m)^\s*SHA256:\s*["\']([0-9a-fA-F]{64})', block)
    if not urls or not path: raise ValueError("invalid catalog entry: " + tag)
    return urls, path.group(1), int(size.group(1)) if size else None, sha.group(1).lower() if sha else None

def download(url, output, size=None, sha=None):
    h = hashlib.sha256(); n = 0
    with urllib.request.urlopen(url, timeout=60) as src, open(output, "wb") as dst:
        while True:
            b = src.read(1024 * 1024)
            if not b: break
            dst.write(b); h.update(b); n += len(b)
    if size is not None and n != size: raise ValueError("size mismatch")
    if sha is not None and h.hexdigest() != sha: raise ValueError("SHA256 mismatch")

if __name__ == "__main__":
    p=argparse.ArgumentParser(); p.add_argument("--tag"); p.add_argument("--catalog")
    p.add_argument("--url"); p.add_argument("--output", required=True); p.add_argument("--size", type=int); p.add_argument("--sha256")
    a=p.parse_args()
    urls=[a.url]; size=a.size; sha=a.sha256
    if a.tag:
        if not a.catalog: p.error("--catalog is required with --tag")
        urls, _, size, sha = entry(a.catalog, a.tag)
    errors=[]
    for u in urls:
        try: download(u, a.output, size, sha); print(a.output); break
        except Exception as e: errors.append(f"{u}: {e}")
    else: raise SystemExit("all mirrors failed\n" + "\n".join(errors))
