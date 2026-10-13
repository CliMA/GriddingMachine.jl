# Isolated and cross-device client validation plan

## Purpose

Validate the repaired automatic-download interfaces without installing new
runtimes on the original macOS host. No public scientific files are needed: tests
serve a deterministic fixture from a temporary loopback HTTP server and download
into temporary directories. Toolchain installation is the only external download.
All changed or added logical code sections must retain English comments.

## Option A: isolated hosted runners

Push `release/v0.5.0` to GitHub. `.github/workflows/ClientDownloads.yml` triggers
`Cross-language downloads` automatically for client changes on that branch.

- Linux: Python, compiled C/Fortran, R and Octave.
- Windows: Python and compiled C/Fortran.
- Matlab: run separately on a licensed device; Octave does not replace Matlab validation.

Inspect both jobs and their individual test results in GitHub Actions. A green
job requires all requested runtimes, successful compilation and successful tests.
If GitHub does not start a run (for example, repository Actions policy), use the
following device procedure instead. Do not interpret the absence of a run as a pass.

## Option B: another device

1. Clone the repository or fetch it, switch to `release/v0.5.0`, and fast-forward
   from `origin/release/v0.5.0`. Preserve unrelated local changes. Record
   `git rev-parse HEAD` before validation.
2. Install Python 3.8+, a C compiler, GNU Fortran, R and Octave using the device's
   approved package manager. On Ubuntu:

   ```sh
   sudo apt-get update
   sudo apt-get install --no-install-recommends -y python3 gcc gfortran r-base octave
   python3 clients/run_validation.py --require-languages c,fortran,r,octave
   ```

   On Windows, put Python and MSYS2 UCRT64 `gcc`/`gfortran` on `PATH`, then:

   ```powershell
   python clients/run_validation.py --require-languages c,fortran
   ```

   To test R or Octave on Windows, add their executables to `PATH` and include
   `r,octave` in the required list. The script never installs dependencies itself.
3. On a licensed Matlab device, provide its executable:

   ```sh
   python3 clients/run_validation.py --matlab-exe /path/to/matlab --require-languages matlab
   ```

   Any other available runtimes are also exercised. Missing runtimes are reported
   as skips unless explicitly required; do not report a skipped language as tested.
4. Save the full terminal output, commit identifier, OS, Python and compiler/runtime
   versions. Add actual results to `clients/VALIDATION.md`, commit and push to the
   release branch. Preserve the existing historical validation record.

## Acceptance cases

Python tests cover catalog parsing, mirror fallback, failed and truncated
transfers, metadata conflicts, concurrent writes and preservation of old files.
Each native wrapper must pass six cases:

1. Original two-argument URL call.
2. URL call with file size and SHA-256 validation.
3. Catalog tag, including an unavailable first mirror.
4. Incorrect SHA-256: nonzero status and unchanged previous file.
5. Incorrect catalog SIZE: nonzero status and unchanged previous file.
6. Explicit downloader-script location override.

Every successful result must match the fixture bytes and SHA-256. All cases use
spaces and shell punctuation in paths and run outside the source directory; POSIX
cases additionally use non-ASCII destination names. No `.part` residue may remain.
Native Windows non-ASCII executable-path support is not established by these cases.

## Original-host record and next action

On 2026-10-13, Python's 13 fixture tests passed locally. The original host compiled
the C wrapper, but the OS terminated the executable with SIGKILL; this is not a
completed runtime validation. Further local dependency downloads were stopped at
the user's request. The new native-wrapper cases therefore need hosted or
cross-device results before they are recorded as passed. The 2026-09-25 Windows
record describes the earlier implementation, rather than this expanded test suite.
