# Downgrade Node

**As Ubuntu**

```bash
sudo apt remove -y nodejs
sudo rm -rf /usr/lib/node_modules/npm
sudo rm -rf /usr/lib/node_modules/corepack
```

```bash
sudo rm -rf /home/deploy/.cache/node-gyp
sudo rm -rf /root/.cache/node-gyp
```

**As Deploy User**

```bash
sudo su - deploy
rm -rf ~/.npm
rm -rf /opt/app/ratsense/backend/node_modules
```

**As Ubuntu**

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

# Switch to deploy user

```bash
sudo su - deploy
```

# RATSENSE STAGING – DEBUG & TROUBLESHOOTING GUIDE

This file focuses ONLY on debugging common issues:

- 502 / 500 / 404 errors
- Backend not responding
- Port mismatch (4000 vs 8000)
- Nginx / DNS / Cloudflare problems
- Deploy issues (bad release, missing secrets, uploads deleted)

# QUICK DIAG CHECKLIST

When something is broken, run these first on the server (as deploy user):

1. Check if backend is running:

```bash
pm2 status
```

2. Check if Node is listening:

```bash
sudo ss -tlnp | grep node
```

3. Check Nginx config:

```bash
sudo nginx -t
```

4. Check current symlinks:

```bash
readlink -f /var/www/frontend/current
readlink -f /var/www/backend/current
```

5. Check that frontend + backend URLs respond:

```bash
curl http://localhost:8000/ -I
curl https://backend-staging.ratsense.com --insecure -I
curl https://staging.ratsense.com --insecure -I
```


# 502 BAD GATEWAY (BACKEND)

SYMPTOM:

- Browser or curl shows:
  502 Bad Gateway (nginx)
- Or Axios "Network Error" when calling backend-staging.ratsense.com

A. CHECK IF BACKEND IS RUNNING

1. Is Node listening on port 8000?

```bash
sudo ss -tlnp | grep 8000
```

   If nothing shows → backend not running.

2. Check PM2:

```bash
pm2 status
```

   - backend should be "online"
   - If missing or "errored", restart:

```bash
cd /var/www/backend/current
pm2 start server.js --name backend
pm2 save
```

3. Check backend logs:

```bash
pm2 logs backend --lines 100
```

   Look for:

   - "server is running at 8000"
   - Module not found
   - Env / DB connection errors

B. PORT MISMATCH: 8000 VS 4000

1. If logs say:
   "Backend running on port 4000"
   but Nginx proxy_pass is:
   proxy_pass http://localhost:8000;

   → Nginx cannot reach backend → 502.

2. TEMP FIX:
   In /etc/nginx/sites-available/backend-staging.ratsense.com
   change:
   proxy_pass http://localhost:8000;
   to:
   proxy_pass http://localhost:4000;

   Then:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

3. LONG-TERM FIX:
   Ensure server.js uses:
   const port = process.env.PORT || 8000;
   and backend .env includes:
   PORT=8000
   Then keep Nginx to proxy_pass localhost:8000.

C. MODULE / SECRET MISSING

If logs show:
Error: Cannot find module './cronDBConnection/cronDBConnection.js'

Check:

```bash
ls -l /var/www/backend/current/cronScript/cronDBConnection/
```

If file missing → deploy didn't copy secrets.

Verify:

```bash
ls -l /opt/secrets/backend/cronDBConnection/
cat /opt/secrets/backend/cronDBConnection/cronDBConnection.js
```

Deploy script must include:

```
mkdir -p "$BACK_RELEASE/cronScript/cronDBConnection"
   cp /opt/secrets/backend/cronDBConnection/cronDBConnection.js \
      "$BACK_RELEASE/cronScript/cronDBConnection/"
```

Then redeploy:

```bash
sudo /opt/deploy/deploy.sh
```

# FRONTEND 404 / 403 / OLD BUILD

A. 404 ON ROUTES LIKE /login, /user, /admin

SYMPTOM:

- https://staging.ratsense.com/ works
- https://staging.ratsense.com/login returns 404 from nginx

CAUSE:

- Nginx not configured for React SPA fallback.

FIX:
In /etc/nginx/sites-available/staging.ratsense.com:

```
location / {
try_files $uri $uri/ /index.html;
}
```

NOT:
try_files $uri $uri/ =404;

Test + reload:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

B. 403 FORBIDDEN

Check directory permissions:

```bash
ls -ld /var /var/www /var/www/frontend /var/www/frontend/releases /var/www/frontend/current
```

Recommended:

```bash
sudo chown -R deploy:www-data /var/www/frontend
sudo find /var/www/frontend -type d -exec chmod 755 {} \;
sudo find /var/www/frontend -type f -exec chmod 644 {} \;
```

C. OLD FRONTEND BUILD / STILL CALLING localhost:8000

SYMPTOM:

- Network tab shows calls to http://localhost:8000
- Even though axios uses process.env.REACT_APP_BASE_URL

CHECK:

1. Ensure frontend .env has NO spaces / quotes:

```bash
cat /opt/secrets/frontend/env/frontend.staging.env
```

   Correct format:
   REACT_APP_BASE_URL=https://backend-staging.ratsense.com
   NOT:
   REACT_APP_BASE_URL = 'https://backend-staging.ratsense.com'

