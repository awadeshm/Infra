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

# Github Deploy SEtup

Use deploy user

ssh-keygen -t ed25519 -f ~/.ssh/github-ci -C "github-actions-prod"
cat ~/.ssh/github-ci

Repo → Settings → Secrets → Actions → New Secret

cat ~/.ssh/github-ci.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

Test:
ssh -i ~/.ssh/github-ci deploy@47.130.228.103 "echo ok"

USER - deploy
HOST - IP

# Delete unwanted cronjobs

```bash
pm2 delete cron_lora_data cron_lora_sync
pm2 save
```
