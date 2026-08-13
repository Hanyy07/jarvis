FROM ubuntu:24.04

# Base image for the Jarvis AI Assistant Cloud Agent environment.
#
# The application pins numpy==1.24.3 and opencv-python==4.8.1.78, which only
# publish wheels up to CPython 3.11, so we install Python 3.11 from the
# deadsnakes PPA rather than relying on Ubuntu 24.04's default Python 3.12.

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONUNBUFFERED=1

# 1) Tooling needed to add the deadsnakes PPA and install Chrome's apt repo.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        software-properties-common \
        ca-certificates \
        curl \
        gnupg \
        git \
        sudo \
        wget \
    && rm -rf /var/lib/apt/lists/*

# 2) Python 3.11 (deadsnakes) plus the system libraries the Python
#    dependencies require:
#      - portaudio19-dev / libasound2-dev : PyAudio (microphone / audio streams)
#      - libgl1 / libglib2.0-0            : OpenCV runtime
#      - espeak                           : pyttsx3 text-to-speech on Linux
#      - python3.11-tk                    : Tk bindings imported by pyautogui/mouseinfo
#      - xvfb / x11-utils / xauth / scrot : headless X display for pyautogui + the eel browser
#      - ffmpeg                           : audio/codec support
RUN add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        python3.11 \
        python3.11-venv \
        python3.11-dev \
        python3.11-tk \
        portaudio19-dev \
        libasound2-dev \
        libgl1 \
        libglib2.0-0 \
        espeak \
        xvfb \
        x11-utils \
        xauth \
        scrot \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 3) Google Chrome, used both by the eel app (webbrowser.open) and by
#    Cursor computer-use manual testing.
RUN wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
        | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# 4) Ubuntu 24.04 ships a non-root "ubuntu" user (uid 1000); make sure it
#    exists and can use passwordless sudo for interactive development.
RUN if ! id ubuntu >/dev/null 2>&1; then useradd -m -s /bin/bash -u 1000 ubuntu; fi \
    && echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-ubuntu \
    && chmod 0440 /etc/sudoers.d/90-ubuntu

USER ubuntu
WORKDIR /home/ubuntu
