# Hermes Agent Termux Pre-Compiled Wheelhouse (Python 3.14 & cryptography 48.0.1)

[![Build Hermes Termux Wheelhouse Release](https://github.com/vanta-jack/cryptography-48.0.1-termux/actions/workflows/build-release.yml/badge.svg)](https://github.com/vanta-jack/cryptography-48.0.1-termux/actions/workflows/build-release.yml)
[![Release](https://img.shields.io/github/v/release/vanta-jack/cryptography-48.0.1-termux?include_prereleases&label=release)](https://github.com/vanta-jack/cryptography-48.0.1-termux/releases/tag/0.19.1)

This repository provides pre-compiled Python 3.14 binary wheels (`android_24_arm64_v8a`), automated installation scripts, and automated test suites for running [NousResearch Hermes Agent](https://github.com/NousResearch/hermes-agent) on **Termux / ARM64 Android** without requiring slow or error-prone on-device C/Rust compilation.

---

## Quick Start: Single-Command Termux Installation

Run the following command directly in your Termux shell:

```bash
curl -fsSL https://raw.githubusercontent.com/vanta-jack/cryptography-48.0.1-termux/main/install-termux.sh | bash
```

### What `install-termux.sh` Does Automatically
1. Downloads the pre-compiled **127 MiB Wheelhouse Archive** (`hermes-termux-wheelhouse.tar.gz`) from GitHub Releases (`0.19.1` / `latest`).
2. Patches `pyproject.toml` (`<3.15`) and `hermes_cli/main.py` (`PROJECT_ROOT` resolution) for Termux Python 3.14 compatibility.
3. Pre-installs pre-compiled `cryptography 48.0.1` and `cffi` without contacting PyPI.
4. Applies Nous Research's `psutil` Android compatibility shim (`install_psutil_android.py`).
5. Symlinks `$VENV_DIR/bin/hermes` to `$PREFIX/bin/hermes` so `hermes` is immediately executable from any shell prompt.

---

## Core Architecture: `gh-actions-wheelhouse-builder`

Compiling heavy C and Rust extensions (`cryptography`, `maturin`, `cffi`, `psutil`) natively on Termux is constrained by Android Bionic libc, emulation tax, and Rust `rlib` build isolation targets.

This project offloads all compilation to **GitHub Actions ARM64 host runners** (`ubuntu-24.04-arm`):
- **Wheel Retagging**: Converts compiled Linux wheels to `android_24_arm64_v8a` platform tags so `pip` on Termux accepts them natively.
- **Automated CI Testing**: Runs `pytest tests/test_wheelhouse.py` in GitHub Actions prior to publishing releases.

---

## Repository Documentation & Agent Skills

- [`AGENTS.md`](file://AGENTS.md): Repository agent instructions focused on codebase architecture, CI pipelines, and Termux Bionic libc compatibility rules.
- [`.agent/skills/gh-actions-wheelhouse-builder/SKILL.md`](file://.agent/skills/gh-actions-wheelhouse-builder/SKILL.md): Core skill for building, retagging, and releasing Termux wheelhouses.
- [`.agent/skills/termux-proot-ssh-bridge/SKILL.md`](file://.agent/skills/termux-proot-ssh-bridge/SKILL.md): Utility skill for proot-to-host Termux SSH debugging (`127.0.0.1:8022`).
- [`MAINTENANCE.md`](file://MAINTENANCE.md): Maintainer guide for future Hermes Agent release upgrades (`0.20.0+`).
- [`tests/test_wheelhouse.py`](file://tests/test_wheelhouse.py): Automated pytest test suite.
- [`tests/check_termux_health.sh`](file://tests/check_termux_health.sh): Client-side 5-second Termux health check script.

---

## Post-Installation Usage

After installation completes, run:

```bash
hermes setup
```

To run diagnostics:

```bash
hermes doctor
```
