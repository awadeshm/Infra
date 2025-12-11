#!/usr/bin/env bash
set -euo pipefail

##############################
# CONFIG
##############################

BRANCH="staging"                 # staging server always deploys staging branch
ENV_SUFFIX="staging"             # change to "prod" on production server
ENV_ROOT="/opt/env"              # folder where env files are stored

APP_DIR="/opt/app/ratsense"
FRONTEND_DIR="$APP_DIR/Frontend"
BACKEND_DIR="$APP_DIR/backend"

FRONT_ROOT="/var/www/frontend"
BACK_ROOT="/var/www/backend"

TS="$(date +%Y%m%d_%H%M%S)"
FRONT_RELEASE="$FRONT_ROOT/releases/$TS"
BACK_RELEASE="$BACK_ROOT/releases/$TS"


##############################
# 1. UPDATE REPO
##############################
echo "=== [1] Updating repo (branch: $BRANCH) ==="
cd "$APP_DIR"
git fetch --all
git reset --hard "origin/$BRANCH"


##############################
# 2. FRONTEND ENV INJECTION
##############################
echo "=== [2] Injecting frontend .env ==="
if [[ -f "$ENV_ROOT/frontend.$ENV_SUFFIX.env" ]]; then
    cp "$ENV_ROOT/frontend.$ENV_SUFFIX.env" "$FRONTEND_DIR/.env"
else
    echo "ERROR: Missing $ENV_ROOT/frontend.$ENV_SUFFIX.env"
    exit 1
fi


##############################
# 3. BUILD FRONTEND
##############################
echo "=== [3] Building frontend ==="
cd "$FRONTEND_DIR"
npm install --legacy-peer-deps
npm run build

mkdir -p "$FRONT_RELEASE"
cp -r build/* "$FRONT_RELEASE"/
ln -sfn "$FRONT_RELEASE" "$FRONT_ROOT/current"

##############################
# 4. BACKEND ENV INJECTION
##############################
echo "=== [4] Injecting backend .env ==="
mkdir -p "$BACK_RELEASE"

if [[ -f "$ENV_ROOT/backend.$ENV_SUFFIX.env" ]]; then
    cp "$ENV_ROOT/backend.$ENV_SUFFIX.env" "$BACK_RELEASE/.env"
else
    echo "ERROR: Missing $ENV_ROOT/backend.$ENV_SUFFIX.env"
    exit 1
fi

# Ensure target directory exists
mkdir -p "$BACK_RELEASE/cronScript/cronDBConnection"

# === Copy secure cron DB connection file ===
mkdir -p "$BACK_RELEASE/cronDBConnection"
cp /opt/secrets/backend/cronDBConnection/cronDBConnection.js "$BACK_RELEASE/cronScript/cronDBConnection/"
echo "Copied secure cronDBConnection.js"

##############################
# 5. BUILD BACKEND
##############################
echo "=== [5] Building backend ==="
cd "$BACKEND_DIR"
npm install --production --legacy-peer-deps

# Copy backend to new release folder
cp -r . "$BACK_RELEASE"


##############################
# 6. PRESERVE UPLOADS
##############################
echo "=== [6] Preserving uploads ==="
mkdir -p "$BACK_ROOT/persistent/uploads"
rm -rf "$BACK_RELEASE/uploads"
ln -s "$BACK_ROOT/persistent/uploads" "$BACK_RELEASE/uploads"

# point backend current to new release
ln -sfn "$BACK_RELEASE" "$BACK_ROOT/current"

##############################
# 7. PM2 BACKEND + CRONJOBS
##############################
echo "=== [7] Reloading PM2 (backend + cronjobs) ==="
cd "$BACK_ROOT/current"

# Determine ecosystem file
if [[ "$BRANCH" == "staging" ]]; then
  ECO="ecosystem.staging.config.js"
else
  ECO="ecosystem.prod.config.js"
fi

if pm2 list | grep -q backend; then
  pm2 reload "$ECO"
else
  pm2 start "$ECO"
fi

pm2 save


##############################
# 8. RELOAD NGINX
##############################
echo "=== [8] Reloading nginx ==="
sudo /usr/bin/systemctl reload nginx


##############################
# DONE
##############################
echo "=== Deployment complete! Release: $TS ==="

echo "=== [8] Cleaning old releases ==="

# Number of releases to keep
KEEP=5

# FRONTEND CLEANUP
cd "$FRONT_ROOT/releases"
TOTAL_FRONT=$(ls -1 | wc -l)
if [ "$TOTAL_FRONT" -gt "$KEEP" ]; then
  ls -1t | tail -n +$((KEEP+1)) | xargs rm -rf
  echo "Frontend: Removed old releases, kept latest $KEEP"
fi

# BACKEND CLEANUP
cd "$BACK_ROOT/releases"
TOTAL_BACK=$(ls -1 | wc -l)
if [ "$TOTAL_BACK" -gt "$KEEP" ]; then
  ls -1t | tail -n +$((KEEP+1)) | xargs rm -rf
  echo "Backend: Removed old releases, kept latest $KEEP"
fi
