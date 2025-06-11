#!/bin/bash

# Set default port if not provided
PORT=${PORT:-8080}
echo "Starting on port: $PORT"

# Execute gunicorn with proper port binding
exec gunicorn --bind 0.0.0.0:$PORT app:app --timeout 120 --workers 2
