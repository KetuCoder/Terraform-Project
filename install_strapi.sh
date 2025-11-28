#!/bin/bash

# ---------------------------
# Update system packages
# ---------------------------
sudo apt update -y
sudo apt upgrade -y

# ---------------------------
# Install Node.js 20 and dependencies
# ---------------------------
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs build-essential git

# ---------------------------
# Install PM2 globally
# ---------------------------
sudo npm install -g pm2

# ---------------------------
# Create Strapi user (non-interactive)
# ---------------------------
USERNAME="strapi"
PASSWORD="Strapi@123"   # Change this if needed

# Check if user exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists"
else
    sudo useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo "$USERNAME"
fi

# ---------------------------
# Switch to Strapi user and install Strapi
# ---------------------------
sudo -i -u "$USERNAME" bash << EOF

# Install npx if not already
npm install -g npx

# Create Strapi app non-interactively
npx create-strapi-app@latest my-strapi-app --quickstart --no-telemetry --no-run

cd ~/my-strapi-app

# ---------------------------
# Start Strapi with PM2
# ---------------------------
pm2 start npm --name strapi -- run develop
pm2 save

# Setup PM2 startup on boot
sudo env PATH=\$PATH:/usr/bin pm2 startup systemd -u $USERNAME --hp /home/$USERNAME

EOF

# ---------------------------
# Final message
# ---------------------------
echo "Strapi installation completed!"
echo "Access Strapi admin panel at http://<EC2_PUBLIC_IP>:1337/admin"
echo "Use 'pm2 logs strapi' to see logs and 'pm2 list' to check status"
