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

## Expanded validation, 2026-10-13

The repaired clients add atomic promotion, preservation of previous files on
failure, consistent error propagation, explicit script/interpreter selection and
catalog/integrity parameters across all wrappers. Tests use loopback HTTP
fixtures, including failed mirrors and invalid integrity metadata.

Validated source: `477c5ba8463f9b10efcde942806b48d1e33e7796`.
[Hosted run 38391975413](https://github.com/CliMA/GriddingMachine.jl/actions/runs/38391975413)
completed successfully in both jobs.

| Runner | Python fixture cases | Native wrapper cases passed | Skipped languages |
|---|---:|---:|---|
| Linux | 13 | 24: C, Fortran, R, Octave; six each | Matlab |
| Windows | 13 | 18: C, Fortran, R; six each | Matlab, Octave |

The native cases exercise the original two-argument URL call, explicit integrity
checks, catalog tags with mirror fallback, wrong SHA-256, wrong catalog SIZE and
an explicit script override. Incorrect-integrity cases must report the expected
checksum/size error, return failure, preserve previous bytes and leave no
`.part` file. Successful cases must match the fixture exactly. Execution uses an
unrelated working directory, installed client paths with spaces, and output
names with shell punctuation; Linux output names additionally contain Chinese.

The original macOS host passed the 13 Python cases and strict C compilation.
Its OS killed the local C executable, so native execution was moved to hosted
runners. No further local runtime installation is needed for the above results.
The earlier Windows compiler record remains historical evidence for the prior
implementation; the hosted run tests the expanded interfaces.

## Independent Matlab cloud validation, 2026-10-13

Validated source: `107a133a02c7a4ed67f6601b09c087ed4de4d9a6`.
[Hosted Matlab run 38398605598](https://github.com/CliMA/GriddingMachine.jl/actions/runs/38398605598)
completed successfully using the official MathWorks public-project batch actions.

- Runner: GitHub-hosted Linux (`ubuntu-latest`).
- Actual runtime: Matlab `25.2.0.3360999 (R2025b) Update 7`.
- Native entry point: the installed copy of `clients/gm_download.m`.
- Result: all six runtime cases passed in one licensed Matlab session.

| Case | Result |
|---|---|
| Original two-argument URL call | PASS |
| URL with byte count and SHA-256 checks | PASS |
| Catalog tag with failed-first-mirror fallback | PASS |
| Incorrect SHA-256, explicit integrity error and unchanged previous file | PASS |
| Incorrect catalog SIZE, explicit integrity error and unchanged previous file | PASS |
| Explicit downloader-script path | PASS |

The session ran outside the source directory, with the installed client path
containing spaces and output names containing Chinese, spaces, quotes, percent,
ampersand and exclamation characters. Successful files matched all binary fixture
bytes; failure cases preserved previous bytes, and no `.part` residue remained.
Matlab invoked the shared Python implementation through its native `system`
interface. No Matlab Engine API or substitute interpreter was used.

`MatlabDownloads.yml` retains this independent check for future Matlab-client
changes. The job uploads `matlab_results.json`, the Matlab log and the fixture-server
log as `matlab-download-validation`. Cross-device instructions remain available
in [VALIDATION_PLAN.md](VALIDATION_PLAN.md) for additional runtimes or platforms.
