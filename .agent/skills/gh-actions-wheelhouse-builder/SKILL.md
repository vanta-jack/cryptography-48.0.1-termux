---
name: gh-actions-wheelhouse-builder
description: Guide and instructions for leveraging GitHub Actions ARM64 runners to pre-compile, retag (android_24_arm64_v8a), test, and release Python binary wheelhouses for Termux / ARM64 Android.
---

# GH-Actions Wheelhouse Builder Skill

The **`gh-actions-wheelhouse-builder`** skill defines the core architecture for offloading C and Rust binary wheel compilation to cloud-hosted GitHub Actions runners (`ubuntu-24.04-arm`).

---

## CRITICAL: Version Freshness & Maintenance Directive

> [!WARNING]
> Hardcoded version pins (currently **Hermes Agent `0.19.1`**, **`cryptography==48.0.1`**, and **Python `<3.15`**) WILL BECOME STALE when Nous Research releases newer versions (e.g. `0.20.0`, `0.21.0`).
>
> **Mandatory Agent Directive**:
> Whenever upgrading or modifying this repository for future releases:
> 1. Audit `pyproject.toml` in `NousResearch/hermes-agent` for updated dependency versions.
> 2. Update the target version pins in `.github/workflows/build-release.yml`, `install-termux.sh`, and `tests/test_wheelhouse.py`.
> 3. Update the version numbers recorded in THIS skill file (`.agent/skills/gh-actions-wheelhouse-builder/SKILL.md`) to keep the skill fresh and accurate.

---

## Core Workflow Steps

### 1. GitHub Actions Host Runner Configuration
Use native ARM64 runners (`runs-on: ubuntu-24.04-arm`) with system build headers:
```yaml
- name: Install system dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y libssl-dev libffi-dev pkg-config clang rustc cargo
```

### 2. Wheelhouse Building
Build wheels for Python 3.14 with `HERMES_NIX_BUILD=1` override:
```bash
pip install --upgrade pip setuptools wheel setuptools-rust maturin pytest
pip wheel --wheel-dir wheelhouse cryptography==48.0.1
pip wheel --wheel-dir wheelhouse -r hermes/requirements.txt || true
pip wheel --wheel-dir wheelhouse ./hermes || true
```

### 3. Wheel Platform Retagging for Termux Bionic libc
Retag Linux wheels (`manylinux_2_34_aarch64`) with Android Bionic platform tags:
```bash
pip install wheel
for w in wheelhouse/*.whl; do
  if [ -f "$w" ]; then
    python -m wheel tags --platform-tag android_24_arm64_v8a "$w" 2>/dev/null || true
    python -m wheel tags --platform-tag linux_aarch64 "$w" 2>/dev/null || true
  fi
done
```

### 4. Automated Pre-Deployment Testing
Run `pytest tests/test_wheelhouse.py` inside the CI test environment to verify zero `libgcc_s.so.1` or `NotImplementedError` issues before release.

### 5. GitHub Release Publication
Publish `hermes-termux-wheelhouse.tar.gz` to GitHub Releases using `softprops/action-gh-release@v2` under tags `latest` and `0.19.1`.
