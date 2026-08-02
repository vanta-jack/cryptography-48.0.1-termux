#!/usr/bin/env bash
set -e

echo "==> Updating Termux package list and installing base dependencies..."
pkg update && pkg install python curl git -y

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
INSTALL_DIR="$HERMES_HOME/hermes-agent"
WHEELHOUSE_DIR="$HERMES_HOME/wheelhouse"
VENV_DIR="$INSTALL_DIR/venv"

mkdir -p "$WHEELHOUSE_DIR"

echo "==> Downloading pre-compiled Hermes Agent Termux wheelhouse..."
curl -L -o "$HERMES_HOME/wheelhouse.tar.gz" https://github.com/vanta-jack/cryptography-48.0.1-termux/releases/latest/download/hermes-termux-wheelhouse.tar.gz
tar -xzf "$HERMES_HOME/wheelhouse.tar.gz" -C "$WHEELHOUSE_DIR"

if [ -d "$INSTALL_DIR" ] && [ -d "$INSTALL_DIR/.git" ]; then
    echo "==> Existing installation found at $INSTALL_DIR, updating repository..."
    cd "$INSTALL_DIR"
    git fetch origin main || true
    git checkout main 2>/dev/null || true
    git pull --ff-only origin main 2>/dev/null || git reset --hard origin/main 2>/dev/null || true
else
    echo "==> Cloning Hermes Agent repository to $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR"
    git clone --depth 1 https://github.com/NousResearch/hermes-agent.git "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

echo "==> Patching pyproject.toml for Termux Python 3.14 compatibility..."
if [ -f "$INSTALL_DIR/pyproject.toml" ]; then
    sed -i 's/<3\.14/<3.15/g' "$INSTALL_DIR/pyproject.toml" || true
fi

if [ ! -d "$VENV_DIR" ]; then
    echo "==> Creating Python virtual environment at $VENV_DIR..."
    python -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

echo "==> Pre-installing cryptography 48.0.1 from pre-compiled wheelhouse..."
pip install --upgrade pip setuptools wheel
pip install --find-links "$WHEELHOUSE_DIR" cryptography==48.0.1

echo "==> Installing Hermes Agent using pre-compiled Termux wheelhouse..."
if [ -f constraints-termux.txt ]; then
    pip install --find-links "$WHEELHOUSE_DIR" -e '.[termux]' -c constraints-termux.txt || pip install --find-links "$WHEELHOUSE_DIR" -e '.'
else
    pip install --find-links "$WHEELHOUSE_DIR" -e '.'
fi

echo "==> Hermes Agent installation complete!"
echo "==> Activate your environment with: source $VENV_DIR/bin/activate"
echo "==> Run 'hermes setup' to configure your agent."
