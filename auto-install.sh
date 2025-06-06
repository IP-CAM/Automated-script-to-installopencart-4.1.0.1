#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Konfigurasi
OPENCART_VERSION="4.1.0.1"
INSTALL_DIR="/var/www/html/opencart"
DB_NAME="opencart"
DB_USER="opencart_user"
DB_PASS="StrongPasswordHere"  # bisa diganti via build args / template

echo "🔄 Update system & install dependencies..."
export DEBIAN_FRONTEND=noninteractive
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y apache2 mysql-server php libapache2-mod-php \
  php-mysql php-zip php-gd php-mbstring php-curl php-xml unzip wget

echo "🛠 Start & enable Apache & MySQL..."
sudo systemctl enable --now apache2
sudo systemctl enable --now mysql

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
rm -rf upload
unzip -oq opencart-${OPENCART_VERSION}.zip

echo "📁 Move files to ${INSTALL_DIR}..."
sudo rm -rf "$INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo mv upload/* "$INSTALL_DIR/"
sudo cp "$INSTALL_DIR/config-dist.php" "$INSTALL_DIR/config.php"
sudo cp "$INSTALL_DIR/admin/config-dist.php" "$INSTALL_DIR/admin/config.php"

echo "🔧 Set permission..."
sudo chown -R www-data:www-data "$INSTALL_DIR"
sudo find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
sudo find "$INSTALL_DIR" -type f -exec chmod 644 {} \;

echo "⚙️ Enable mod_rewrite & AllowOverride All..."
sudo a2enmod rewrite
APACHE_CONF="/etc/apache2/sites-available/000-default.conf"
sudo sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' "$APACHE_CONF"

echo "🔄 Restart Apache..."
sudo systemctl restart apache2

echo "🧹 Cleanup..."
rm -rf upload
rm -f opencart-${OPENCART_VERSION}.zip

IP_ADDR=$(hostname -I | awk '{print $1}')
echo "✅ OpenCart ${OPENCART_VERSION} terinstal!"
echo "🌐 Akses di: http://${IP_ADDR}/opencart"
echo "🚀 Lanjutkan instalasi via browser."
