#!/bin/bash
set -e
cd "$(dirname "$0")"

# Check prerequisites
missing=""

if ! command -v python3 &> /dev/null; then
    missing="$missing python3"
fi

if ! command -v yt-dlp &> /dev/null; then
    missing="$missing yt-dlp"
fi

if ! command -v ffmpeg &> /dev/null; then
    missing="$missing ffmpeg"
fi

if [ -n "$missing" ]; then
    echo "Missing required tools:$missing"
    echo ""
    if [ -n "$PREFIX" ] && [ -n "$TERMUX_VERSION" ]; then
        echo "Install with:  pkg install$missing"
    elif command -v brew &> /dev/null; then
        echo "Install with:  brew install$missing"
    elif command -v apt &> /dev/null; then
        echo "Install with:  sudo apt install$missing"
    else
        echo "Please install:$missing"
    fi
    exit 1
fi

if ! command -v aria2c &> /dev/null; then
    echo "Notice: aria2c is not installed. Installing it can accelerate downloads."
    if [ -n "$PREFIX" ] && [ -n "$TERMUX_VERSION" ]; then
        echo "You can install it with:  pkg install aria2"
    elif command -v brew &> /dev/null; then
        echo "You can install it with:  brew install aria2"
    elif command -v apt &> /dev/null; then
        echo "You can install it with:  sudo apt install aria2"
    fi
    echo ""
fi

# Set up venv and install Python deps
if [ ! -d "venv" ]; then
    echo "Setting up virtual environment..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -q -r requirements.txt
else
    source venv/bin/activate
fi

if [ -n "$PREFIX" ] && [ -n "$TERMUX_VERSION" ]; then
    if command -v termux-wake-lock &> /dev/null; then
        echo "Acquiring termux-wake-lock to prevent Android from suspending the process..."
        termux-wake-lock
    else
        echo "Notice: termux-wake-lock not found. The app might be suspended in the background."
        echo "To fix this, install Termux:API app and run: pkg install termux-api"
    fi
fi

PORT="${PORT:-8899}"
export PORT

echo ""
echo "  ReClip is running at http://localhost:$PORT"
echo ""
python3 app.py
