#!/bin/sh

# Print environment variables for debugging
echo "PORT environment variable: $PORT"

# Set default port if not provided
PORT=${PORT:-8080}
echo "Using port: $PORT"

# Execute gunicorn with the port
exec gunicorn app:app --bind "0.0.0.0:$PORT" --workers 2 --timeout 120
