#!/bin/bash
# Script to completely destroy all Docker containers, images, and volumes for this project
# WARNING: This will delete ALL data including database!

# Get the project root directory (1 level up from this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Change to project root directory
cd "$PROJECT_ROOT"

echo "⚠️  WARNING: This will completely destroy the Magento project!"
echo "============================================================"
echo "This will remove:"
echo "  - All Docker containers"
echo "  - All Docker images"
echo "  - All Docker volumes (INCLUDING DATABASE!)"
echo "  - All networks"
echo ""
read -p "Are you sure? Type 'yes' to continue: " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "🛑 Stopping all containers..."
docker compose down

echo ""
echo "🗑️  Removing all containers..."
docker compose rm -f -s -v

echo ""
echo "💾 Removing all volumes..."
docker volume rm mgthemes_mysql_data mgthemes_opensearch_data mgthemes_redis_data mgthemes_composer_cache 2>/dev/null || true

echo ""
echo "🌐 Removing networks..."
docker network rm mgthemes_network 2>/dev/null || true

echo ""
echo "🖼️  Removing custom images..."
docker rmi mgthemes-mgthemes_php 2>/dev/null || true

echo ""
echo "🧹 Cleaning up dangling images..."
docker image prune -f

echo ""
echo "✅ Project destroyed successfully!"
echo ""
echo "To recreate the project, run:"
echo "  ./bin/start-dev.sh"
echo ""
