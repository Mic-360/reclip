# ReClip Deployment Guide

## Deploying on Android via Termux

ReClip can be natively run on an Android device using Termux, taking full advantage of the device's capabilities without needing root access.

### 1. Install Termux
Install Termux and Termux:API from F-Droid (do not use the Google Play Store version as it is outdated).

### 2. One-Click Setup
Open Termux and run:
```bash
curl -O https://raw.githubusercontent.com/averygan/reclip/main/install.sh && bash install.sh
```
This script will automatically:
- Update Termux packages.
- Request storage access.
- Install dependencies (Python, FFmpeg, git, aria2, termux-api, cloudflared).
- Clone the ReClip repository and set up the Python environment.

### 3. Run in Background
To start ReClip in the background, keeping your terminal free and ensuring it runs continuously:
```bash
cd reclip
./start-background.sh
```
This will also automatically start a Cloudflare Tunnel and output a public `.trycloudflare.com` URL so you can access ReClip from anywhere on the internet immediately.

---

## Exposing ReClip via Cloudflare Tunnel (Manual Setup)

The `start-background.sh` script handles creating a temporary tunnel for you. However, if you want a permanent URL using your own domain:

### Setup a Permanent Tunnel (Custom Domain)
If you own a domain name and use Cloudflare for DNS:
1. Log in to your Cloudflare account.
2. Run `cloudflared tunnel login` in Termux and authenticate.
3. Create a tunnel:
   ```bash
   cloudflared tunnel create reclip
   ```
4. Route your domain (e.g., `reclip.yourdomain.com`) to the tunnel:
   ```bash
   cloudflared tunnel route dns reclip reclip.yourdomain.com
   ```
5. Run the tunnel:
   ```bash
   cloudflared tunnel run --url http://localhost:8899 reclip
   ```

*Tip: For a permanent setup on Android, you can use an app like [Termux:Boot](https://f-droid.org/packages/com.termux.boot/) to automatically start the `reclip.sh` script and `cloudflared` tunnel whenever your phone restarts.*

---

## Performance Notes on Android
ReClip includes several optimizations for running on mobile hardware:
1. **Multi-threading:** By installing `aria2`, `yt-dlp` will automatically fragment downloads and stitch them together, maximizing network utilization.
2. **Resource Management:** Console logging from `yt-dlp` has been suppressed to prevent memory spikes in the terminal environment.
3. **WSGI Server:** ReClip uses `waitress` to efficiently serve requests without blocking, enabling concurrent fetching and downloading.
