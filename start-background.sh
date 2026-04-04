#!/bin/bash

cd "$(dirname "$0")"

echo "==> Acquiring wakelock..."
if command -v termux-wake-lock &> /dev/null; then
    termux-wake-lock
fi

echo "==> Starting ReClip server in background..."
if [ ! -d "venv" ]; then
    echo "Virtual environment not found. Please run install.sh or reclip.sh first."
    exit 1
fi

source venv/bin/activate
nohup python3 app.py > reclip.log 2>&1 &
RECLIP_PID=$!

echo "==> Starting Cloudflare Tunnel in background..."
if command -v cloudflared &> /dev/null; then
    nohup cloudflared tunnel --url http://localhost:8899 > cloudflared.log 2>&1 &
    CLOUDFLARED_PID=$!

    echo "============================================="
    echo " ReClip is starting in the background!"
    echo " Local URL: http://localhost:8899"
    echo " Process PIDs: ReClip=$RECLIP_PID, Cloudflared=$CLOUDFLARED_PID"
    echo "============================================="
    echo ""
    echo "Waiting for Cloudflare Public URL..."
    sleep 5
    # Extract URL from log
    CF_URL=$(grep -o 'https://[-a-zA-Z0-9]*\.trycloudflare\.com' cloudflared.log | head -n 1)

    if [ -n "$CF_URL" ]; then
        echo "---------------------------------------------"
        echo " Public URL: $CF_URL"
        echo "---------------------------------------------"
    else
        echo "Could not parse Cloudflare URL yet. You can check it with:"
        echo "  cat cloudflared.log | grep trycloudflare"
    fi
else
    echo "============================================="
    echo " ReClip is starting in the background!"
    echo " Local URL: http://localhost:8899"
    echo " Process PID: ReClip=$RECLIP_PID"
    echo "============================================="
    echo ""
    echo "Notice: cloudflared is not installed. Skipping public URL generation."
    echo "To get a public URL, install cloudflared and restart."
fi

echo ""
if command -v cloudflared &> /dev/null; then
    echo "To stop ReClip, run: kill $RECLIP_PID $CLOUDFLARED_PID"
else
    echo "To stop ReClip, run: kill $RECLIP_PID"
fi
echo "To view logs, run: tail -f reclip.log"
