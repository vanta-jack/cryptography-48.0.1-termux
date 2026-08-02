#!/usr/bin/env bash
set -e

echo "==> Installing pre-compiled cryptography 48.0.1 wheel for Termux..."

WHEELHOUSE_DIR="${HOME}/.cryptography-wheelhouse"
mkdir -p "$WHEELHOUSE_DIR"

echo "==> Downloading cryptography 48.0.1 wheelhouse release..."
curl -L -o "$WHEELHOUSE_DIR/wheelhouse.tar.gz" https://github.com/vanta-jack/cryptography-48.0.1-termux/releases/latest/download/cryptography-48.0.1-termux-wheelhouse.tar.gz
tar -xzf "$WHEELHOUSE_DIR/wheelhouse.tar.gz" -C "$WHEELHOUSE_DIR"

echo "==> Installing build dependencies (patchelf & libffi)..."
pkg install patchelf libffi -y 2>/dev/null || true

echo "==> Installing cryptography 48.0.1 wheel..."
python3 -m pip install --force-reinstall --no-deps --find-links "$WHEELHOUSE_DIR" cryptography==48.0.1 cffi

echo "==> Applying Android Bionic dynamic linker patch..."
CRYPT_SO=$(find /data/data/com.termux/files/usr/lib/python3.*/site-packages/cryptography -name "_rust*.so" 2>/dev/null | head -n 1)
if [ -n "$CRYPT_SO" ]; then
    patchelf --replace-needed libgcc_s.so.1 libc.so --replace-needed libc.so.6 libc.so --add-needed libpython3.14.so "$CRYPT_SO" 2>/dev/null || true
fi

echo "==> Verifying cryptography 48.0.1 installation..."
python3 -c "import cryptography; assert cryptography.__version__ == '48.0.1', f'Expected 48.0.1, got {cryptography.__version__}'; from cryptography.hazmat.primitives import hashes; digest = hashes.Hash(hashes.SHA256()); digest.update(b'termux'); print('✓ SUCCESS: cryptography', cryptography.__version__, 'installed and verified cleanly on Termux!')"
