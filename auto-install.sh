#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Konfigurasi
OPENCART_VERSION="4.1.0.1"
INSTALL_DIR="/var/www/html/opencart"
DB_NAME="opencart"
DB_USER="opencart_user"
DB_PASS="GantiPasswordKuat123"  # ← ganti sesuai kebutuhan

# Logging
echo "📄 Starting OpenCart ${OPENCART_VERSION} auto-install..."

# Update & Install
echo "🔄 Update sistem & install dependensi..."
export DEBIAN_FRONTEND=noninteractive
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y apache2 mysql-server php libapache2-mod-php \
  php-mysql php-zip php-gd php-mbstring php-curl php-xml unzip wget ufw

# Start Services
echo "🛠 Menjalankan & mengaktifkan Apache & MySQL..."
sudo systemctl is-active --quiet apache2 || sudo systemctl start apache2
sudo systemctl enable apache2

sudo systemctl is-active --quiet mysql || sudo systemctl start mysql
sudo systemctl enable mysql

# MySQL Setup
echo "🔒 Setup database & user MySQL..."
sudo mysql <<MYSQL
DROP DATABASE IF EXISTS ${DB_NAME};
DROP USER IF EXISTS '${DB_USER}'@'localhost';
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL

# Download OpenCart
echo "⬇️ Download OpenCart versi ${OPENCART_VERSION}..."
wget -q https://github.com/opencart/opencart/releases/download/${OPENCART_VERSION}/opencart-${OPENCART_VERSION}.zip

# Extract
echo "📦 Extract file OpenCart..."
rm -rf upload
unzip -oq opencart-${OPENCART_VERSION}.zip

# Deploy
echo "📁 Deploy ke direktori: ${INSTALL_DIR}..."
sudo rm -rf "$INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo mv upload/* "$INSTALL_DIR/"
sudo cp "$INSTALL_DIR/config-dist.php" "$INSTALL_DIR/config.php"
sudo cp "$INSTALL_DIR/admin/config-dist.php" "$INSTALL_DIR/admin/config.php"

# Permissions
echo "🔧 Set permission & ownership..."
sudo chown -R www-data:www-data "$INSTALL_DIR"
sudo find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
sudo find "$INSTALL_DIR" -type f -exec chmod 644 {} \;

# Apache mod_rewrite & AllowOverride
echo "⚙️ Konfigurasi Apache rewrite & .htaccess support..."
sudo a2enmod rewrite
APACHE_CONF="/etc/apache2/sites-available/000-default.conf"
sudo sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' "$APACHE_CONF"

# Firewall
echo "🛡️ Buka akses HTTP dan HTTPS di firewall (UFW)..."
sudo ufw allow 80/tcp > /dev/null || true
sudo ufw allow 443/tcp > /dev/null || true
sudo ufw --force enable > /dev/null || true

# Restart Apache
echo "🔄 Restart Apache..."
sudo systemctl restart apache2

# Cleanup
echo "🧹 Cleanup file sementara..."
rm -rf upload
rm -f opencart-${OPENCART_VERSION}.zip

# Output info
IP_ADDR=$(hostname -I | awk '{print $1}')
echo ""
echo "✅ OpenCart ${OPENCART_VERSION} berhasil diinstal!"
echo "🌐 Akses via: http://${IP_ADDR}/opencart"
echo "🚀 Lanjutkan instalasi via browser."
