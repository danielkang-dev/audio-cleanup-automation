#!/bin/bash
cd "$(dirname "$0")"

echo "Stopping Music Pipeline..."

docker compose down

echo "Music Pipeline has stopped. Safe to close this window."
