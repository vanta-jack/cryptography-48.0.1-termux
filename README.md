# Hermes Agent & Cryptography 48.0.1 for Termux

## Overview
This repository contains the build environment, GitHub Actions CI workflow, and single-line installer script to cross-compile Python `cryptography==48.0.1` and associated binary extensions for **Hermes Agent** on Termux (`aarch64-linux-android`).

## Background & Problem
Termux operates on a rolling package release model. Upstream Termux updated `python-cryptography` to version 50.0.0, introducing breaking changes and dropping legacy OpenSSL compatibility required by certain Python runtime environments and agent dependencies. Additionally, compiling `cryptography==48.0.1` or native Rust/C extensions directly on Android devices often fails due to missing headers or excessive compilation times.

## Solution Architecture
1. **Dockerized Cross-Builder**: Uses `termux/package-builder` on GitHub Actions ARM64 runners (`ubuntu-24.04-arm`) to compile binary `.whl` files compatible with Android Bionic libc and Python 3.11.
2. **Automated Releases**: The CI workflow dynamically pulls requirements from `NousResearch/Hermes-Agent` and publishes a `hermes-termux-wheelhouse.tar.gz` asset on GitHub Releases.
3. **One-Command Installer**: An `install-termux.sh` script downloads the pre-compiled wheelhouse and sets up an isolated Python `venv` on Termux without on-device compilation.

## Quick Installation on Termux
Run the following command inside Termux:

```bash
curl -fsSL https://raw.githubusercontent.com/vanta-jack/cryptography-48.0.1-termux/main/install-termux.sh | bash
```

## Repository Files
- [`Dockerfile`](file:///root/projects-proot/cryptography-48.0.1-termux/Dockerfile): Termux build container definition.
- [`.github/workflows/build-release.yml`](file:///root/projects-proot/cryptography-48.0.1-termux/.github/workflows/build-release.yml): GitHub Actions workflow for wheel compilation and release publishing.
- [`install-termux.sh`](file:///root/projects-proot/cryptography-48.0.1-termux/install-termux.sh): Automated installation script for Termux devices.
