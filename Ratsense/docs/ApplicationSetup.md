3. Create Directory Structure

sudo mkdir -p /opt/app/ratsense
sudo mkdir -p /opt/deploy
sudo mkdir -p /opt/secrets/backend/cronDBConnection
sudo mkdir -p /opt/secrets/backend/env
sudo mkdir -p /var/www/frontend/releases
sudo mkdir -p /var/www/backend/releases
sudo mkdir -p /var/www/backend/persistent/uploads

sudo chown -R deploy:deploy /opt/app /opt/deploy /opt/secrets /var/www

CLONE REPOSITORY (STAGING BRANCH)
cd /opt/app
git clone -b staging git@github.com:simplifys-com/ratsenseV2.git ratsense

STORE SECRETS (NOT IN GIT)

# Backend .env (example)

nano /opt/secrets/backend/env/backend.staging.env

# Cron DB file

nano /opt/secrets/backend/cronDBConnection/cronDBConnection.js

Permissions:
sudo chmod -R 700 /opt/secrets/backend
