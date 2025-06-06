# OpenCart 4.1.0.1 Auto Installer

This repository provides an automated script to install OpenCart 4.1.0.1 on a VPS with a LAMP stack (Linux, Apache, MySQL, PHP).

## Features
- Automated installation of LAMP stack.
- Automatic database and user setup (will replace if already exists).
- Fully sets up OpenCart files and permissions.
- Prepares system for web-based OpenCart installation wizard.

## Prerequisites
- A fresh VPS running Ubuntu/Debian.
- Root or sudo access.

## Usage
1. Run the installation script:
   ```sh
   wget -qO- https://raw.githubusercontent.com/syvaira/opencart-4.1.0.1/main/auto-install.sh | sudo bash
   ```

2. During installation, follow the prompts for **MySQL Secure Installation**:

   * You can skip password setting if using `auth_socket`.
   * Recommended to remove anonymous users, disallow remote root login, and remove test database.

## Post Installation

After running the script:

1. Move OpenCart files from `upload/` to root:

   ```bash
   sudo mv /var/www/html/opencart/upload/* /var/www/html/opencart/
   sudo rm -r /var/www/html/opencart/upload
   ```

2. Copy configuration files:

   ```bash
   sudo cp /var/www/html/opencart/config-dist.php /var/www/html/opencart/config.php
   sudo cp /var/www/html/opencart/admin/config-dist.php /var/www/html/opencart/admin/config.php
   ```

3. Set file permissions:

   ```bash
   sudo chown -R www-data:www-data /var/www/html/opencart
   sudo chmod -R 755 /var/www/html/opencart
   ```

4. (Optional) Setup Apache virtual host:

   ```bash
   sudo nano /etc/apache2/sites-available/opencart.conf
   ```

   Add the following:

   ```apache
   <VirtualHost *:80>
       ServerAdmin webmaster@localhost
       DocumentRoot /var/www/html/opencart
       ServerName opencart.local

       <Directory /var/www/html/opencart/>
           Options Indexes FollowSymLinks
           AllowOverride All
           Require all granted
       </Directory>

       ErrorLog ${APACHE_LOG_DIR}/opencart_error.log
       CustomLog ${APACHE_LOG_DIR}/opencart_access.log combined
   </VirtualHost>
   ```

   Then enable and reload:

   ```bash
   sudo a2ensite opencart.conf
   sudo a2enmod rewrite
   sudo systemctl reload apache2
   ```

   Add to `/etc/hosts`:

   ```bash
   echo "127.0.0.1 opencart.local" | sudo tee -a /etc/hosts
   ```

5. Access your OpenCart installation:

   * Via browser: `http://your-server-ip/opencart/` or `http://opencart.local/`
   * Follow the OpenCart web installer steps.

6. After successful installation, remove the `install/` directory:

   ```bash
   sudo rm -rf /var/www/html/opencart/install
   ```

7. Login to the admin dashboard:

   * `http://your-server-ip/opencart/admin/` or `http://opencart.local/admin/`

## Notes

* Default MySQL credentials created by the script:

  * **Database:** `opencart`
  * **Username:** `opencart_user`
  * **Password:** `StrongPasswordHere`
* For security, change the database password in the script before use.
* Adjust Apache configs if using a custom domain.
