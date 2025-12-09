15. VERIFY SETUP

curl http://localhost:8000/ -I
curl https://backend-staging.ratsense.com --insecure -I
curl https://staging.ratsense.com --insecure -I

pm2 status
sudo ss -tlnp | grep node
sudo nginx -t
