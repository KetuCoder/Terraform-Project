#!/bin/bash
set -e

sudo apt update -y
sudo apt install -y curl
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs

sudo npm install -g yarn

sudo apt install -y build-essential

cd /home/ubuntu

sudo -E STRAPI_DISABLE_CLOUD=true STRAPI_TELEMETRY_DISABLED=true STRAPI_FORCE_CI=true \
npx create-strapi-app@latest my-project --quickstart --no-run

sudo chown -R ubuntu:ubuntu /home/ubuntu/my-project

sudo npm install -g pm2

cd /home/ubuntu/my-project
pm2 start npm --name strapi -- run develop
pm2 save
pm2 startup systemd -u ubuntu --hp /home/ubuntu
