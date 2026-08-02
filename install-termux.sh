#!/usr/bin/env bash
set -e

echo "==> Updating Termux package list and installing base dependencies..."
pkg update && pkg install python curl git clang rust make pkg-config libffi openssl ca-certificates -y

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
INSTALL_DIR="$HERMES_HOME/hermes-agent"
WHEELHOUSE_DIR="$HERMES_HOME/wheelhouse"
VENV_DIR="$INSTALL_DIR/venv"

mkdir -p "$WHEELHOUSE_DIR"

echo "==> Downloading pre-compiled Hermes Agent Termux wheelhouse (100% Binary Coverage)..."
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

echo "==> Patching pyproject.toml and hermes_cli for Termux Python 3.14 compatibility..."
if [ -f "$INSTALL_DIR/pyproject.toml" ]; then
    sed -i 's/<3\.14/<3.15/g' "$INSTALL_DIR/pyproject.toml" || true
fi

if [ -f "$INSTALL_DIR/hermes_cli/main.py" ]; then
    sed -i 's/print(f"Install directory: {PROJECT_ROOT}")/project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))\n    print(f"Install directory: {project_root}")/g' "$INSTALL_DIR/hermes_cli/main.py" || true
fi

if [ ! -d "$VENV_DIR" ]; then
    echo "==> Creating Python virtual environment at $VENV_DIR..."
    python -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

echo "==> Pre-installing all pre-compiled C/Rust binary extensions from wheelhouse..."
pip install --upgrade pip setuptools wheel
pip install --find-links "$WHEELHOUSE_DIR" cryptography==48.0.1 pydantic-core jiter tiktoken cffi psutil multidict yarl frozenlist || true

echo "==> Pre-building Android psutil compatibility shim..."
if [ -f "$INSTALL_DIR/scripts/install_psutil_android.py" ]; then
    python "$INSTALL_DIR/scripts/install_psutil_android.py" --pip "$VENV_DIR/bin/python -m pip" || true
fi

echo "==> Installing Hermes Agent using pre-compiled Termux wheelhouse..."
if [ -f constraints-termux.txt ]; then
    pip install --find-links "$WHEELHOUSE_DIR" -e '.[termux]' -c constraints-termux.txt || pip install --find-links "$WHEELHOUSE_DIR" -e '.'
else
    pip install --find-links "$WHEELHOUSE_DIR" -e '.'
fi

echo "==> Linking hermes executable to $PREFIX/bin/hermes for immediate shell access..."
ln -sf "$VENV_DIR/bin/hermes" "$PREFIX/bin/hermes" 2>/dev/null || mkdir -p "$HOME/.local/bin" && ln -sf "$VENV_DIR/bin/hermes" "$HOME/.local/bin/hermes" 2>/dev/null || true

echo "==> Hermes Agent installation complete!"
echo "==> Activate your environment with: source $VENV_DIR/bin/activate"
echo "==> Run 'hermes setup' to configure your agent."
