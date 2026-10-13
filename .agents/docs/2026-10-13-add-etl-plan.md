# Add compat.etl

ETL 20.49.0 is a MIT-licensed header-only upstream release. A generated C
anchor gives mcpp a library target and exposes the original include directory.
The three platform entries share the pinned archive and SHA-256. No optional
compiled sources exist, so no sources-only features are advertised.

The GLOBAL URL is kept as a plain string; CN users fall back to upstream
until a byte-identical mirror is published. The example redirects compat to
this checkout and asserts fixed-capacity vector and queue ordering.

Local validation: mcpp 2026.10.1.2, gcc 16.1.0, `mcpp test -p etl`:
`test result ok. 1 passed; 0 failed`. The original LLVM CI failure belonged
to eui-neo-tray, which used setenv without stdlib.h; the follow-up includes
that declaration so the already selected CI member compiles correctly.
