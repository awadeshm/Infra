15. VERIFY SETUP

```bash
curl http://localhost:8000/ -I
curl https://backend-staging.ratsense.com --insecure -I
curl https://staging.ratsense.com --insecure -I
```

```bash
pm2 status
sudo ss -tlnp | grep node
sudo nginx -t
```

# Verify Upload folder created

```bash
ls -l /var/www/backend/uploads
```

**Expected**
uploads -> /var/www/backend/persistent/uploads
