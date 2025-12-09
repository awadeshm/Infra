#!/usr/bin/env bash
set -euo pipefail

BRANCH="staging"

APP_DIR="/opt/app/ratsense"
FRONTEND_DIR="$APP_DIR/Frontend"
BACKEND_DIR="$APP_DIR/backend"

FRONT_ROOT="/var/www/frontend"
BACK_ROOT="/var/www/backend"

SECRETS_ROOT="/opt/secrets"

TS="$(date +%Y%m%d_%H%M%S)"
FRONT_RELEASE="$FRONT_ROOT/releases/$TS"
BACK_RELEASE="$BACK_ROOT/releases/$TS"

echo "=== [1] Updating repo ($BRANCH) ==="
cd "$APP_DIR"
git fetch --all
git reset --hard "origin/$BRANCH"

echo "=== [2] Copying frontend .env ==="
cp "$SECRETS_ROOT/frontend/.env" "$FRONTEND_DIR/.env"

echo "=== [3] Building frontend ==="
cd "$FRONTEND_DIR"
npm install --legacy-peer-deps
npm run build

mkdir -p "$FRONT_RELEASE"
cp -r build/* "$FRONT_RELEASE"
ln -sfn "$FRONT_RELEASE" "$FRONT_ROOT/current"

echo "=== [4] Building backend ==="
cd "$BACKEND_DIR"
npm install --production --legacy-peer-deps

mkdir -p "$BACK_RELEASE"
cp -r . "$BACK_RELEASE"

echo "=== [5] Injecting backend environment ==="
cp "$SECRETS_ROOT/backend/.env" "$BACK_RELEASE/.env"

echo "=== [6] Injecting cronDBConnection.js ==="
mkdir -p "$BACK_RELEASE/cronScript/cronDBConnection"
cp "$SECRETS_ROOT/backend/cronDBConnection/cronDBConnection.js" \
   "$BACK_RELEASE/cronScript/cronDBConnection/"

echo "=== [7] Preserve uploads folder ==="
mkdir -p "$BACK_ROOT/persistent/uploads"
rm -rf "$BACK_RELEASE/uploads"
ln -s "$BACK_ROOT/persistent/uploads" "$BACK_RELEASE/uploads"

ln -sfn "$BACK_RELEASE" "$BACK_ROOT/current"

echo "=== [8] Restart backend ==="
cd "$BACK_ROOT/current"
if pm2 describe backend >/dev/null 2>&1; then
    pm2 restart backend
else
    pm2 start server.js --name backend
fi
pm2 save

echo "=== [9] Reload Nginx ==="
sudo /usr/bin/systemctl reload nginx

echo "=== [10] Clean old releases (>5) ==="
ls -1dt "$FRONT_ROOT/releases/"* | tail -n +6 | xargs rm -rf || true
ls -1dt "$BACK_ROOT/releases/"* | tail -n +6 | xargs rm -rf || true

echo "=== Deployment complete: $TS ==="