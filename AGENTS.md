# Agent Guidelines for Hermes Agent Termux Build Repository

Welcome to the **Hermes Agent Termux Build System** repository. This repository provides pre-compiled Python 3.14 binary wheels, automated installation scripts, and testing suites for running [NousResearch Hermes Agent](https://github.com/NousResearch/hermes-agent) on ARM64 Android / Termux.

---

## Core Architecture: `gh-actions-wheelhouse-builder`

The primary theme and capability of this repository is the **`gh-actions-wheelhouse-builder`** workflow.

### Architectural Rules for Agents
1. **Never Attempt On-Device Compilation for Heavy Extensions**: Compiling C and Rust extensions (`cryptography`, `maturin`, `cffi`, `psutil`) natively on Termux is constrained by Android Bionic libc, emulation tax, and missing Rust `rlib` build isolation targets. Always offload compilation to the GitHub Actions workflow (`.github/workflows/build-release.yml`).
2. **Platform Tag Matching (`android_24_arm64_v8a`)**: Wheels built on Linux host runners (`ubuntu-24.04-arm`) carry `manylinux_2_34_aarch64` platform tags. `pip` on Termux Android rejects `manylinux` tags because Termux uses Bionic libc instead of glibc. Always execute `python -m wheel tags --platform-tag android_24_arm64_v8a` on compiled wheels before publishing releases.
3. **Python Version Constraint Patching**: Termux Python is version 3.14. Always apply `sed -i 's/<3\.14/<3.15/g' pyproject.toml` to allow Hermes installation under Python 3.14.
4. **Android Compatibility Shims**: Always run `python scripts/install_psutil_android.py` during installation to resolve `NotImplementedError: platform android is not supported` in `psutil`.

---

## Repository Structure

- [`.github/workflows/build-release.yml`](file://.github/workflows/build-release.yml): GitHub Actions pipeline running on `ubuntu-24.04-arm` host runner to pre-compile wheels, retag platform tags, run pytest suites, and publish GitHub Releases (`latest` and `0.19.1`).
- [`install-termux.sh`](file://install-termux.sh): Single-command client installation script that fetches the 127 MiB pre-compiled wheelhouse, patches `pyproject.toml` and `hermes_cli/main.py`, applies the `psutil` Android shim, and symlinks `$PREFIX/bin/hermes`.
- [`tests/test_wheelhouse.py`](file://tests/test_wheelhouse.py): Automated pytest suite validating binary module imports (`cryptography`, `cffi`, `psutil`, `openai`) and `hermes` CLI execution.
- [`tests/check_termux_health.sh`](file://tests/check_termux_health.sh): Fast 5-second health check script for client Termux environments.
- [`.agent/skills/gh-actions-wheelhouse-builder/SKILL.md`](file://.agent/skills/gh-actions-wheelhouse-builder/SKILL.md): Core skill for building, retagging, and releasing Termux wheelhouses in GitHub Actions.
- [`.agent/skills/termux-proot-ssh-bridge/SKILL.md`](file://.agent/skills/termux-proot-ssh-bridge/SKILL.md): Secondary utility skill for proot-to-host SSH debugging.

---

## Secondary Utility: Proot-to-Host SSH Bridge Protocol ("SSH Party Trick")

When operating inside a `proot-distro` container (such as Ubuntu on Termux), agents can inspect and manage the native Termux host environment via SSH:

### Connection Parameters
- **Target Host**: `127.0.0.1`
- **Target Port**: `8022` (Termux default `sshd` port)
- **Private Key**: Provided in temporary storage (e.g. `/tmp/id_ed25519` with permissions `600`).
- **Execution Command Pattern**:
  ```bash
  ssh -i /tmp/id_ed25519 -p 8022 -o StrictHostKeyChecking=no 127.0.0.1 "export PATH=\$PATH:\$HOME/.local/bin:\$HOME/.hermes/hermes-agent/venv/bin; hermes doctor"
  ```

---

## Verification Protocols

Before declaring any release or code change successful:
1. Run `pytest tests/test_wheelhouse.py` in CI.
2. Verify `gh release view latest` shows the 127 MiB release asset.
3. Test `hermes --version` and `hermes doctor` over SSH on the host Termux environment.
