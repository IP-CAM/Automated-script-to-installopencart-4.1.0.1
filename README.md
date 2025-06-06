# OpenCart 4.1.0.1 Auto Installer

This repository provides an automated script to install OpenCart 4.1.0.1 on a VPS with a LAMP stack (Linux, Apache, MySQL, PHP).

## Features
- Automated installation of LAMP stack.
- Automatic database creation and user setup (Database will be replaced if already exists).
- Easy and fast OpenCart installation.

## Prerequisites
- A fresh VPS running Ubuntu/Debian.
- Root or sudo access.

## Usage
1. Run the installation script:
   ```sh
   wget -qO- https://raw.githubusercontent.com/syvaira/opencart-4.1.0.1/main/auto-install.sh | sudo bash
   ```
2. Follow the prompts for MySQL secure installation.

## Post Installation
- Access your OpenCart installation via your server's IP address.
- Complete the web-based setup wizard for OpenCart.

## Notes
- Make sure to change the database password in the script for better security.
- Adjust Apache configurations if needed for custom domain setup.
