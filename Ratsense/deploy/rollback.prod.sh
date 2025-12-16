#!/usr/bin/env bash
set -euo pipefail

FRONT_ROOT="/var/www/frontend/releases"
BACK_ROOT="/var/www/backend/releases"

echo "==============================="
echo "     ROLLBACK TOOL"
echo "==============================="

echo ""
echo "Available FRONTEND releases:"
ls -1 $FRONT_ROOT

echo ""
echo "Available BACKEND releases:"
ls -1 $BACK_ROOT

echo ""
read -p "Enter release timestamp to rollback to (e.g. 20251209_071026): " TS

FRONT_TARGET="$FRONT_ROOT/$TS"
BACK_TARGET="$BACK_ROOT/$TS"

# Validate release exists
if [ ! -d "$FRONT_TARGET" ]; then
  echo "ERROR: Frontend release not found: $FRONT_TARGET"
  exit 1
fi

if [ ! -d "$BACK_TARGET" ]; then
  echo "ERROR: Backend release not found: $BACK_TARGET"
  exit 1
fi

echo ""
echo "You are about to rollback to:"
echo "  Frontend → $FRONT_TARGET"
echo "  Backend  → $BACK_TARGET"
read -p "Confirm rollback? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Rollback cancelled."
  exit 0
fi

echo ""
echo "=== Updating symlinks ==="

ln -sfn "$FRONT_TARGET" /var/www/frontend/current
ln -sfn "$BACK_TARGET" /var/www/backend/current

echo "Symlinks updated."

echo ""
echo "=== Restarting backend ==="
cd /var/www/backend/current

if pm2 describe backend >/dev/null 2>&1; then
  pm2 restart backend
else
  pm2 start server.js --name backend
fi

pm2 save

echo ""
echo "=== Reloading NGINX ==="
sudo /usr/bin/systemctl reload nginx

echo ""
echo "==============================="
echo "Rollback to release $TS completed."
echo "==============================="
