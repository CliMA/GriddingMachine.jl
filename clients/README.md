# Cross-language automatic downloads

Julia provides the GriddingMachine reading and mode-input interfaces. The clients
in this directory provide automatic file downloads from Matlab, Octave, Python,
R, C and Fortran. Each client delegates transfers and checks to the same
standard-library-only Python downloader (Python 3.8 or newer).

Downloads go to a unique temporary file beside the destination. Only a completed
transfer that passes the requested byte-count and SHA-256 checks replaces the
destination. A failed download preserves an existing file and removes its temporary
file. Catalog-tag downloads try the registered mirrors in order. Integrity checks
use catalog metadata when present; explicit parameters can supplement it but
cannot override conflicting metadata.

## Python

```sh
python3 clients/download.py --url URL --output FILE --size BYTE_COUNT --sha256 DIGEST
python3 clients/download.py --tag TAG --catalog Artifacts.yaml --output FILE
```

Use `python` on Windows. `--size` and `--sha256` are optional for direct URLs.
The catalog reader accepts the flat `PATH`, `URL`, `SIZE`, and `SHA256` schema
written by GriddingMachine. A tag identifies the registered file; `--output`
chooses the local destination independently of catalog `PATH`.

## Matlab and Octave

Add `clients` to the language search path. The original two-argument call remains
supported, and name-value options expose catalog and integrity parameters:

```matlab
gm_download(url, output);
gm_download(url, output, 'Size', byte_count, 'SHA256', digest);
gm_download('', output, 'Tag', tag, 'Catalog', catalog_path);
```

Optional `Python` and `Script` parameters specify the Python executable and
`download.py` path. Failure raises an error; success returns the output path.

## R

```r
source('clients/gm_download.R')
gm_download(url, output)
gm_download(url, output, size = byte_count, sha256 = digest)
gm_download(output = output, tag = tag, catalog = catalog_path)
```

Optional `python` and `script` parameters select the interpreter and downloader.
Failure raises an error; success invisibly returns the output path.

## C and Fortran

Compile the executables beside `download.py`, so they can find the shared script
from any working directory:

```sh
gcc -std=c99 -Wall -Wextra clients/gm_download.c -o clients/gm_c
gfortran -std=f2008 -Wall -Wextra clients/gm_download.f90 -o clients/gm_fortran
clients/gm_c URL FILE
clients/gm_fortran URL FILE
clients/gm_c --url URL --output FILE --size BYTE_COUNT --sha256 DIGEST
clients/gm_fortran --tag TAG --catalog Artifacts.yaml --output FILE
```

On Windows, use `.exe` output names. Both executables accept either the original
`URL FILE` arguments or the Python option syntax. `--script PATH` selects an
explicit shared downloader. A nonzero exit code reports failure.

## Location and interpreter selection

All native wrappers accept `GM_PYTHON` and `GM_DOWNLOADER` environment variables.
The interpreter defaults to `python` on Windows and `python3` elsewhere. If no
script override is supplied, wrappers look beside their own source or executable;
keep `download.py` with the installed wrapper. A Python executable path with
spaces is supported. Shell wrappers encode data arguments before launching Python
to preserve spaces, quotes and shell punctuation in URLs and output paths.

## Validation

```sh
python clients/run_validation.py --require-languages c,fortran,r,octave
```

The runner compiles available C/Fortran clients and executes generated local HTTP
fixtures. Required missing runtimes fail the command. To additionally test Matlab,
pass `--matlab-exe /path/to/matlab` and include `matlab` in the required list.
See [VALIDATION_PLAN.md](VALIDATION_PLAN.md) for cross-device instructions and
[VALIDATION.md](VALIDATION.md) for recorded results. Hosted CI runs Linux and
Windows checks without downloading any public scientific dataset.
