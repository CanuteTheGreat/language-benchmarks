# One image with every toolchain, so all languages are built and run the same way.
# Arch Linux is used because it ships the latest stable release of each toolchain.
FROM docker.io/library/archlinux:latest

RUN pacman -Syu --noconfirm --needed \
      base-devel gcc clang lld llvm \
      rust go jdk-openjdk nodejs \
      python pypy3 php uv icu krb5 libunwind \
      gmp pcre2 cjson nlohmann-json \
      hyperfine time git curl jq xz zstd python-matplotlib \
 && pacman -Scc --noconfirm

# CPython: Arch still ships 3.14; install the latest stable 3.15.x as a python-build-standalone
# build (PGO+LTO, the same builds uv uses) and make it the default python3.
RUN set -eux; export UV_PYTHON_INSTALL_DIR=/opt/uv-python; \
    uv python install 3.15; \
    py=$(uv python find 3.15); ln -sf "$py" /usr/local/bin/python3; ln -sf "$py" /usr/local/bin/python; \
    python3 --version | grep -q '^Python 3.15'

# .NET: Arch still ships 10.0; install the latest stable SDK (11.0) with Microsoft's installer.
RUN set -eux; curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/di.sh; \
    bash /tmp/di.sh --channel 11.0 --quality ga --install-dir /opt/dotnet; rm /tmp/di.sh; \
    ln -sf /opt/dotnet/dotnet /usr/local/bin/dotnet; dotnet --version | grep -q '^11\.'
ENV DOTNET_ROOT=/opt/dotnet

# Zig: official release tarball (latest stable from ziglang.org's index)
RUN set -eux; \
    ver=$(curl -fsSL https://ziglang.org/download/index.json | jq -r 'keys[] | select(. != "master")' | sort -V | tail -1); \
    url=$(curl -fsSL https://ziglang.org/download/index.json | jq -r --arg v "$ver" '.[$v]["x86_64-linux"].tarball'); \
    sha=$(curl -fsSL https://ziglang.org/download/index.json | jq -r --arg v "$ver" '.[$v]["x86_64-linux"].shasum'); \
    curl -fsSL "$url" -o /tmp/zig.tar.xz; echo "$sha  /tmp/zig.tar.xz" | sha256sum -c -; \
    mkdir -p /opt/zig && tar -xJf /tmp/zig.tar.xz -C /opt/zig --strip-components=1 && rm /tmp/zig.tar.xz; \
    ln -s /opt/zig/zig /usr/local/bin/zig

# PHP: enable the bundled gmp extension; opcache/JIT is switched on per run with -d flags.
RUN set -eux; ini=/etc/php/php.ini; \
    sed -i 's/^;extension=gmp/extension=gmp/' $ini; \
    if [ -f /usr/lib/php/modules/opcache.so ]; then sed -i 's/^;zend_extension=opcache/zend_extension=opcache/' $ini; fi; \
    sed -i 's/^memory_limit = .*/memory_limit = -1/' $ini; \
    php -m | grep -qi gmp

# Java: Jackson for the JSON benchmark (Java has no JSON parser in the standard library)
RUN set -eux; mkdir -p /opt/java-libs; cd /opt/java-libs; \
    v=$(curl -fsSL https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/maven-metadata.xml | grep -oP '(?<=<release>)[^<]+'); \
    for a in jackson-core jackson-databind jackson-annotations; do \
      av=$v; if [ $a = jackson-annotations ]; then av=${v%.*}; curl -fsI https://repo1.maven.org/maven2/com/fasterxml/jackson/core/$a/$av/$a-$av.jar >/dev/null || av=$v; fi; \
      curl -fsSLO https://repo1.maven.org/maven2/com/fasterxml/jackson/core/$a/$av/$a-$av.jar; done; ls -l

# Rust: pre-fetch the crates the implementations use so builds run offline
COPY rust-seed /opt/rust-seed
ENV CARGO_HOME=/opt/cargo
RUN cd /opt/rust-seed && cargo fetch && cargo build --release && rm -rf target

# .NET: warm the SDK (first-run setup) so build timings don't include it
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 NUGET_PACKAGES=/opt/nuget
COPY dotnet-seed /opt/dotnet-seed
RUN cd /opt/dotnet-seed && dotnet publish -c Release -o /tmp/ds && rm -rf /tmp/ds bin obj

# Go: no module downloads needed (standard library only)
ENV GOFLAGS=-mod=mod GOAMD64=v3 GOTOOLCHAIN=local GOCACHE=/tmp/gocache

COPY measure.c /opt/measure.c
RUN gcc -O2 -o /usr/local/bin/measure /opt/measure.c

RUN pacman -S --noconfirm --needed tokei openmp && pacman -Scc --noconfirm

COPY versions.sh /usr/local/bin/versions.sh
RUN chmod +x /usr/local/bin/versions.sh && versions.sh
WORKDIR /bench
