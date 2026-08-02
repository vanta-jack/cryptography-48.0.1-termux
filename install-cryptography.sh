#!/usr/bin/env bash
set -e

echo "==> Installing cryptography for Termux..."

WHEELHOUSE_DIR="${HOME}/.cryptography-wheelhouse"
mkdir -p "$WHEELHOUSE_DIR"

echo "==> Downloading cryptography wheelhouse release..."
curl -L -o "$WHEELHOUSE_DIR/wheelhouse.tar.gz" https://github.com/vanta-jack/cryptography-48.0.1-termux/releases/latest/download/cryptography-48.0.1-termux-wheelhouse.tar.gz 2>/dev/null || true
tar -xzf "$WHEELHOUSE_DIR/wheelhouse.tar.gz" -C "$WHEELHOUSE_DIR" 2>/dev/null || true

echo "==> Installing cryptography and cffi..."
pkg install python-cryptography python-cffi -y 2>/dev/null || true
python3 -m pip install --find-links "$WHEELHOUSE_DIR" cryptography cffi 2>/dev/null || true

# Apply patchelf dynamic linker fix if needed
CRYPT_SO=$(find /data/data/com.termux/files/usr/lib/python3.*/site-packages/cryptography -name "_rust*.so" 2>/dev/null | head -n 1)
if [ -n "$CRYPT_SO" ]; then
    patchelf --replace-needed libgcc_s.so.1 libc.so --replace-needed libc.so.6 libc.so --add-needed libpython3.14.so "$CRYPT_SO" 2>/dev/null || true
fi

python3 -c "import cryptography; from cryptography.hazmat.primitives import hashes; print('✓ cryptography successfully installed and verified on Termux!')"
