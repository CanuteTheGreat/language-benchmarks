#!/bin/sh
# Disk size of what each language needs installed at run time, inside the benchmark image.
# (Compiled C/C++/Rust/Zig/Go programs need only libc/libstdc++/libm, listed for reference.)
#   docker run --rm langbench:dev sh harness/runtime-sizes.sh
s() { printf '%s\t%s\n' "$1" "$(du -sb "$2" 2>/dev/null | cut -f1)"; }
s "java: JDK (as installed)" "$(readlink -f /usr/lib/jvm/default-runtime)"
s "dotnet: shared runtime only (Microsoft.NETCore.App)" /opt/dotnet/shared/Microsoft.NETCore.App
s "dotnet: SDK + runtime" /opt/dotnet
s "node: binary" "$(readlink -f "$(command -v node)")"
s "python: CPython install" "$(dirname "$(dirname "$(readlink -f "$(command -v python3)")")")"
s "pypy: install" /opt/pypy3
s "php: binary" "$(readlink -f "$(command -v php)")"
s "php: extensions dir" /usr/lib/php
s "libc.so.6" "$(readlink -f /usr/lib/libc.so.6)"
s "libstdc++.so.6" "$(readlink -f /usr/lib/libstdc++.so.6)"
s "libm.so.6" "$(readlink -f /usr/lib/libm.so.6)"
