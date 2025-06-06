#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# Konfigurasi
readonly OPENCART_VERSION="4.1.0.1"
readonly INSTALL_DIR="/var/www/html/opencart"

read -rp "🛡 Masukkan password untuk MySQL user 'opencart_user': " DB_PASS

readonly DB_NAME="opencart"
readonly DB_USER="opencart_user"

LOG_FILE="$(mktemp)"
trap 'echo "❌ Terjadi kesalahan. Cek log: $LOG_FILE" >&2' ERR

echo "📄 Logging ke $LOG_FILE..."

{
echo "🔄 Update sistem & install dependensi..."
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y apache2 mysql-server php libapache2-mod-php \
  php-mysql php-zip php-gd php-mbstring php-curl php-xml unzip wget

echo "🛠 Start & enable Apache & MySQL..."
sudo systemctl enable --now apache2
sudo systemctl enable --now mysql

echo "🔒 Konfigurasi database MySQL..."
sudo mysql <<MYSQL
DROP DATABASE IF EXISTS ${DB_NAME};
DROP USER IF EXISTS '${DB_USER}'@'localhost';
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL

echo "⬇️ Download OpenCart versi ${OPENCART_VERSION}..."
wget -q https://github.com/opencart/opencart/releases/download/${OPENCART_VERSION}/opencart-${OPENCART_VERSION}.zip

echo "📦 Ekstrak file OpenCart..."
unzip -q opencart-${OPENCART_VERSION}.zip
[[ -d "upload" ]] || { echo "❌ Folder 'upload' tidak ditemukan."; exit 1; }

echo "📁 Pindahkan file ke ${INSTALL_DIR}..."
sudo mkdir -p "$INSTALL_DIR"
sudo mv upload/* "$INSTALL_DIR"
sudo cp "$INSTALL_DIR/config-dist.php" "$INSTALL_DIR/config.php"
sudo cp "$INSTALL_DIR/admin/config-dist.php" "$INSTALL_DIR/admin/config.php"

echo "🔧 Set permission yang sesuai..."
sudo chown -R www-data:www-data "$INSTALL_DIR"
sudo find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
sudo find "$INSTALL_DIR" -type f -exec chmod 644 {} \;

echo "⚙️ Aktifkan mod_rewrite & konfigurasi Apache AllowOverride..."
sudo a2enmod rewrite

APACHE_CONF="/etc/apache2/sites-available/000-default.conf"
if ! grep -q "AllowOverride All" "$APACHE_CONF"; then
  sudo sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' "$APACHE_CONF"
fi

echo "🔄 Restart Apache untuk menerapkan perubahan..."
sudo systemctl restart apache2

echo "🧹 Bersihkan file sementara..."
rm -rf upload
rm -f "opencart-${OPENCART_VERSION}.zip"

IP_ADDR=$(hostname -I | awk '{print $1}')
echo -e "\n✅ OpenCart ${OPENCART_VERSION} berhasil dipasang!"
echo "🌐 Akses di: http://${IP_ADDR}/opencart"
echo "🚀 Lanjutkan konfigurasi di browser Anda."

} | tee "$LOG_FILE"
