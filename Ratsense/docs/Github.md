# Generate CI SSH Key on the server (deploy user)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/github-ci -C "github-actions-staging"
```

~/.ssh/github-ci ← PRIVATE key
~/.ssh/github-ci.pub ← PUBLIC key

# Add the private key to GitHub

```bash
cat ~/.ssh/github-ci
```

Copy the entire line, then in GitHub:

Repo → Settings → Secrets → Actions → New Secret

- STAGING_SSH_KEY
- STAGING_HOST
- STAGING_USER

# Add the public key to authorized_keys

```bash
cat ~/.ssh/github-ci.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

# Setup Deployment Script

Update your .github/workflows/staging-deploy.yml:
