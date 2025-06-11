#!/bin/sh
# Railway PORT handling wrapper script

# Print original PORT value for debugging
echo "Original PORT value: '$PORT'"

# Set default port if not provided or empty
if [ -z "$PORT" ]; then
  echo "PORT is empty, setting default port 8080"
  export PORT=8080
fi

# Always print the PORT being used
echo "Using PORT: $PORT"

# Execute gunicorn with the port
exec gunicorn app:app --bind "0.0.0.0:$PORT" --workers 2 --timeout 120
