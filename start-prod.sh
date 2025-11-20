#!/bin/bash
# Script to start Production environment

echo "🚀 Starting Production Environment..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found. Please create it from .env.example"
    exit 1
fi

# Validate production environment variables
if grep -q "change_me" .env; then
    echo "❌ Please update all passwords in .env before starting production!"
    exit 1
fi

# Stop any running containers
echo "🛑 Stopping existing containers..."
docker compose -f docker-compose.yml -f docker-compose.prod.yml down

# Build and start production environment
echo "🔨 Building and starting containers..."
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 15

# Show status
echo "📊 Container Status:"
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps

echo ""
echo "✅ Production environment is ready!"
echo "🌐 Website: https://mgthemes.info"
echo ""
echo "⚠️  Important security reminders:"
echo "   1. Ensure firewall is properly configured"
echo "   2. SSL certificates are configured in docker/ssl/"
echo "   3. Database passwords are strong and secure"
echo "   4. phpMyAdmin is only accessible from localhost"
