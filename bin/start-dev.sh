#!/bin/bash
# Script to start Development environment

echo "🚀 Starting Development Environment..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Copying from .env.example..."
    cp .env.example .env
    echo "✅ Please update .env with your settings before continuing."
    exit 1
fi

# Stop any running containers
echo "🛑 Stopping existing containers..."
docker compose down

# Build and start development environment
echo "🔨 Building and starting containers..."
docker compose up -d --build

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Show status
echo "📊 Container Status:"
docker compose ps

echo ""
echo "✅ Development environment is ready!"
echo "🌐 Website: http://mgthemes.localhost"
echo "🗄️  phpMyAdmin: http://localhost:8080"
echo "🔍 OpenSearch: http://localhost:9200"
echo ""
echo "📝 Next steps:"
echo "   1. Add 'mgthemes.localhost' to your /etc/hosts file pointing to 127.0.0.1"
echo "   2. Access the container: docker compose exec mgthemes_php bash"
echo "   3. Install Magento in the src/ directory"
