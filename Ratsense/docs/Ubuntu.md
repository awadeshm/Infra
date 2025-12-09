1. Create EC2 Instance

• OS: Ubuntu LTS (22.04 or 24.04)
• Instance type: t3.medium or better (recommended)
• Storage: 30GB gp3 minimum
• Security Group: - Allow SSH (22) from your IP only - Allow HTTP (80) from anywhere - Allow HTTPS (443) from anywhere
• Elastic IP: Assign one static Elastic IP to the server

2. Update Server & Install Essentials

sudo apt update && sudo apt upgrade -y
sudo apt install -y git unzip build-essential

# OPTIONAL but recommended

sudo timedatectl set-timezone Asia/Kolkata

INSTALL NODE.JS (LATEST LTS) + NPM + PM2

curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

sudo npm install -g pm2

# Auto-start PM2 on boot

pm2 startup systemd
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u deploy --hp /home/deploy

CREATE DEPLOY USER

sudo adduser deploy
sudo usermod -aG sudo deploy

# Switch to deploy user

sudo su - deploy

# Generate SSH key for GitHub access

ssh-keygen -t ed25519 -C "deploy@ratsense-staging"

# Show public key → add to GitHub Deploy Keys (read-only)

cat ~/.ssh/id_ed25519.pub

# Test GitHub access

ssh -T git@github.com
INSTALL NGINX

sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Allow firewall traffic

sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
sudo ufw enable
