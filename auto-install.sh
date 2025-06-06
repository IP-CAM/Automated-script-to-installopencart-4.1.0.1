#!/bin/bash

set -e  # Exit on error

OPENCART_VERSION="4.1.0.1"
DB_NAME="opencart"
DB_USER="opencart_user"
DB_PASS="StrongPasswordHere"

echo "🔄 Updating system and installing dependencies..."
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql php-zip php-gd php-mbstring php-curl php-xml unzip wget

echo "🛠 Starting and enabling Apache & MySQL services..."
sudo systemctl enable apache2
sudo systemctl enable mysql
sudo systemctl start apache2
sudo systemctl start mysql

echo "🔒 Running MySQL secure installation (manual step)..."
sudo mysql_secure_installation

echo "🛠 Creating MySQL database and user..."
sudo mysql -e "DROP DATABASE IF EXISTS ${DB_NAME};"
sudo mysql -e "DROP USER IF EXISTS '${DB_USER}'@'localhost';"
sudo mysql -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "⬇️ Downloading OpenCart ${OPENCART_VERSION}..."
wget -q https://github.com/opencart/opencart/releases/download/${OPENCART_VERSION}/opencart-${OPENCART_VERSION}.zip -O opencart.zip

echo "📦 Extracting OpenCart files to /var/www/html/opencart..."
sudo mkdir -p /var/www/html/opencart
sudo unzip -q opencart.zip -d /var/www/html/opencart

if [ ! -d "/var/www/html/opencart/upload" ]; then
  echo "❌ Folder upload tidak ditemukan di /var/www/html/opencart"
  exit 1
fi

echo "📁 Moving files from upload to /var/www/html/opencart root..."
sudo mv /var/www/html/opencart/upload/* /var/www/html/opencart/
sudo mv /var/www/html/opencart/upload/.* /var/www/html/opencart/ 2>/dev/null || true  # pindahkan file tersembunyi kalau ada
sudo rm -rf /var/www/html/opencart/upload

echo "📝 Copying config files..."
sudo cp /var/www/html/opencart/config-dist.php /var/www/html/opencart/config.php
sudo cp /var/www/html/opencart/admin/config-dist.php /var/www/html/opencart/admin/config.php

echo "🔧 Setting permissions..."
sudo chown -R www-data:www-data /var/www/html/opencart
sudo chmod -R 755 /var/www/html/opencart

echo "⚙️ Enabling Apache mod_rewrite and restarting apache..."
sudo a2enmod rewrite
sudo systemctl restart apache2

echo "🧹 Cleaning up..."
rm -f opencart.zip

echo "✅ OpenCart ${OPENCART_VERSION} installed successfully!"
echo "🌐 Access it via: http://your-server-ip/opencart"
