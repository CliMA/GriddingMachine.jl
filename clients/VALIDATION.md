# Cross-language download validation

Validation date: 2026-09-25  
Platform: macOS arm64 (Darwin 25.3.0)  
Python: 3.9.6  
C compiler: Apple clang 21.0.0  
Fortran compiler: unavailable (`gfortran` is not installed)

The checked source was the working tree descended from commit `b815e84`
(`merge-cross-language-download-clients`). The C wrapper was compiled with:

```text
cc -Wall -Wextra -Werror clients/gm_download.c -o /tmp/gm_download_check
```

This compilation passed. The Python downloader passed syntax validation and
downloaded a temporary fixture through a `file://` URL with matching byte count
and SHA-256. The fixture contained 25 bytes and had SHA-256
`9e378b210b2885455454b3b73d8f7b831b82d6fa671aeac174fc940f382dc189`.

The C wrapper invocation was attempted with the same fixture and an output path
containing spaces, but the sandbox terminated the subprocess with `SIGKILL`
before a runtime result could be obtained. The local HTTP smoke test was also
blocked because the sandbox disallows binding a loopback listening socket.
Fortran compilation and runtime validation remain pending on a machine with
`gfortran`; no Fortran pass is claimed here.
