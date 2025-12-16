# Create EC2 Instance

- Create a new Ubuntu LTS (22.04 or 24.04 or Latest)
- Choose storage of min 20GB
- Setup Security Group to allow :
  - Allow SSH (22) from your IP only
  - Allow HTTP (80) from anywhere
  - Allow HTTPS (443) from anywhere
- Assign one static Elastic IP to the server

# Update Server & Install Essentials

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git unzip build-essential
```

# Optional but recommended

```bash
sudo timedatectl set-timezone Asia/Kolkata
```

# Setup Node and dependencies

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g pm2
```

**Older version of node**

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g pm2
```

# Setup Deploy user

```bash
sudo adduser deploy
```

**Deploy user to the groups that can manage PM2 & Nginx:**

```bash
sudo usermod -aG sudo deploy
sudo usermod -aG www-data deploy
```

# Auto-start PM2 on boot

```bash
pm2 startup systemd -u deploy --hp /home/deploy
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u deploy --hp /home/deploy
```

# Add SWAP

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab
```
