#!/bin/bash

echo "=========================================="
echo "  Distributed Database CRUD System"
echo "  Starting up..."
echo "=========================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running!"
    echo ""
    echo "Please start Docker Desktop and try again."
    echo "On macOS: Open 'Docker Desktop' from Applications"
    echo "On Linux: sudo systemctl start docker"
    echo ""
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down -v 2>/dev/null
echo ""

# Build and start all services
echo "🚀 Building and starting all services..."
docker-compose up --build -d

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Failed to start services"
    exit 1
fi

echo ""
echo "⏳ Waiting for databases to initialize..."
echo "   This may take 30-60 seconds..."
echo ""

# Wait for databases to be ready
for i in {1..60}; do
    if docker-compose exec -T db11 pg_isready -U user11 > /dev/null 2>&1 && \
       docker-compose exec -T db12 pg_isready -U user12 > /dev/null 2>&1 && \
       docker-compose exec -T db21 pg_isready -U user21 > /dev/null 2>&1 && \
       docker-compose exec -T db22 pg_isready -U user22 > /dev/null 2>&1; then
        echo "✅ All databases are ready!"
        break
    fi
    echo -n "."
    sleep 1
done

echo ""
echo ""

# Check backend
echo "🔍 Checking backend service..."
sleep 5

if curl -s http://localhost:5000/ > /dev/null; then
    echo "✅ Backend is running on http://localhost:5000"
else
    echo "⚠️  Backend may still be starting..."
    echo "   Check logs with: docker-compose logs backend"
fi

echo ""
echo "=========================================="
echo "  System is ready!"
echo "=========================================="
echo ""
echo "📊 Services:"
echo "   - DB11 (Spatial 1-5):    localhost:5011"
echo "   - DB12 (Spatial 6-10):   localhost:5012"
echo "   - DB21 (Business 1-5):   localhost:5021"
echo "   - DB22 (Business 6-10):  localhost:5022"
echo "   - Backend API:           http://localhost:5000"
echo "   - Frontend:              http://localhost:8088"
echo ""
echo "🧪 Test the system:"
echo "   python test_crud.py"
echo ""
echo "📖 View logs:"
echo "   docker-compose logs -f backend"
echo ""
echo "🛑 Stop all services:"
echo "   docker-compose down"
echo ""
