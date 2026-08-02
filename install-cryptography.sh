#!/usr/bin/env bash
set -e

echo "==> Installing pre-compiled cryptography 48.0.1 wheel for Termux..."

WHEELHOUSE_DIR="${HOME}/.cryptography-wheelhouse"
mkdir -p "$WHEELHOUSE_DIR"

echo "==> Downloading cryptography 48.0.1 wheelhouse release..."
curl -L -o "$WHEELHOUSE_DIR/wheelhouse.tar.gz" https://github.com/vanta-jack/cryptography-48.0.1-termux/releases/latest/download/cryptography-48.0.1-termux-wheelhouse.tar.gz
tar -xzf "$WHEELHOUSE_DIR/wheelhouse.tar.gz" -C "$WHEELHOUSE_DIR"

echo "==> Installing cryptography 48.0.1..."
python -m pip install --force-reinstall --find-links "$WHEELHOUSE_DIR" cryptography==48.0.1 cffi --no-index

python -c "import cryptography; from cryptography.hazmat.primitives import hashes; print('✓ cryptography 48.0.1 successfully installed and verified!')"
