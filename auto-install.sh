#!/bin/bash

set -e

OPENCART_VERSION="4.1.0.1"
DB_NAME="opencart"
DB_USER="opencart_user"
DB_PASS="StrongPasswordHere"  # Ganti sesuai kebutuhan

echo "🔄 Update system & install dependencies..."
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql php-zip php-gd php-mbstring php-curl php-xml unzip wget

echo "🛠 Start & enable Apache & MySQL..."
sudo systemctl enable apache2
sudo systemctl enable mysql
sudo systemctl start apache2
sudo systemctl start mysql

echo "🔒 Setup MySQL database & user..."
sudo mysql -e "DROP DATABASE IF EXISTS ${DB_NAME};"
sudo mysql -e "DROP USER IF EXISTS '${DB_USER}'@'localhost';"
sudo mysql -e "CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "⬇️ Download OpenCart ${OPENCART_VERSION}..."
wget -q https://github.com/opencart/opencart/releases/download/${OPENCART_VERSION}/opencart-${OPENCART_VERSION}.zip

echo "📦 Extract OpenCart files..."
unzip -q opencart-${OPENCART_VERSION}.zip
if [ ! -d "upload" ]; then
  echo "❌ Folder 'upload' tidak ditemukan. Gagal extract."
  exit 1
fi

echo "📁 Move files to /var/www/html/opencart..."
sudo mkdir -p /var/www/html/opencart
sudo mv upload/* /var/www/html/opencart/
sudo cp /var/www/html/opencart/config-dist.php /var/www/html/opencart/config.php
sudo cp /var/www/html/opencart/admin/config-dist.php /var/www/html/opencart/admin/config.php

echo "🔧 Set permission..."
sudo chown -R www-data:www-data /var/www/html/opencart
sudo find /var/www/html/opencart -type d -exec chmod 755 {} \;
sudo find /var/www/html/opencart -type f -exec chmod 644 {} \;

echo "⚙️ Enable Apache mod_rewrite & AllowOverride All..."
sudo a2enmod rewrite

APACHE_CONF="/etc/apache2/sites-available/000-default.conf"
if ! grep -q "AllowOverride All" $APACHE_CONF; then
  echo "Updating Apache config to AllowOverride All..."
  sudo sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' $APACHE_CONF
fi

echo "🔄 Restart Apache..."
sudo systemctl restart apache2

echo "🧹 Cleanup..."
rm -rf upload
rm -f opencart-${OPENCART_VERSION}.zip

echo "✅ OpenCart ${OPENCART_VERSION} installed!"
echo "🌐 Silakan akses di: http://$(hostname -I | awk '{print $1}')/opencart"
echo "🚀 Lanjutkan setup OpenCart via web browser."
