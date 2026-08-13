#!/usr/bin/env bash
# Repository bootstrap for the Jarvis AI Assistant Cloud Agent environment.
# Runs from /workspace after checkout (and whenever dependencies are
# refreshed). Must be idempotent and non-interactive.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# ---------------------------------------------------------------------------
# 1) System dependencies.
#    The app pins numpy==1.24.3 / opencv-python==4.8.1.78, which only publish
#    wheels up to CPython 3.11, so install Python 3.11 from the deadsnakes PPA
#    (the base image ships Python 3.12). Also install the native libraries the
#    Python packages need at import/runtime:
#      - portaudio19-dev / libasound2-dev : PyAudio
#      - libgl1 / libglib2.0-0            : OpenCV
#      - espeak                           : pyttsx3 text-to-speech
#      - python3.11-tk                    : Tk bindings imported by pyautogui
#      - xvfb / x11-utils / xauth / scrot : headless X display for pyautogui + eel
#      - ffmpeg                           : audio/codec support
# ---------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    software-properties-common ca-certificates gnupg
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    python3.11 python3.11-venv python3.11-dev python3.11-tk \
    portaudio19-dev libasound2-dev \
    libgl1 libglib2.0-0 \
    espeak \
    xvfb x11-utils xauth scrot \
    ffmpeg

# ---------------------------------------------------------------------------
# 2) Python virtualenv + dependencies.
# ---------------------------------------------------------------------------
if [ ! -x ".venv/bin/python" ]; then
    python3.11 -m venv .venv
fi
# shellcheck disable=SC1091
source .venv/bin/activate

python -m pip install --upgrade pip
pip install -r requirements.txt
# Dev/test tooling that CI relies on.
pip install pytest flake8 ruff

# ---------------------------------------------------------------------------
# 3) Make interactive/agent shells ready to run tests and the eel GUI app
#    headlessly (auto-activate the venv and point at the virtual display).
# ---------------------------------------------------------------------------
BASHRC="$HOME/.bashrc"
touch "$BASHRC"
add_line() { grep -qxF "$1" "$BASHRC" 2>/dev/null || printf '%s\n' "$1" >> "$BASHRC"; }
add_line '# --- Jarvis AI Assistant environment ---'
add_line 'export DISPLAY=:99'
add_line 'export SDL_AUDIODRIVER=dummy'
add_line "source \"$REPO_ROOT/.venv/bin/activate\""

echo "install.sh complete: $(python --version) venv ready at $REPO_ROOT/.venv"
