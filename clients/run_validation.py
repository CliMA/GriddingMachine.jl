#!/usr/bin/env python3
"""Compile available clients and run local-fixture tests on a host or CI runner."""

import argparse
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent


def run(command):
    # Display reproducible arguments and preserve nonzero test/compile exit codes.
    print("+ " + " ".join(map(str, command)), flush=True)
    subprocess.run(list(map(str, command)), cwd=ROOT.parent, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--require-languages", default="")
    parser.add_argument("--matlab-exe")
    args = parser.parse_args()
    required = set(filter(None, args.require_languages.split(",")))
    options, available = [], set()
    with tempfile.TemporaryDirectory(prefix="gm-client-build-") as directory:
        # Keep generated executables and all downloaded fixtures outside the checkout.
        build = Path(directory)
        compiler = shutil.which("gcc") or shutil.which("clang")
        if compiler:
            exe = build / ("gm_c.exe" if sys.platform == "win32" else "gm_c")
            run([compiler, "-std=c99", "-Wall", "-Wextra", "-Werror", ROOT / "gm_download.c", "-o", exe])
            options += ["--c-exe", str(exe)]
            available.add("c")
        compiler = shutil.which("gfortran")
        if compiler:
            exe = build / ("gm_fortran.exe" if sys.platform == "win32" else "gm_fortran")
            run([compiler, "-std=f2008", "-Wall", "-Wextra", "-Werror", "-fcheck=all",
                 ROOT / "gm_download.f90", "-o", exe])
            options += ["--fortran-exe", str(exe)]
            available.add("fortran")
        for language, command in (("r", "Rscript"), ("octave", "octave")):
            executable = shutil.which(command)
            if executable:
                options += ["--" + language + "-exe", executable]
                available.add(language)
        if args.matlab_exe:
            options += ["--matlab-exe", args.matlab_exe]
            available.add("matlab")
        # Missing required runtimes are a failed validation, not a successful skip.
        if not required <= available:
            parser.error("missing required runtimes: " + ", ".join(sorted(required - available)))
        run([sys.executable, ROOT / "test_download.py"])
        run([sys.executable, ROOT / "test_wrappers.py", *options,
             "--require-languages", args.require_languages])


if __name__ == "__main__":
    main()
