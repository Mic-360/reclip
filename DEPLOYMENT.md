# ReClip Deployment Guide

## Deploying on Android via Termux

ReClip can be natively run on an Android device using Termux, taking full advantage of the device's capabilities without needing root access.

### 1. Install Termux
Install Termux and Termux:API from F-Droid (do not use the Google Play Store version as it is outdated).

### 2. Basic Setup
Open Termux and run the following commands to update packages and grant storage access:
```bash
pkg update && pkg upgrade
termux-setup-storage
```

### 3. Install Required Dependencies
Install Python, FFmpeg, git, and other essential tools. We also highly recommend installing `aria2` to enable multi-threaded downloads, which significantly improves download speeds on mobile devices.
```bash
pkg install python ffmpeg git aria2 termux-api
```
*Note: Installing `termux-api` is important so ReClip can request a wake-lock, preventing Android from putting the app to sleep during long downloads.*

### 4. Clone and Run ReClip
```bash
git clone https://github.com/averygan/reclip.git
cd reclip
./reclip.sh
```
This script will automatically create a virtual environment, install the required Python packages (including `waitress` for better concurrency), and start the server.
When running in a compatible Termux environment with `termux-api` available, it will also attempt to acquire a `termux-wake-lock` to help keep the process running reliably in the background.

The app is now running locally at `http://localhost:8899`.

---

## Exposing ReClip via Cloudflare Tunnel

To access ReClip from anywhere using a live domain (and share it securely), you can use Cloudflare Tunnel (cloudflared). You do not need root access or port forwarding for this.

### 1. Install cloudflared in Termux
You can install `cloudflared` directly via pkg:
```bash
pkg install cloudflared
```

### 2. Start a Quick Tunnel (No Domain Required)
If you just want a quick, temporary URL to access ReClip:
```bash
cloudflared tunnel --url http://localhost:8899
```
This will generate a `.trycloudflare.com` URL that you can access from any device.

### 3. Setup a Permanent Tunnel (Custom Domain)
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
