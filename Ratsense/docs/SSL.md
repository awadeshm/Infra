# Setup SSL files for Server

sudo mkdir -p /etc/nginx/ssl/ratsense

# Copy all the SSL Files from localhost

scp -i ~/Downloads/<your-ec2-key>.pem ~/Downloads/STAR.ratsense.com.crt ubuntu@13.250.46.121:/tmp/
scp -i ~/Downloads/<your-ec2-key>.pem ~/Downloads/STAR.ratsense.com.ca-bundle ubuntu@13.250.46.121:/tmp/
scp -i ~/Downloads/<your-ec2-key>.pem ~/Downloads/STAR.ratsense.com.key ubuntu@13.250.46.121:/tmp/

# Move SSL Files to Nginx Directory

sudo mv /tmp/STAR.ratsense.com.crt /etc/nginx/ssl/ratsense/
sudo mv /tmp/STAR.ratsense.com.ca-bundle /etc/nginx/ssl/ratsense/
sudo mv /tmp/STAR.ratsense.com.key /etc/nginx/ssl/ratsense/

# Create Fullchain Certificate

cd /etc/nginx/ssl/ratsense

sudo cp STAR.ratsense.com.key privkey.pem

sudo sh -c "cat STAR.ratsense.com.crt > fullchain.pem"
sudo sh -c "printf '\n' >> fullchain.pem"
sudo sh -c "cat STAR.ratsense.com.ca-bundle >> fullchain.pem"

# Set Permissions

sudo chmod 600 /etc/nginx/ssl/ratsense/\*
sudo chown root:root /etc/nginx/ssl/ratsense/\*

**Verify**
ls -l /etc/nginx/ssl/ratsense
