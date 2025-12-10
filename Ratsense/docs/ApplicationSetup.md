# Setup Deploy user

```bash
sudo adduser deploy
```

**Deploy user to the groups that can manage PM2 & Nginx:**

```bash
sudo usermod -aG sudo deploy
sudo usermod -aG www-data deploy
```

**Set up SSH for deploy user**

```bash
sudo su - deploy
```

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

**Fix for Uploads**

```bash
sudo ln -s /var/www/backend/persistent/uploads /var/www/backend/uploads
```

# Deploy User permissions to run deploy.sh

**(As Ubuntu)**

```bash
sudo visudo
```

**Add the following at the end of the file**

```
# Allow deploy user to reload nginx without password

deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl reload nginx

# Optional: allow config test

deploy ALL=(ALL) NOPASSWD: /usr/sbin/nginx

# Optional: allow restart (rarely needed)

deploy ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
```

# Create Directory Structure

```bash
sudo mkdir -p /opt/app/ratsense
sudo mkdir -p /opt/deploy
sudo mkdir -p /opt/env
sudo mkdir -p /opt/secrets/backend/cronDBConnection
sudo mkdir -p /var/www/frontend/releases
sudo mkdir -p /var/www/backend/releases
sudo mkdir -p /var/www/backend/persistent/uploads
```

```bash
sudo chown -R deploy:deploy /opt/app /opt/env /opt/deploy /opt/secrets /var/www
```

# Setup Github

```bash
ssh-keygen -t ed25519 -C "deploy@ratsense-staging"
```

Verify -
/home/deploy/.ssh/id_ed25519
/home/deploy/.ssh/id_ed25519.pub

Start SSH agent & Add the private key:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

**Optional**

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

**Copy the key**

```bash
cat ~/.ssh/id_ed25519.pub
```

**Verify the Github Connection**

```bash
ssh -T git@github.com
```

# Clone Repo

```bash
cd /opt/app
git clone -b <branch e.g. staging> git@github.com:simplifys-com/ratsenseV2.git ratsense
```

# Setup Secret Files

```bash
sudo nano /opt/env/frontend.staging.env
sudo nano /opt/env/backend.staging.env
sudo nano /opt/secrets/backend/cronDBConnection/cronDBConnection.js
```

```bash
sudo chmod -R 700 /opt/env
sudo chmod -R 700 /opt/secrets/backend
```

# Copy Uploads folder

```bash
scp -i ratsense/ratsense-staging.pem -r uploads/_ ubuntu@13.250.46.121:/home/ubuntu/uploads_tmp/
sudo mv /home/ubuntu/uploads_tmp/_ /var/www/backend/persistent/uploads/
sudo chown -R deploy:deploy /var/www/backend/persistent/uploads/
sudo rm -rf /home/ubuntu/uploads_tmp
```
