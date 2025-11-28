#!/bin/bash
set -e

LOG=/var/log/strapi-install.log
exec > >(tee -a &{LOG}) 2>&1

echo "Strating Strapi Installation On Ubuntu.....!"

sudo apt update -y

sudo apt upgrade -y

curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs git build-essential nginx

# Create user
useradd -m -s /bin/bash strapi

# Install PM2 globally
npm install pm2@latest -g

# Switch to strapi user and create project
sudo -u strapi bash <<EOF
cd ~
npx create-strapi-app@latest my-strapi-project --quickstart --no-run
cd my-strapi-project
npm install
npm run build
EOF

sudo -u strapi pm2 start /home/strapi/my-strapi-project/npm --name strapi-app -- start
sudo -u strapi pm2 save
pm2 startup systemcd -u strapi --hp /home/strapi

echo "Strapi Installation Finished...!"
echo "Strapi Should Be Available On Port 1337 After A Few Minutes.......!"