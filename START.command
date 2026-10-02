#!/bin/bash
cd "$(dirname "$0")"

echo "Starting Audio Cleanup Automation..."

# Start Docker Desktop if not running
open -a Docker
echo "Waiting for Docker to start..."
sleep 8

# Start the containers
docker compose up -d

echo "Waiting for n8n to be ready..."
sleep 5

# Open browser
open http://localhost:5678

echo "Audio Cleanup Automation is running!"
echo "Drop your MP3s into the 'input' folder, then click the button in your browser."
