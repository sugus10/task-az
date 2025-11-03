#!/bin/bash

# Build and test the containerized application locally

echo "🐳 Building and Testing Containerized Azure CRUD App"
echo "===================================================="

# Build the Docker image
echo "Building Docker image..."
docker build -t azure-crud-app:latest .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully!"
else
    echo "❌ Docker build failed!"
    exit 1
fi

# Stop any existing container
echo "Stopping any existing containers..."
docker stop azure-crud-app 2>/dev/null || true
docker rm azure-crud-app 2>/dev/null || true

# Run the container
echo "Starting container..."
docker run -d \
    --name azure-crud-app \
    -p 8000:8000 \
    azure-crud-app:latest

if [ $? -eq 0 ]; then
    echo "✅ Container started successfully!"
else
    echo "❌ Container failed to start!"
    exit 1
fi

# Wait for container to be ready
echo "Waiting for application to start..."
sleep 10

# Test the application
echo ""
echo "🧪 Testing the application..."
echo "=============================="

# Test health endpoint
echo "Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:8000/health)
echo "Health check: $HEALTH_RESPONSE"

# Test main page
echo ""
echo "Testing main page..."
MAIN_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/)
echo "Main page status: $MAIN_RESPONSE"

# Test API endpoint
echo ""
echo "Testing API endpoint..."
API_RESPONSE=$(curl -s http://localhost:8000/api/items)
echo "API response: $API_RESPONSE"

# Show container logs
echo ""
echo "📋 Container logs:"
echo "=================="
docker logs azure-crud-app --tail 20

echo ""
echo "🌐 Application URLs:"
echo "==================="
echo "Main app: http://localhost:8000"
echo "Health check: http://localhost:8000/health"
echo "API: http://localhost:8000/api/items"
echo "Info: http://localhost:8000/info"

echo ""
echo "🐳 Container commands:"
echo "====================="
echo "View logs: docker logs azure-crud-app"
echo "Stop container: docker stop azure-crud-app"
echo "Remove container: docker rm azure-crud-app"
echo "List images: docker images"

echo ""
echo "✅ Local testing complete! Open http://localhost:8000 in your browser"