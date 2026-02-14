#!/bin/bash

# Hamster Kombat Bot - Startup Script

echo "🐹 Starting Hamster Kombat Bot..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "Please create .env file from .env.example"
    cp .env.example .env
    echo "✅ Created .env file. Please edit it with your settings."
    exit 1
fi

# Load environment variables
export $(cat .env | xargs)

# Check if BOT_TOKEN is set
if [ "$BOT_TOKEN" = "your_bot_token_here" ]; then
    echo "❌ Please set your BOT_TOKEN in .env file"
    exit 1
fi

# Create necessary directories
mkdir -p backend/data
mkdir -p frontend/dist

echo "📦 Installing backend dependencies..."
cd backend
pip install -r requirements.txt > /dev/null 2>&1
cd ..

echo "📦 Installing frontend dependencies..."
cd frontend
npm install > /dev/null 2>&1
cd ..

echo "🏗️ Building frontend..."
cd frontend
npm run build > /dev/null 2>&1
cd ..

echo "🚀 Starting services..."

# Start API in background
echo "  • Starting API server on port 5000..."
cd backend
python api.py &
API_PID=$!
cd ..

# Wait for API to start
sleep 2

# Start Bot in background
echo "  • Starting Telegram Bot..."
cd backend
python bot.py &
BOT_PID=$!
cd ..

echo ""
echo "✅ All services started!"
echo ""
echo "📊 Services:"
echo "  • API: http://localhost:5000"
echo "  • Bot: Running"
echo ""
echo "🛑 Press Ctrl+C to stop all services"
echo ""

# Wait for interrupt
trap "kill $API_PID $BOT_PID; exit" INT
wait
