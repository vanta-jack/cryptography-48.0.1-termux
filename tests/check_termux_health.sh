#!/usr/bin/env bash
set -e

echo "==> Running Termux Hermes Health Check..."

VENV_PYTHON="$HOME/.hermes/hermes-agent/venv/bin/python"
VENV_HERMES="$HOME/.hermes/hermes-agent/venv/bin/hermes"

if [ ! -f "$VENV_PYTHON" ]; then
    echo "ERROR: Virtual environment python not found at $VENV_PYTHON"
    exit 1
fi

"$VENV_PYTHON" -c "
import cryptography
import psutil
import cffi
import openai
import hermes_cli
print('✓ All core binary modules imported successfully!')
"

if [ -f "$VENV_HERMES" ]; then
    "$VENV_HERMES" --version
fi

echo "✓ Health check passed! Hermes is ready for use."
