#!/bin/bash
set -e

# -------------------------------
# CONFIGURATION
# -------------------------------
APP_DIR="$HOME/multiuser-blog"
REPO_HTTPS="https://github.com/nafiurrashid/multiuser-blog.git"
DB_NAME="laravel_db"
DB_USER="laravel_user"
DB_PASS="secret"
PORT=8000

# -------------------------------
# Install PHP 8.0 and Required Packages
# -------------------------------
echo "🔄 Installing PHP 8.0 and required packages..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.0 php8.0-cli php8.0-mbstring php8.0-xml php8.0-bcmath php8.0-curl php8.0-mysql unzip curl git mysql-server
sudo update-alternatives --set php /usr/bin/php8.0
php -v

# -------------------------------
# Install Composer
# -------------------------------
echo "📦 Installing Composer..."
cd ~
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer --version

# -------------------------------
# Configure MySQL
# -------------------------------
echo "🗃️ Setting up MySQL database and user..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
sudo mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# -------------------------------
# Clone Laravel Project (via HTTPS)
# -------------------------------
echo "📁 Cloning Laravel project from GitHub (HTTPS)..."
rm -rf $APP_DIR
git clone $REPO_HTTPS $APP_DIR
cd $APP_DIR

# -------------------------------
# Install Laravel Dependencies
# -------------------------------
echo "📦 Installing Laravel PHP packages..."
composer install

# -------------------------------
# Environment Setup
# -------------------------------
echo "⚙️ Setting up .env and generating app key..."
cp .env.example .env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_NAME}/" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USER}/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASS}/" .env
php artisan key:generate

# -------------------------------
# Run Migrations
# -------------------------------
echo "🗃️ Running database migrations..."
php artisan migrate --force

# -------------------------------
# Set Permissions
# -------------------------------
echo "🔧 Setting correct file permissions..."
chmod -R 775 storage bootstrap/cache

# -------------------------------
# Start Laravel Development Server
# -------------------------------
echo "🚀 Starting Laravel at http://localhost:$PORT ..."
php artisan serve --host=0.0.0.0 --port=$PORT
