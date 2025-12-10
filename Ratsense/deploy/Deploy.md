# Setup Deploy Script (As Deploy User)

```bash
nano /opt/deploy/deploy.sh
```

```bash
chmod +x /opt/deploy/deploy.sh
```

```bash
sudo /opt/deploy/deploy.sh
```

```bash
/opt/deploy/rollback.sh
```

**Ensure the files are owned by Deploy user**

```bash
sudo chmod -R 700 /opt/env
```

```bash
sudo chown deploy:deploy /opt/deploy/deploy.sh
```
