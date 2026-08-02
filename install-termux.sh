#!/usr/bin/env bash
set -e

echo "==> Updating Termux packages and installing base dependencies..."
pkg update && pkg upgrade -y
pkg install python curl git -y

WORK_DIR="$HOME/.hermes"
WHEELHOUSE_DIR="$WORK_DIR/wheelhouse"
VENV_DIR="$WORK_DIR/hermes-agent/venv"

mkdir -p "$WHEELHOUSE_DIR"

echo "==> Downloading latest Hermes Agent Termux wheelhouse..."
curl -L -o "$WORK_DIR/wheelhouse.tar.gz" https://github.com/vanta-jack/cryptography-48.0.1-termux/releases/latest/download/hermes-termux-wheelhouse.tar.gz
tar -xzf "$WORK_DIR/wheelhouse.tar.gz" -C "$WHEELHOUSE_DIR"

echo "==> Creating Python virtual environment at $VENV_DIR..."
python -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo "==> Installing Hermes Agent using pre-compiled Termux wheelhouse..."
pip install --no-index --find-links "$WHEELHOUSE_DIR" hermes-agent

echo "==> Hermes Agent installation complete!"
echo "==> Activate your environment with: source $VENV_DIR/bin/activate"
echo "==> Run 'hermes setup' to configure your agent."
