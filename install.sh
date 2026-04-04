#!/bin/bash
set -e

echo "============================================="
echo "       ReClip Termux 1-Click Installer       "
echo "============================================="
echo ""

# Check if running in Termux
if [ -z "$PREFIX" ]; then
    echo "This installer supports automatic dependency installation only on Termux."
    echo "For other platforms, please follow the manual setup instructions in the README:"
    echo "https://github.com/averygan/reclip"
    echo ""
    exit 1
fi

if ! command -v pkg &> /dev/null; then
    echo "Termux environment detected, but the 'pkg' command is not available."
    echo "Automatic package installation cannot continue."
    exit 1
fi

# Update and install packages in Termux
echo "==> Updating package lists..."
pkg update -y && pkg upgrade -y

echo "==> Requesting storage access..."
termux-setup-storage || true

echo "==> Installing dependencies (Python, FFmpeg, Git, Aria2, Termux-API, Cloudflared)..."
pkg install -y python ffmpeg git aria2 termux-api cloudflared

# Clone repository
if [ ! -d "reclip" ]; then
    echo "==> Cloning ReClip repository..."
    git clone https://github.com/averygan/reclip.git
else
    echo "==> ReClip repository already exists. Updating..."
    cd reclip
    git pull
    cd ..
fi

cd reclip

# Set up virtual environment
echo "==> Setting up Python virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate

echo "==> Installing Python requirements..."
pip install --upgrade pip
pip install -q -r requirements.txt

chmod +x start-background.sh

echo ""
echo "============================================="
echo " Installation Complete! Starting ReClip... "
echo "============================================="
echo ""

./start-background.sh
