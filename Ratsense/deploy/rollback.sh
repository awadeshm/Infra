#!/usr/bin/env bash
set -euo pipefail

ROOT="/var/www/backend/releases"

echo "Available releases:"
ls -ltr "$ROOT"

read -p "Enter release folder name to rollback to: " REL

if [ ! -d "$ROOT/$REL" ]; then
  echo "Release does not exist."
  exit 1
fi

ln -sfn "$ROOT/$REL" /var/www/backend/current
pm2 restart backend
sudo systemctl reload nginx

echo "Rollback complete → $REL"