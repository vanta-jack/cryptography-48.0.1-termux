# Repository Maintenance Guide

This document provides instructions for maintainers and AI agents updating this repository for future Hermes Agent releases (e.g. `0.20.0`, `0.21.0`).

---

## Upstream Hermes Agent Release Upgrade Procedure

When Nous Research releases a new version of `hermes-agent`:

1. **Update Dependency Pins & Version Matrices**:
   - Inspect `pyproject.toml` in `NousResearch/hermes-agent`.
   - Update `.github/workflows/build-release.yml` with the new target release tag name.
   - Update `.agent/skills/gh-actions-wheelhouse-builder/SKILL.md` to reflect the new release version.

2. **Trigger GitHub Actions Wheelhouse Rebuild**:
   - Push updates to `main` branch.
   - GitHub Actions workflow `build-release.yml` will automatically compile wheels on `ubuntu-24.04-arm`, apply `android_24_arm64_v8a` platform tags, execute `pytest tests/test_wheelhouse.py`, and update the `latest` GitHub Release asset.

3. **Tag Git Release**:
   - Create a Git tag matching the Hermes Agent version:
     ```bash
     git tag 0.20.0
     git push origin 0.20.0
     ```

4. **Verify Client Installation**:
   - Run `tests/check_termux_health.sh` or execute `hermes doctor` over SSH on a Termux device.
