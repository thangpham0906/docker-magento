#!/bin/bash

# Get the project root directory (2 levels up from this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Change to project root directory
cd "$PROJECT_ROOT"

# Define deployment modes
DEFAULT_MODE=1
QUICK_MODE=2
FULL_MODE=3

# Ask user for deployment mode
echo "Choose deployment mode:"
echo "1 - Default (with cache cleaning)"
echo "2 - Quick (setup:upgrade, di:compile, static-content:deploy)"
echo "3 - Full (all commands including indexing)"
# read -p "Enter mode (1-3) [default: 1]: " deploy_mode
deploy_mode=$1

# Set default if empty
deploy_mode=${deploy_mode:-$DEFAULT_MODE}

# Conditional execution based on deployment mode
start_time=$(date +%s)
echo "Starting Magento 2 deployment process..."
echo "Project root: $PROJECT_ROOT"
echo ""

if [[ $deploy_mode -eq $QUICK_MODE ]]; then
    # Setup Upgrade
    echo "Running setup:upgrade..."
    docker compose exec -T -e XDEBUG_MODE=off mgthemes_php php bin/magento setup:upgrade

    # Dependency Injection Compilation
    echo "Compiling dependency injection configuration..."
    docker compose exec -T -e XDEBUG_MODE=off mgthemes_php php bin/magento setup:di:compile

    # Final Cache Flush
    echo "Final cache flush..."
    docker compose exec -T mgthemes_php php bin/magento cache:clean
    docker compose exec -T mgthemes_php php bin/magento cache:flush
elif [[ $deploy_mode -eq $FULL_MODE ]]; then
    # Setup Upgrade
    echo "Running setup:upgrade..."
    docker compose exec -T -e XDEBUG_MODE=off mgthemes_php php bin/magento setup:upgrade

    # Dependency Injection Compilation
    echo "Compiling dependency injection configuration..."
    docker compose exec -T -e XDEBUG_MODE=off mgthemes_php php bin/magento setup:di:compile

    # Deploy Static Content
    echo "Deploying static content..."
    docker compose exec -T -e XDEBUG_MODE=off mgthemes_php php bin/magento setup:static-content:deploy -f
#    docker compose exec -T -e XDEBUG_MODE=off mgthemes_php php bin/magento setup:static-content:deploy -f

    # Reindex
    echo "Reindexing..."
#    docker compose exec -T -e XDEBUG_MODE=off mgthemes_php php bin/magento indexer:reindex

    # Final Cache Flush
    echo "Final cache flush..."
    docker compose exec -T mgthemes_php php bin/magento cache:flush
    docker compose exec -T mgthemes_php php bin/magento cache:clean
else
    # Default mode - just clean cache
    echo "Running mode 1 - Default"
    echo "Cleaning cache..."
    docker compose exec -T mgthemes_php bash -c "cd /var/www/html && rm -rf pub/static/frontend/Laybyland/layup/* var/view_preprocessed pub/static/_cache/merged/*"
    docker compose exec -T mgthemes_php php bin/magento cache:flush
    docker compose exec -T mgthemes_php php bin/magento cache:clean
fi

echo "Deployment completed successfully!"
# Calculate execution time
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Total execution time: $execution_time seconds"
