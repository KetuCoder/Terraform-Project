#!/bin/bash
# ===================================================
# Strapi v5 installation script for Ubuntu EC2
# Logs everything to /var/log/strapi-install.log
# ===================================================

set -ex

# Redirect all stdout/stderr to log and syslog
exec > >(tee /var/log/strapi-install.log|logger -t strapi-userdata ) 2>&1

echo "===== START Strapi installation ====="

# ---------------------------
# Update system packages
# ---------------------------
sudo apt update -y
sudo apt upgrade -y

# ---------------------------
# Install Node.js 20, npm, build tools, git
# ---------------------------
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs build-essential git

# Verify Node.js and npm
echo "Node version: $(node -v)"
echo "npm version: $(npm -v)"

# ---------------------------
# Install PM2 globally
# ---------------------------
sudo npm install -g pm2
pm2 -v

# ---------------------------
# Create Strapi user (non-interactive)
# ---------------------------
USERNAME="strapi"
PASSWORD="Strapi@123"  # Change this if needed

if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists"
else
    sudo useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo "$USERNAME"
    echo "Created user $USERNAME"
fi

# ---------------------------
# Prepare Strapi installation script for user
# ---------------------------
sudo tee /home/$USERNAME/install_strapi_user.sh > /dev/null << 'EOL'
#!/bin/bash
set -ex
# Log for user-specific commands
exec > >(tee /home/strapi/strapi-user.log|logger -t strapi-user) 2>&1

# Install npx if missing
npm install -g npx

# Create Strapi app (non-interactive)
npx create-strapi-app@latest my-strapi-app --quickstart --no-telemetry --no-run

cd ~/my-strapi-app

# Start Strapi with PM2
pm2 start npm --name strapi -- run develop
pm2 save

# Setup PM2 to start on boot
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u strapi --hp /home/strapi
EOL

sudo chmod +x /home/$USERNAME/install_strapi_user.sh
sudo chown $USERNAME:$USERNAME /home/$USERNAME/install_strapi_user.sh

# ---------------------------
# Run Strapi installation as strapi user
# ---------------------------
sudo -u $USERNAME /home/$USERNAME/install_strapi_user.sh

# ---------------------------
# Finished
# ---------------------------
echo "===== Strapi installation completed ====="
echo "Access Strapi admin panel at http://<EC2_PUBLIC_IP>:1337/admin"
echo "Use 'pm2 logs strapi' to see logs and 'pm2 list' to check status"
