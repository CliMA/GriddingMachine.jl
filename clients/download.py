#!/usr/bin/env python3
"""Dependency-free, transactional downloads shared by all language clients."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import sys
import tempfile
import urllib.request


def _scalar(value):
    """Read the scalar subset emitted by the GriddingMachine catalog writer."""
    # Parse quoted values explicitly so URL punctuation is preserved.
    value = value.strip()
    if value.startswith('"'):
        result, end = json.JSONDecoder().raw_decode(value)
        if value[end:].strip() and not value[end:].lstrip().startswith("#"):
            raise ValueError("invalid quoted catalog value")
        return result
    if value.startswith("'"):
        match = re.fullmatch(r"'((?:[^']|'')*)'\s*(?:#.*)?", value)
        if not match:
            raise ValueError("invalid single-quoted catalog value")
        return match.group(1).replace("''", "'")
    return re.split(r"\s+#", value, maxsplit=1)[0].strip()


def _integrity(size, sha):
    """Reject malformed metadata rather than silently skipping integrity checks."""
    if size is not None:
        if not re.fullmatch(r"[0-9]+", str(size)) or int(size) <= 0:
            raise ValueError("SIZE must be a positive byte count")
        size = int(size)
    if sha is not None:
        if not isinstance(sha, str) or not re.fullmatch(r"[0-9a-fA-F]{64}", sha):
            raise ValueError("SHA256 must contain 64 hexadecimal characters")
        sha = sha.lower()
    return size, sha


def entry(catalog, tag):
    """Resolve one tag in the flat PATH/URL/SIZE/SHA256 catalog schema."""
    text = Path(catalog).read_text(encoding="utf-8")
    headers = list(re.finditer(r"(?m)^([A-Za-z0-9_.-]+):[ \t]*(?:#.*)?$", text))
    # Only URL list items are mirrors; unrelated lists must not become downloads.
    for index, header in enumerate(headers):
        if header.group(1) != tag:
            continue
        end = headers[index + 1].start() if index + 1 < len(headers) else len(text)
        fields, urls, current = {}, [], None
        for line in text[header.end():end].splitlines():
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            field = re.fullmatch(r"[ \t]+([A-Za-z0-9_]+):[ \t]*(.*)", line)
            if field:
                current, value = field.groups()
                if current in fields:
                    raise ValueError("duplicate catalog field: " + current)
                fields[current] = _scalar(value) if value.strip() else None
                if current == "URL" and fields[current] is not None:
                    urls.append(fields[current])
                continue
            item = re.fullmatch(r"[ \t]+-[ \t]+(.*)", line)
            if item and current == "URL":
                urls.append(_scalar(item.group(1)))
            else:
                raise ValueError("unsupported catalog syntax for " + tag)
        if not fields.get("PATH") or not urls or any(not isinstance(u, str) or not u for u in urls):
            raise ValueError("invalid catalog entry: " + tag)
        size, sha = _integrity(fields.get("SIZE"), fields.get("SHA256", fields.get("SHA")))
        return urls, fields["PATH"], size, sha
    raise ValueError("tag not found: " + tag)


def download(url, output, size=None, sha=None):
    """Verify a unique temporary file before atomically replacing the destination."""
    size, sha = _integrity(size, sha)
    destination = Path(output)
    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        # A sibling temporary file keeps replacement on the same filesystem.
        with tempfile.NamedTemporaryFile(
            dir=destination.parent, prefix="." + destination.name + ".", suffix=".part", delete=False
        ) as dst:
            temporary = Path(dst.name)
            digest, count = hashlib.sha256(), 0
            with urllib.request.urlopen(url, timeout=60) as src:
                # Detect incomplete HTTP/FTP responses even without catalog checksums.
                declared = src.headers.get("Content-Length")
                declared = int(declared) if declared is not None else None
                while True:
                    block = src.read(1024 * 1024)
                    if not block:
                        break
                    dst.write(block)
                    digest.update(block)
                    count += len(block)
                if declared is not None and count != declared:
                    raise ValueError("incomplete response body")
            if size is not None and count != size:
                raise ValueError("size mismatch")
            if sha is not None and digest.hexdigest() != sha:
                raise ValueError("SHA256 mismatch")
            dst.flush()
            os.fsync(dst.fileno())
        # Close both streams before promotion, including on Windows.
        os.replace(temporary, destination)
        return str(destination)
    finally:
        # Failed transfers and integrity checks never modify the previous target.
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def main(argv=None):
    argv = list(sys.argv[1:] if argv is None else argv)
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--url")
    source.add_argument("--tag")
    parser.add_argument("--catalog")
    parser.add_argument("--output", required=True)
    parser.add_argument("--size", type=int)
    parser.add_argument("--sha256")
    # Shell clients encode every UTF-8 argument, preserving spaces and metacharacters.
    if argv and argv[0] == "--encoded-args":
        try:
            if any(not token.startswith("x") for token in argv[1:]):
                raise ValueError("missing encoded argument prefix")
            argv = [bytes.fromhex(token[1:]).decode("utf-8") for token in argv[1:]]
        except (ValueError, UnicodeError) as error:
            parser.error("invalid encoded arguments: " + str(error))
    args = parser.parse_args(argv)
    if args.tag and not args.catalog:
        parser.error("--catalog is required with --tag")
    if args.catalog and not args.tag:
        parser.error("--catalog requires --tag")
    try:
        size, sha = _integrity(args.size, args.sha256)
        urls = [args.url]
        if args.tag:
            urls, _, catalog_size, catalog_sha = entry(args.catalog, args.tag)
            # Explicit checks may supplement catalog metadata, but never weaken it.
            if size is not None and catalog_size is not None and size != catalog_size:
                raise ValueError("--size conflicts with catalog SIZE")
            if sha is not None and catalog_sha is not None and sha != catalog_sha:
                raise ValueError("--sha256 conflicts with catalog SHA256")
            size = catalog_size if catalog_size is not None else size
            sha = catalog_sha if catalog_sha is not None else sha
        errors = []
        for url in urls:
            try:
                print(download(url, args.output, size, sha))
                return 0
            except Exception as error:
                errors.append(f"{url}: {error}")
        print("all mirrors failed\n" + "\n".join(errors), file=sys.stderr)
        return 1
    except (OSError, ValueError) as error:
        print(str(error), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
