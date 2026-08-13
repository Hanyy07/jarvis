#!/usr/bin/env bash
# Repository bootstrap for the Jarvis AI Assistant.
# Runs after the repo is checked out. Must be idempotent.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Create the Python 3.11 virtualenv (pinned deps require CPython <= 3.11).
if [ ! -x ".venv/bin/python" ]; then
    python3.11 -m venv .venv
fi
# shellcheck disable=SC1091
source .venv/bin/activate

python -m pip install --upgrade pip
pip install -r requirements.txt
# Dev/test tooling that CI relies on.
pip install pytest flake8 ruff

# Make interactive/agent shells ready to run tests and the eel GUI app headlessly.
BASHRC="$HOME/.bashrc"
touch "$BASHRC"
add_line() { grep -qxF "$1" "$BASHRC" 2>/dev/null || printf '%s\n' "$1" >> "$BASHRC"; }
add_line '# --- Jarvis AI Assistant environment ---'
add_line 'export DISPLAY=:99'
add_line 'export SDL_AUDIODRIVER=dummy'
add_line "source \"$REPO_ROOT/.venv/bin/activate\""

echo "install.sh complete: Python $(python --version) venv ready at $REPO_ROOT/.venv"
