# Cross-language automatic download entry points

The 2022 GriddingMachine release provided Julia, MATLAB, Octave, Python and R
interfaces. This directory keeps those interfaces usable with the current
direct-NetCDF catalog and adds small C and Fortran entry points. All adapters
delegate transfer, mirror fallback, and optional `SIZE`/`SHA256` checks to the
dependency-free `download.py` implementation, so the same integrity semantics
are used from every language.

For a direct file URL:

```text
python3 clients/download.py --url URL --output FILE
```

The C and Fortran programs are intentionally minimal and can be compiled with
the platform compiler. MATLAB/Octave and R call the same command from their
native functions. A tag-based download is available through `--tag TAG
--catalog Artifacts.yaml`; the catalog parser accepts the current `PATH`,
`URL`, `SIZE`, and `SHA256` fields.
