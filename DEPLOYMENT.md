# ReClip Deployment Guide (Ubuntu Server)

This guide walks you through deploying ReClip on an Ubuntu Server natively using systemd, Nginx as a reverse proxy, and Let's Encrypt for HTTPS. This setup is intended to host ReClip on the domain `reclip.bhaumicsingh.tech`.

## Prerequisites

- An Ubuntu Server (20.04, 22.04, 24.04, or newer)
- A user account with sudo privileges (assumed to be `mic` in this guide)
- The domain `reclip.bhaumicsingh.tech` pointing to your server's IP address (A record)

## 1. Install Dependencies

First, update your package lists and install the required system dependencies: Python, FFmpeg, Nginx, and Certbot.

```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-pip ffmpeg nginx certbot python3-certbot-nginx git
```

*(Optional but recommended)* Install `aria2` to speed up downloads using multi-threading:
```bash
sudo apt install -y aria2
```

## 2. Clone the Repository and Setup the Environment

We will install ReClip in `/home/mic/reclip`.

```bash
cd /home/mic
git clone https://github.com/averygan/reclip.git
cd reclip
```

Create a Python virtual environment and install the required Python packages:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 3. Create a Systemd Service

To ensure ReClip runs in the background and starts automatically when the server reboots, we will create a systemd service.

Create a new service file:

```bash
sudo nano /etc/systemd/system/reclip.service
```

Add the following configuration to the file:

```ini
[Unit]
Description=ReClip Service
After=network.target

[Service]
User=mic
Group=mic
WorkingDirectory=/home/mic/reclip
Environment="PATH=/home/mic/reclip/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# Using Waitress as the WSGI server (default in app.py)
ExecStart=/home/mic/reclip/venv/bin/python app.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Save and exit. Then, reload the systemd daemon, enable the service to start on boot, and start it immediately:

```bash
sudo systemctl daemon-reload
sudo systemctl enable reclip
sudo systemctl start reclip
```

Verify the service is running:

```bash
sudo systemctl status reclip
```
*(You should see it running on `http://127.0.0.1:8899`)*

## 4. Configure Nginx Reverse Proxy

Now, configure Nginx to forward traffic from `reclip.bhaumicsingh.tech` to the local ReClip instance.

Create a new Nginx configuration file:

```bash
sudo nano /etc/nginx/sites-available/reclip
```

Add the following configuration:

```nginx
server {
    listen 80;
    server_name reclip.bhaumicsingh.tech;

    location / {
        proxy_pass http://127.0.0.1:8899;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Depending on the size of files, you might want to increase this,
        # but ReClip downloads files on the backend directly.
        client_max_body_size 10M;
    }
}
```

Save and exit. Enable the site by creating a symbolic link to `sites-enabled`:

```bash
sudo ln -s /etc/nginx/sites-available/reclip /etc/nginx/sites-enabled/
```

Test the Nginx configuration for syntax errors:

```bash
sudo nginx -t
```

If the test is successful, restart Nginx to apply the changes:

```bash
sudo systemctl restart nginx
```

## 5. Secure with SSL (Let's Encrypt / Certbot)

Finally, use Certbot to automatically fetch and configure an SSL certificate for your domain.

```bash
sudo certbot --nginx -d reclip.bhaumicsingh.tech
```

Follow the prompts. Certbot will automatically modify your Nginx configuration to enable HTTPS and set up automatic certificate renewals.

## 6. Access ReClip

You can now access your ReClip deployment securely at:
**https://reclip.bhaumicsingh.tech**

---

### Alternative Deployments

*(If you are looking for the old Android/Termux deployment instructions, they are available in the [repository history](https://github.com/averygan/reclip) or via the `install.sh` and `start-background.sh` scripts included in the repo.)*
