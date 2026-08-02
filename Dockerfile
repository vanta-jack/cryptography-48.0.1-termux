FROM termux/package-builder:latest

# Install Rust toolchain, C compiler, and Python 3.11 development dependencies
RUN apt-get update && apt-get install -y \
    rustc \
    cargo \
    clang \
    python3.11 \
    python3.11-dev \
    python3-pip \
    git \
    libssl-dev \
    libffi-dev

WORKDIR /build
