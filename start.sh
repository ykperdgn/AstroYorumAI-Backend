#!/bin/sh
# Single line shell script for Railway compatibility

# Simple port handling
PORT="${PORT:-8080}"
echo "Starting server on port: $PORT"
exec gunicorn app:app --bind "0.0.0.0:$PORT" --workers 2 --timeout 120