2. After updating .env, rebuild manually:

```bash
cd /opt/app/ratsense/Frontend
cp /opt/secrets/frontend/env/frontend.staging.env .env
npm run build
```

3. Verify build contents:

```bash
grep -R "backend-staging" -n build
grep -R "localhost:8000" -n build
```

4. Redeploy:

```bash
sudo /opt/deploy/deploy.sh
```

5. Clear browser + Cloudflare cache:
   - Hard reload (Ctrl+Shift+R)
   - Cloudflare → Caching → Purge Everything

# DNS / CLOUDFLARE ISSUES

A. CHECK DNS

On your Mac:

```bash
dig staging.ratsense.com
dig backend-staging.ratsense.com
```

Should resolve to:
<EC2 Elastic IP>

If not → fix DNS in Cloudflare.

B. CHECK WHO IS RESPONDING

From your Mac:

```bash
curl -I --insecure https://backend-staging.ratsense.com
```

If you see:
server: cloudflare
cf-ray: ...

→ Cloudflare is in path.

If you see:
Server: nginx/1.24.0 (Ubuntu)

→ You are talking directly to your server.

C. CLOUDFLARE PROXY

For backend-staging:

- If you see frequent 502 from Cloudflare
- Option: switch to DNS-only for debugging

In Cloudflare DNS:

- Toggle orange cloud → grey cloud
- Wait 1–2 minutes
- Test again with curl

Keep record of working setup and revert to that.

# DEPLOYMENT SCRIPT ISSUES

SCRIPT PATH:
/opt/deploy/deploy.sh

A. VERIFY SCRIPT IS EXECUTABLE

```bash
sudo chmod +x /opt/deploy/deploy.sh
```

B. IF DEPLOY FAILS MIDWAY

Common errors:

1. cp: cannot stat '/opt/secrets/...': No such file or directory
   → Secret path wrong or file missing
   → Check:

```bash
ls -R /opt/secrets/backend
```

2. Wrong release symlink:

```bash
readlink -f /var/www/frontend/current
readlink -f /var/www/backend/current
```

If they point to wrong folder, manually fix:

```bash
ln -sfn /var/www/frontend/releases/<good_ts> /var/www/frontend/current
ln -sfn /var/www/backend/releases/<good_ts> /var/www/backend/current
sudo systemctl reload nginx
```

C. NPM INSTALL ISSUES

If deploy fails during npm install:

- Try clearing node_modules and lockfile once manually
- But usually just:

```bash
cd /opt/app/ratsense/Frontend
npm install --legacy-peer-deps
```

```bash
cd /opt/app/ratsense/backend
npm install --production --legacy-peer-deps
```

Then rerun:

```bash
sudo /opt/deploy/deploy.sh
```

# UPLOADS FOLDER LOST AFTER DEPLOY

EXPECTED DESIGN:

- All uploaded files stored in:
  /var/www/backend/persistent/uploads

- Each release has:
  /var/www/backend/releases/<ts>/uploads → symlink to persistent/uploads

CHECK:

```bash
ls -ld /var/www/backend/persistent/uploads
ls -l /var/www/backend/current/uploads
```

Should show:
uploads -> /var/www/backend/persistent/uploads

If not, fix deployment block:

In deploy.sh, after copying backend:

```
mkdir -p "$BACK_ROOT/persistent/uploads"
   rm -rf "$BACK_RELEASE/uploads"
ln -s "$BACK_ROOT/persistent/uploads" "$BACK_RELEASE/uploads"
```

# ROLLBACK TO PREVIOUS RELEASE

If a new deploy breaks something:

1. List releases:

```bash
ls -ltr /var/www/frontend/releases
ls -ltr /var/www/backend/releases
```

Latest will be at bottom.

2. Pick previous timestamp, e.g. 20251209_071026

3. Point symlinks back:

```bash
ln -sfn /var/www/frontend/releases/20251209_071026 /var/www/frontend/current
ln -sfn /var/www/backend/releases/20251209_071026 /var/www/backend/current
```

4. Restart backend + reload Nginx:

```bash
cd /var/www/backend/current
pm2 restart backend
pm2 save
```

```bash
sudo systemctl reload nginx
```

5. Verify:

```bash
curl http://localhost:8000/ -I
curl https://backend-staging.ratsense.com --insecure -I
curl https://staging.ratsense.com --insecure -I
```

# QUICK COMMANDS REFERENCE

# Nginx

```bash
sudo nginx -t
sudo systemctl reload nginx
sudo systemctl restart nginx
sudo journalctl -u nginx --no-pager -n 50
```

# PM2 & Node

```bash
pm2 status
pm2 logs backend --lines 50
pm2 restart backend
pm2 delete backend
pm2 save
sudo ss -tlnp | grep node
sudo ss -tlnp | grep 8000
```

# Symlinks

```bash
readlink -f /var/www/frontend/current
readlink -f /var/www/backend/current
```

# Curl tests

```bash
curl http://localhost:8000/ -I
curl https://backend-staging.ratsense.com --insecure -I
curl https://staging.ratsense.com --insecure -I
```