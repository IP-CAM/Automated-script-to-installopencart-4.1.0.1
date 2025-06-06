#!/bin/bash
set -e

# Konfigurasi database
DB_NAME="opencart"
DB_USER="opencart_user"
DB_PASS="StrongPassword123!"

# Versi OpenCart
OPENCART_VERSION="4.1.0.1"

echo "===== Memulai instalasi OpenCart v${OPENCART_VERSION} ====="

echo "1. Update sistem dan install dependencies"
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql php-zip php-gd php-mbstring php-curl php-xml unzip wget

echo "2. Mulai dan aktifkan service Apache dan MySQL"
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl enable mysql
sudo systemctl start mysql

echo "3. Membuat database dan user MySQL"
echo "   - Menghapus database lama jika ada"
sudo mysql -e "DROP DATABASE IF EXISTS ${DB_NAME};" 2>&1 | tee /tmp/mysql_drop_db.log
echo "   - Menghapus user lama jika ada"
sudo mysql -e "DROP USER IF EXISTS '${DB_USER}'@'localhost';" 2>&1 | tee /tmp/mysql_drop_user.log
echo "   - Membuat database baru"
sudo mysql -e "CREATE DATABASE ${DB_NAME};" 2>&1 | tee /tmp/mysql_create_db.log
echo "   - Membuat user baru dan set password"
sudo mysql -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';" 2>&1 | tee /tmp/mysql_create_user.log
echo "   - Berikan hak akses penuh ke user pada database"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';" 2>&1 | tee /tmp/mysql_grant_priv.log
sudo mysql -e "FLUSH PRIVILEGES;" 2>&1 | tee /tmp/mysql_flush_priv.log

echo "4. Download OpenCart versi ${OPENCART_VERSION}"
wget -q https://github.com/opencart/opencart/releases/download/${OPENCART_VERSION}/opencart-${OPENCART_VERSION}.zip -O opencart.zip
echo "   File opencart.zip berhasil didownload"

echo "5. Ekstrak file OpenCart ke /var/www/html/opencart"
sudo mkdir -p /var/www/html/opencart
sudo unzip -o opencart.zip -d /var/www/html/opencart 2>&1 | tee /tmp/unzip_opencart.log

echo "6. Pindahkan isi folder upload ke /var/www/html/opencart"
sudo mv /var/www/html/opencart/upload/* /var/www/html/opencart/
sudo mv /var/www/html/opencart/upload/.* /var/www/html/opencart/ 2>/dev/null || true
sudo rm -rf /var/www/html/opencart/upload

echo "7. Copy file konfigurasi contoh ke file konfigurasi utama"
sudo cp /var/www/html/opencart/config-dist.php /var/www/html/opencart/config.php
sudo cp /var/www/html/opencart/admin/config-dist.php /var/www/html/opencart/admin/config.php

echo "8. Set permission folder /var/www/html/opencart"
sudo chown -R www-data:www-data /var/www/html/opencart
sudo find /var/www/html/opencart/ -type d -exec chmod 755 {} \;
sudo find /var/www/html/opencart/ -type f -exec chmod 644 {} \;

echo "9. Enable Apache mod_rewrite dan restart Apache"
sudo a2enmod rewrite
sudo systemctl restart apache2

echo "10. Bersihkan file zip yang sudah tidak diperlukan"
rm -f opencart.zip

echo "===== Instalasi OpenCart selesai! ====="
echo "Akses OpenCart melalui http://<IP-atau-Domain-Server>/opencart"
echo "Database Name: ${DB_NAME}"
echo "Database User: ${DB_USER}"
echo "Database Password: ${DB_PASS}"

exit 0
