#!/bin/bash
# Script to stop all Docker containers

ENV=${1:-dev}

echo "🛑 Stopping environment: $ENV"

if [ "$ENV" == "prod" ]; then
    docker compose -f docker-compose.yml -f docker-compose.prod.yml down
else
    docker compose down
fi

echo "✅ Containers stopped successfully!"
