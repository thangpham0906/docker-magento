#!/bin/bash
# Script to install Magento 2.4.8-p3

echo "📦 Magento 2.4.8-p3 Installation Script"
echo "========================================"

# Check if running inside container
if [ ! -f /.dockerenv ]; then
    echo "⚠️  This script should be run inside the PHP container"
    echo "Run: docker compose exec mgthemes_php bash"
    echo "Then run: bash /var/www/html/install-magento.sh"
    exit 1
fi

# Check if Magento is already installed
if [ -f "/var/www/html/app/etc/env.php" ]; then
    echo "⚠️  Magento appears to be already installed."
    read -p "Do you want to reinstall? (yes/no): " REINSTALL
    if [ "$REINSTALL" != "yes" ]; then
        exit 0
    fi
fi

# Load environment variables (if available)
if [ -f "/var/www/html/.env" ]; then
    source /var/www/html/.env
fi

# Set default values if not in .env
MAGENTO_BASE_URL=${MAGENTO_BASE_URL:-http://mgthemes.local/}
MAGENTO_BACKEND_FRONTNAME=${MAGENTO_BACKEND_FRONTNAME:-admin}
MAGENTO_ADMIN_FIRSTNAME=${MAGENTO_ADMIN_FIRSTNAME:-Admin}
MAGENTO_ADMIN_LASTNAME=${MAGENTO_ADMIN_LASTNAME:-User}
MAGENTO_ADMIN_EMAIL=${MAGENTO_ADMIN_EMAIL:-admin@mgthemes.info}
MAGENTO_ADMIN_USER=${MAGENTO_ADMIN_USER:-admin}
MAGENTO_ADMIN_PASSWORD=${MAGENTO_ADMIN_PASSWORD:-Admin@123456}

echo ""
echo "🔧 Installing Magento 2.4.8-p3..."
echo ""

cd /var/www/html

# Check if composer.json exists
if [ ! -f "composer.json" ]; then
    echo "📥 Creating Magento project via Composer..."
    
    # Ask for Magento credentials
    echo "Please enter your Magento Marketplace credentials:"
    read -p "Public Key: " COMPOSER_USER
    read -sp "Private Key: " COMPOSER_PASS
    echo ""
    
    # Configure Composer authentication
    composer config -g http-basic.repo.magento.com "$COMPOSER_USER" "$COMPOSER_PASS"
    
    # Create Magento project
    composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.8-p3 .
fi

echo ""
echo "⚙️  Running Magento setup:install..."
echo ""

php bin/magento setup:install \
    --base-url="$MAGENTO_BASE_URL" \
    --db-host=mgthemes_mysql \
    --db-name="${MYSQL_DATABASE:-magento}" \
    --db-user="${MYSQL_USER:-magento}" \
    --db-password="${MYSQL_PASSWORD:-magento}" \
    --admin-firstname="$MAGENTO_ADMIN_FIRSTNAME" \
    --admin-lastname="$MAGENTO_ADMIN_LASTNAME" \
    --admin-email="$MAGENTO_ADMIN_EMAIL" \
    --admin-user="$MAGENTO_ADMIN_USER" \
    --admin-password="$MAGENTO_ADMIN_PASSWORD" \
    --language=en_US \
    --currency=USD \
    --timezone=Asia/Ho_Chi_Minh \
    --use-rewrites=1 \
    --search-engine=opensearch \
    --opensearch-host=mgthemes_opensearch \
    --opensearch-port=9200 \
    --opensearch-index-prefix=magento2 \
    --opensearch-enable-auth=0 \
    --session-save=redis \
    --session-save-redis-host=mgthemes_redis \
    --session-save-redis-port=6379 \
    --session-save-redis-db=2 \
    --cache-backend=redis \
    --cache-backend-redis-server=mgthemes_redis \
    --cache-backend-redis-db=0 \
    --page-cache=redis \
    --page-cache-redis-server=mgthemes_redis \
    --page-cache-redis-db=1 \
    --backend-frontname="$MAGENTO_BACKEND_FRONTNAME"

echo ""
echo "🔐 Setting permissions..."
find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
chown -R www-data:www-data .
chmod u+x bin/magento

echo ""
echo "🎨 Deploying static content..."
php bin/magento setup:static-content:deploy -f

echo ""
echo "📊 Reindexing..."
php bin/magento indexer:reindex

echo ""
echo "🧹 Clearing cache..."
php bin/magento cache:flush

echo ""
echo "✅ Magento installation completed!"
echo ""
echo "🌐 Frontend: $MAGENTO_BASE_URL"
echo "🔧 Admin Panel: ${MAGENTO_BASE_URL}${MAGENTO_BACKEND_FRONTNAME}"
echo "👤 Admin User: $MAGENTO_ADMIN_USER"
echo "🔑 Admin Password: $MAGENTO_ADMIN_PASSWORD"
echo ""
