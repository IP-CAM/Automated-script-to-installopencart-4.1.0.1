#!/bin/bash

# Set OpenCart version
OPENCART_VERSION="4.1.0.1" # Versi terbaru

# Update system and install dependencies
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql php-zip php-gd php-mbstring php-curl php-xml unzip wget

# Set up MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure MySQL installation
sudo mysql_secure_installation

# Create OpenCart database and user
DB_NAME="opencart"
DB_USER="opencart_user"
DB_PASS="StrongPasswordHere"

sudo mysql -e "DROP DATABASE IF EXISTS ${DB_NAME};"
sudo mysql -e "DROP USER IF EXISTS '${DB_USER}'@'localhost';"
sudo mysql -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Download OpenCart
wget https://github.com/opencart/opencart/releases/download/${OPENCART_VERSION}/opencart-${OPENCART_VERSION}.zip
sudo unzip opencart-${OPENCART_VERSION}.zip -d /var/www/html/opencart

# Set permissions
sudo chown -R www-data:www-data /var/www/html/opencart
sudo chmod -R 755 /var/www/html/opencart

# Set up Apache
sudo a2enmod rewrite
sudo systemctl restart apache2

# Clean up
rm opencart-${OPENCART_VERSION}.zip

# Output
echo "OpenCart ${OPENCART_VERSION} has been installed successfully!"
