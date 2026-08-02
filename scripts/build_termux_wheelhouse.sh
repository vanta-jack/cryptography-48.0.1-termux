#!/bin/sh
set -e

export ANDROID_API_LEVEL=24

pkg update -y
pkg install -y python rust clang libffi openssl patchelf tar git make pkg-config python-psutil autoconf automake libtool zip

echo "==> Python version: $(python3 --version)"
mkdir -p ~/build_whl

python3 -m pip install --upgrade pip setuptools wheel setuptools-rust maturin cffi

echo "==> Building binary extension wheels..."
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl cryptography==48.0.1
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl cffi
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl pydantic-core
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl jiter
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl tiktoken
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl multidict
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl yarl
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl frozenlist
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl propcache
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl uvloop || echo "WARNING: uvloop build failed (optional), skipping"
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl watchfiles
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl 'ruamel.yaml.clib'
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl pyyaml
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl httptools
python3 -m pip wheel --no-deps --wheel-dir ~/build_whl MarkupSafe

echo "==> Retagging all binary wheels to android_24_arm64_v8a..."
cd ~/build_whl
for w in *.whl; do
  case "$w" in
    *cp314*|*abi3*|*aarch64*)
      python3 -m wheel tags --platform-tag android_24_arm64_v8a "$w" 2>/dev/null || true
      rm -f "$w"
      ;;
  esac
done

echo "==> Packaging psutil from Termux system pkg into wheel..."
PSUTIL_VERSION=$(python3 -c 'import psutil; print(psutil.__version__)')
PSUTIL_LOC=$(python3 -c 'import psutil, os; print(os.path.dirname(psutil.__file__))')
PSUTIL_TAG="psutil-${PSUTIL_VERSION}-cp314-cp314-android_24_arm64_v8a"

mkdir -p "$HOME/psutil_wheel/psutil"
cp -r "${PSUTIL_LOC}/"* "$HOME/psutil_wheel/psutil/"

mkdir -p "$HOME/psutil_wheel/${PSUTIL_TAG}.dist-info"

printf 'Wheel-Version: 1.0\nGenerator: manual\nRoot-Is-Purelib: false\nTag: cp314-cp314-android_24_arm64_v8a\n' \
  > "$HOME/psutil_wheel/${PSUTIL_TAG}.dist-info/WHEEL"

printf "Metadata-Version: 2.1\nName: psutil\nVersion: ${PSUTIL_VERSION}\n" \
  > "$HOME/psutil_wheel/${PSUTIL_TAG}.dist-info/METADATA"

cd "$HOME/psutil_wheel"
zip -r ~/build_whl/${PSUTIL_TAG}.whl psutil "${PSUTIL_TAG}.dist-info" || \
  python3 -c "
import zipfile, os, glob
whl = os.path.expanduser('~/build_whl/${PSUTIL_TAG}.whl')
with zipfile.ZipFile(whl, 'w', zipfile.ZIP_DEFLATED) as z:
    for f in glob.glob('psutil/**', recursive=True):
        if os.path.isfile(f): z.write(f)
    tag = '${PSUTIL_TAG}.dist-info'
    for f in glob.glob(tag + '/**', recursive=True):
        if os.path.isfile(f): z.write(f)
print('psutil wheel created via python zipfile:', whl)
"

echo "==> Final wheelhouse:"
ls -lah ~/build_whl/
cp -f ~/build_whl/*.whl /workspace/wheelhouse/
