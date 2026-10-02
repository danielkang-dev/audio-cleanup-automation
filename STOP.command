#!/bin/bash
cd "$(dirname "$0")"

echo "Stopping Audio Cleanup Automation..."

docker compose down

echo "Audio Cleanup Automation has stopped. Safe to close this window."
