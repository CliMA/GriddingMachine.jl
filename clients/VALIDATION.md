# Cross-language download validation

## Environment

- Date: 2026-09-25
- OS: Microsoft Windows 10.0.19045.6466
- Repository branch: `release/v0.5.0`
- Baseline commit: `e0ee0051ba1e51826f494d03f4a411187477cc61`
- C compiler: GCC 5.3.0 (MinGW-w64, MSYS2 Rev5)
- Fortran compiler: GNU Fortran 5.3.0 (MinGW-w64, MSYS2 Rev5)
- Validation Python: CPython 3.11.16
- Documented Windows command Python: CPython 3.11.0

The compilers and validation Python were installed in a disposable Conda
environment under the manuscript workspace and removed after validation.

## Commands

From the GriddingMachine repository root, with the compiler `bin` directory on
`PATH` and `TEMP`/`TMP` pointing to a writable validation directory:

```text
gcc -Wall -Wextra -Werror clients/gm_download.c -o gm_download_check.exe
gfortran -Wall -Wextra -Werror -fcheck=all clients/gm_download.f90 -o gm_download_f90_check.exe
python -m py_compile clients/download.py clients/test_download.py clients/test_wrappers.py
python clients/test_download.py
python clients/test_wrappers.py --c-exe gm_download_check.exe --fortran-exe gm_download_f90_check.exe
```

The Windows direct-URL command documented in `clients/README.md` was also run
in its published form:

```text
python clients/download.py --url http://127.0.0.1:18765/fixture%20direct.nc --output "README direct result.nc"
```

## Deterministic fixture and results

The cross-language binary fixture was 42 bytes with SHA-256
`c2bcfbc5b5f1da6e92f210a553c344e871749b6af1ee69af156b156d9b555461`.
Its served path and every destination path contained spaces.

| Entry point | Compile | Runtime download | Exact bytes and SHA-256 | Temporary residue |
|---|---:|---:|---:|---:|
| Python direct URL | n/a | PASS | PASS | none |
| Python catalog tag with failed-first-mirror fallback | n/a | PASS | PASS | none |
| C | PASS | PASS | PASS | none |
| Fortran | PASS | PASS | PASS | none |

The separate README invocation used a 7-byte fixture with SHA-256
`717c751b2a14e718b9585b2b1815f29ad77dc0301b17dc4c1b9d41c70c3e5937`;
the downloaded file matched exactly and left no `.part` file.

## Repair evidence

The baseline C wrapper assembled a shell command with POSIX single quotes,
which split a Windows destination containing spaces. It now launches Python
with an argument vector, uses the Windows `python` convention, and retains
`python3` on macOS/Linux. The baseline Fortran source used a variable `STOP`
code that GNU Fortran 5.3 rejected and always selected `python3`; it now uses a
portable constant failure code, selects the platform command, and quotes paths
according to the command processor. Both wrappers accept `GM_PYTHON` for an
explicit Python 3 executable.

The recorded PASS results apply to the repaired source derived from the
baseline commit above. The repository history records the resulting validation
commit.
