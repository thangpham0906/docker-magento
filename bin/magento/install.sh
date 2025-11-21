#!/bin/bash
# Script to install Magento 2.4.8-p3
# Run this script from the HOST machine (not inside container)

# Get the project root directory (2 levels up from this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "📦 Magento 2.4.8-p3 Installation Script"
echo "========================================"
echo "Project root: $PROJECT_ROOT"
echo ""

# Change to project root directory
cd "$PROJECT_ROOT"

# Load .env file if exists
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Set default values if not in .env
MAGENTO_BASE_URL=${MAGENTO_BASE_URL:-http://mgthemes.localhost/}
MAGENTO_BACKEND_FRONTNAME=${MAGENTO_BACKEND_FRONTNAME:-admin}
MAGENTO_ADMIN_FIRSTNAME=${MAGENTO_ADMIN_FIRSTNAME:-Admin}
MAGENTO_ADMIN_LASTNAME=${MAGENTO_ADMIN_LASTNAME:-User}
MAGENTO_ADMIN_EMAIL=${MAGENTO_ADMIN_EMAIL:-admin@mgthemes.info}
MAGENTO_ADMIN_USER=${MAGENTO_ADMIN_USER:-admin}
MAGENTO_ADMIN_PASSWORD=${MAGENTO_ADMIN_PASSWORD:-Admin@123456}
COMPOSER_USER=${COMPOSER_AUTH_USERNAME:-your_public_key}
COMPOSER_PASS=${COMPOSER_AUTH_PASSWORD:-your_private_key}

echo ""
echo "🔧 Installing Magento 2.4.8-p3..."
echo ""

# Check if composer.json exists in src/
if [ ! -f "./src/composer.json" ]; then
    echo "📥 Creating Magento project via Composer..."
    
    echo "Using Magento Marketplace credentials:"
    echo "Public Key: $COMPOSER_USER"
    
    # Clean src directory completely
    echo "🧹 Cleaning src directory..."
    sudo rm -rf ./src/*
    sudo rm -rf ./src/.[!.]*
    
    # Configure Composer authentication and create project in container
    docker compose exec -T mgthemes_php bash -c "
        cd /var/www/html && \
        composer config -g http-basic.repo.magento.com '$COMPOSER_USER' '$COMPOSER_PASS' && \
        composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.8-p3 . --no-interaction
    "

    echo ""
    echo "⚙️  Running Magento setup:install..."
    echo ""

    # Run Magento setup in container (with xdebug disabled for performance)
    docker compose exec -T -e XDEBUG_MODE=off mgthemes_php bash -c "
        cd /var/www/html && \
        php bin/magento setup:install \
            --base-url='$MAGENTO_BASE_URL' \
            --db-host=mgthemes_mysql \
            --db-name='${MYSQL_DATABASE:-magento}' \
            --db-user='${MYSQL_USER:-magento}' \
            --db-password='${MYSQL_PASSWORD:-magento}' \
            --admin-firstname='$MAGENTO_ADMIN_FIRSTNAME' \
            --admin-lastname='$MAGENTO_ADMIN_LASTNAME' \
            --admin-email='$MAGENTO_ADMIN_EMAIL' \
            --admin-user='$MAGENTO_ADMIN_USER' \
            --admin-password='$MAGENTO_ADMIN_PASSWORD' \
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
            --backend-frontname='$MAGENTO_BACKEND_FRONTNAME'
    "

    # add file auth.json
    echo ""
    echo "📄 Creating auth.json for Composer authentication..."
    docker compose exec -T mgthemes_php bash -c "
        cd /var/www/html && \
        echo '{\"http-basic\": {\"repo.magento.com\": {\"username\": \"$COMPOSER_USER\", \"password\": \"$COMPOSER_PASS\"}}}' > auth.json && \
        chmod 600 auth.json
    "

    # datasample installation can be added here if needed
    bin/magento sampledata:deploy

else
    echo "⚠️  Magento already installed (composer.json exists)"
    echo ""
    echo "To reinstall, run: rm -rf ./src/* && ./bin/magento/install.sh"
    exit 0
fi

echo ""
echo "🔐 Setting permissions..."
docker compose exec -T -e XDEBUG_MODE=off mgthemes_php bash -c "
    cd /var/www/html && \
    find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + 2>/dev/null || true && \
    find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + 2>/dev/null || true && \
    chown -R www-data:www-data . && \
    chmod u+x bin/magento
"

echo ""
echo "🎨 Deploying static content..."
docker compose exec -T -e XDEBUG_MODE=off mgthemes_php bash -c "
    cd /var/www/html && \
    php bin/magento setup:static-content:deploy -f
"

echo ""
echo "📊 Reindexing..."
docker compose exec -T -e XDEBUG_MODE=off mgthemes_php bash -c "
    cd /var/www/html && \
    php bin/magento indexer:reindex
"

echo ""
echo "🧹 Clearing cache..."
docker compose exec -T -e XDEBUG_MODE=off mgthemes_php bash -c "
    cd /var/www/html && \
    php bin/magento cache:flush
"

echo ""
echo "✅ Magento installation completed!"
echo ""
echo "🌐 Frontend: $MAGENTO_BASE_URL"
echo "🔧 Admin Panel: ${MAGENTO_BASE_URL}${MAGENTO_BACKEND_FRONTNAME}"
echo "👤 Admin User: $MAGENTO_ADMIN_USER"
echo "🔑 Admin Password: $MAGENTO_ADMIN_PASSWORD"
echo ""
