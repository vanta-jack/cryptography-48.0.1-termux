# Cryptography 48.0.1 Termux Pre-Compiled Wheelhouse (Python 3.14 / ARM64 Android)

[![Build Cryptography 48.0.1 Termux Release](https://github.com/vanta-jack/cryptography-48.0.1-termux/actions/workflows/build-release.yml/badge.svg)](https://github.com/vanta-jack/cryptography-48.0.1-termux/actions/workflows/build-release.yml)
[![Release](https://img.shields.io/github/v/release/vanta-jack/cryptography-48.0.1-termux?include_prereleases&label=release)](https://github.com/vanta-jack/cryptography-48.0.1-termux/releases/tag/latest)

This repository provides pre-compiled Python 3.14 binary wheels (`android_24_arm64_v8a`) for **`cryptography 48.0.1`** on **Termux / ARM64 Android** without requiring slow or error-prone on-device C/Rust compilation.

---

## Quick Start: Single-Command Termux Installation

Run the following command directly in your Termux shell:

```bash
curl -fsSL https://raw.githubusercontent.com/vanta-jack/cryptography-48.0.1-termux/main/install-cryptography.sh | bash
```

### What `install-cryptography.sh` Does Automatically
1. Downloads the pre-compiled **`cryptography 48.0.1` wheelhouse archive** (`cryptography-48.0.1-termux-wheelhouse.tar.gz`) from GitHub Releases.
2. Pre-installs `cryptography 48.0.1` and `cffi` into your Termux Python environment instantly without contacting PyPI or building from source.
3. Runs a verification import check (`from cryptography.hazmat.primitives import hashes`).

---

## Direct Wheel Download

You can also download the individual wheel file directly from GitHub Releases:
- [`cryptography-48.0.1-cp311-abi3-android_24_arm64_v8a.whl`](https://github.com/vanta-jack/cryptography-48.0.1-termux/releases/latest)

Then install it manually with:
```bash
pip install cryptography-48.0.1-cp311-abi3-android_24_arm64_v8a.whl
```

---

## Core Architecture

Building `cryptography 48.0.1` natively on Termux fails due to missing Rust `rlib` targets inside pip's build isolation subshells. 

This repository offloads compilation to **GitHub Actions ARM64 host runners** (`ubuntu-24.04-arm`), retags compiled wheels for `android_24_arm64_v8a`, and publishes pre-compiled binary wheels for instant Termux installation.

---

## Archived Code

Experimental build scripts and full Hermes Agent installers have been archived under the [`legacy/`](file://legacy/) directory.
