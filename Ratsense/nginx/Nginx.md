NGINX CONFIG FOR FRONTEND

sudo nano /etc/nginx/sites-available/staging.ratsense.com

Enable:
sudo ln -s /etc/nginx/sites-available/staging.ratsense.com /etc/nginx/sites-enabled/

NGINX CONFIG FOR BACKEND (backend-staging.ratsense.com)
sudo nano /etc/nginx/sites-available/backend-staging.ratsense.com
Enable:
sudo ln -s /etc/nginx/sites-available/backend-staging.ratsense.com /etc/nginx/sites-enabled/

Test and reload:
sudo nginx -t
sudo systemctl reload nginx

INSTALL SSL CERTIFICATE FROM SSLS.COM

sudo mkdir -p /etc/nginx/ssl/ratsense
sudo cp STAR.ratsense.com.crt /etc/nginx/ssl/ratsense/fullchain.pem
sudo cp STAR.ratsense.com.key /etc/nginx/ssl/ratsense/privkey.pem

sudo nginx -t
sudo systemctl reload nginx
