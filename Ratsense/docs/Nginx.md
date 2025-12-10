# Install Nginx

```bash
sudo apt update
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
```

# Check Status

```bash
systemctl status nginx
```

# Allow Nginx in firewall

```bash
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
sudo ufw enable
```

[Setup SSL Files](SSL.md)

# NGINX config for Domains

- sudo nano /etc/nginx/sites-available/<domain>
- Copy the data from the nginx/<domain>.conf
- sudo ln -s /etc/nginx/sites-available/<domain>> /etc/nginx/sites-enabled/

**Repeat for All domains**

# Test and reload:

```bash
sudo nginx -t
sudo systemctl reload nginx
```
