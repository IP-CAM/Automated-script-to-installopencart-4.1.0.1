# 🛒 OpenCart Auto Installer (v4.1.0.1)

Skrip Bash otomatis untuk menginstal **OpenCart versi 4.1.0.1** di server Ubuntu 22.04+ dengan stack **LAMP (Linux, Apache, MySQL, PHP)** lengkap, termasuk konfigurasi permission, database, Apache rewrite, dan firewall (UFW).

---

## 🚀 Fitur

- Install semua dependensi yang dibutuhkan
- Konfigurasi MySQL otomatis (DB, user, privileges)
- Download & ekstrak OpenCart dari GitHub resmi
- Setup direktori, permission, dan config file
- Enable `mod_rewrite` dan konfigurasi `.htaccess`
- Buka port firewall HTTP/HTTPS otomatis (UFW)
- Cleanup otomatis setelah instalasi
- Siap lanjut instalasi via browser dalam sekali jalan

---

## 🧰 Requirements

- Ubuntu 22.04 atau lebih baru
- Akses root atau `sudo`
- Server dengan akses internet aktif

---

## 📥 Cara Pakai

```bash
wget -qO- https://raw.githubusercontent.com/syvaira/opencart-4.1.0.1/main/auto-install.sh | sudo bash
````

Skrip akan:

* Menghapus instalasi OpenCart sebelumnya (jika ada)
* Menyiapkan database `opencart` dan user `opencart_user`
* Men-deploy file OpenCart ke `/var/www/html/opencart`

---

## ⚙️ Konfigurasi Default

> Kamu bisa mengedit di bagian atas skrip (`auto-install.sh`) jika ingin menyesuaikan:

```bash
OPENCART_VERSION="4.1.0.1"
INSTALL_DIR="/var/www/html/opencart"
DB_NAME="opencart"
DB_USER="opencart_user"
DB_PASS="GantiPasswordKuat123"
```

---

## 🌐 Akses Setelah Instalasi

Jika sukses, akan muncul:

```bash
✅ OpenCart 4.1.0.1 berhasil diinstal!
🌐 Akses via: http://<IP_SERVER>/opencart
🚀 Lanjutkan instalasi via browser.
```

> Ganti `<IP_SERVER>` dengan alamat IP publik atau domain server kamu.

---

## 🔒 Langkah Setelah Instalasi Web

1. Akses `http://<IP>/opencart`
2. Ikuti wizard instalasi melalui browser (License → Pre-install Check → Configuration)
3. Setelah selesai:

   ```bash
   sudo rm -rf /var/www/html/opencart/install
   sudo chmod 644 /var/www/html/opencart/config.php
   sudo chmod 644 /var/www/html/opencart/admin/config.php
   ```

---

## 📂 Lokasi Penting

* **Frontend**: `http://<IP>/opencart`
* **Admin Panel**: `http://<IP>/opencart/admin`

---

## 👨‍💻 Credit

Dibuat oleh: [Syvaira](https://github.com/syvaira)
Untuk: Infrastruktur cepat & efisien deploy OpenCart.
