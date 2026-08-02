# Cryptography 48.0.1 for Termux

## Overview
This repository contains the build scripts and GitHub Actions workflow configuration to compile Python `cryptography` version 48.0.1 specifically for Termux on Android.

## Background & Intent
Termux operates on a rolling release package model (`pkg update` / `pkg upgrade`). The official Termux repository was updated to `cryptography` version 50.0.0, introducing breaking changes and dropping legacy OpenSSL compatibility. Because Termux no longer provides pre-compiled legacy `.deb` packages for version 48.0.1, this project sets up a dedicated build environment to cross-compile or natively package `cryptography` 48.0.1 for `aarch64-linux-android`.

## Objectives
- Build `cryptography==48.0.1` wheel/package targeted for Android (`aarch64`).
- Maintain compatibility with existing Python runtime requirements on Termux.
- Automate binary generation via GitHub Actions runners.
