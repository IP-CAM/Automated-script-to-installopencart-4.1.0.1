#!/bin/bash

# Set OpenCart version
OPENCART_VERSION="4.1.0.1"

# Database configuration
DB_NAME="opencart"
DB_USER="opencart_user"
DB_PASS="StrongPasswordHere" # Ganti sesuai kebutuhan!

# Update and install dependencies
echo "🔄 Updating system and installing dependencies..."
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql php-zip php-gd php-mbstring php-curl php-xml unzip wget

# Start and enable Apache & MySQL
sudo systemctl enable apache2
sudo systemctl enable mysql
sudo systemctl start apache2
sudo systemctl start mysql

# Run MySQL secure installation
echo "🔒 Running MySQL secure installation..."
sudo mysql_secure_installation

# Setup MySQL database and user
echo "🛠️ Creating MySQL database and user..."
sudo mysql -e "DROP DATABASE IF EXISTS ${DB_NAME};"
sudo mysql -e "DROP USER IF EXISTS '${DB_USER}'@'localhost';"
sudo mysql -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Download OpenCart
echo "⬇️ Downloading OpenCart ${OPENCART_VERSION}..."
wget https://github.com/opencart/opencart/releases/download/${OPENCART_VERSION}/opencart-${OPENCART_VERSION}.zip

# Unzip and prepare files
echo "📦 Extracting OpenCart files..."
unzip opencart-${OPENCART_VERSION}.zip
if [ ! -d "upload" ]; then
  echo "❌ Gagal extract: folder 'upload' tidak ditemukan."
  exit 1
fi

# Move files to Apache root
echo "📁 Setting up files in /var/www/html/opencart..."
sudo mkdir -p /var/www/html/opencart
sudo mv upload/* /var/www/html/opencart/
sudo cp upload/config-dist.php /var/www/html/opencart/config.php
sudo cp upload/admin/config-dist.php /var/www/html/opencart/admin/config.php

# Set permissions
sudo chown -R www-data:www-data /var/www/html/opencart
sudo chmod -R 755 /var/www/html/opencart

# Enable Apache rewrite module
echo "⚙️ Enabling Apache mod_rewrite..."
sudo a2enmod rewrite
sudo systemctl restart apache2

# Cleanup
rm -rf upload
rm -f opencart-${OPENCART_VERSION}.zip

# Output
echo "✅ OpenCart ${OPENCART_VERSION} has been installed successfully!"
echo "🌐 Access it via: http://your-server-ip/opencart"
