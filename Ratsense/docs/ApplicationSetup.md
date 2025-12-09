# Setup Deploy user

sudo adduser deploy

**Deploy user to the groups that can manage PM2 & Nginx:**
sudo usermod -aG sudo deploy
sudo usermod -aG www-data deploy

**Set up SSH for deploy user**
sudo su - deploy

mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Create Directory Structure

sudo mkdir -p /opt/app/ratsense
sudo mkdir -p /opt/deploy
sudo mkdir -p /opt/env
sudo mkdir -p /opt/secrets/backend/cronDBConnection
sudo mkdir -p /var/www/frontend/releases
sudo mkdir -p /var/www/backend/releases
sudo mkdir -p /var/www/backend/persistent/uploads

sudo chown -R deploy:deploy /opt/app /opt/deploy /opt/secrets /var/www

# Setup Github

ssh-keygen -t ed25519 -C "deploy@ratsense-staging"

Verify -
/home/deploy/.ssh/id_ed25519
/home/deploy/.ssh/id_ed25519.pub

Start SSH agent & Add the private key:
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

**Optional**
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

**Copy the key**
cat ~/.ssh/id_ed25519.pub

**Verify the Github Connection**
ssh -T git@github.com

# Clone Repo

cd /opt/app
git clone -b <branch e.g. staging> git@github.com:simplifys-com/ratsenseV2.git ratsense

# Setup Secret Files

sudo nano /opt/env/frontend.staging.env
sudo nano /opt/env/backend.staging.env
sudo nano /opt/secrets/backend/cronDBConnection/cronDBConnection.js

sudo chmod -R 700 /opt/env
sudo chmod -R 700 /opt/secrets/backend
