#!/bin/bash
echo "Starting Redis data generation..."

# Wait for Redis cluster to be ready
echo "⏳ Waiting for Redis cluster nodes..."
attempt=1
max_attempts=30

until nc -z redis1 7001 && nc -z redis2 7002 && nc -z redis3 7003 && \
      nc -z redis4 7004 && nc -z redis5 7005 && nc -z redis6 7006; do
    if [ $attempt -gt $max_attempts ]; then
        echo "❌ Timeout waiting for Redis nodes"
        exit 1
    fi
    echo "⏳ Waiting for Redis cluster... (Attempt $attempt/$max_attempts)"
    sleep 5
    attempt=$((attempt + 1))
done

echo "✅ Redis nodes are ready"

# Wait for cluster formation
echo "⏳ Waiting for cluster formation..."
sleep 30

# Run data generation
cd /app
echo "📊 Generating Redis data..."
node generate_redis_data.js

echo "✅ Redis data generation completed!"