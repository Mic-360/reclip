#!/bin/bash

cd "$(dirname "$0")"
PORT="${PORT:-8899}"
LOCAL_URL="http://localhost:$PORT"

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
CLOUDFLARED_PID=""

if [ "${ENABLE_CLOUDFLARED_TUNNEL:-0}" = "1" ]; then
    echo "==> Starting Cloudflare Tunnel in background..."
    if command -v cloudflared &> /dev/null; then
        echo "Security warning: Cloudflare Quick Tunnel makes this service publicly reachable."
        nohup cloudflared tunnel --url "$LOCAL_URL" > cloudflared.log 2>&1 &
        CLOUDFLARED_PID=$!

        echo "============================================="
        echo " ReClip is starting in the background!"
        echo " Local URL: $LOCAL_URL"
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
        echo "cloudflared is not installed. Skipping public URL generation."
    fi
else
    echo "============================================="
    echo " ReClip is starting in the background!"
    echo " Local URL: $LOCAL_URL"
    echo " Process PID: ReClip=$RECLIP_PID"
    echo "============================================="
    echo ""
    echo "Cloudflare Tunnel is disabled by default."
    echo "To enable it, run: ENABLE_CLOUDFLARED_TUNNEL=1 ./start-background.sh"
fi

echo ""
if [ -n "$CLOUDFLARED_PID" ]; then
    echo "To stop ReClip, run: kill $RECLIP_PID $CLOUDFLARED_PID"
else
    echo "To stop ReClip, run: kill $RECLIP_PID"
fi
echo "To view logs, run: tail -f reclip.log"
