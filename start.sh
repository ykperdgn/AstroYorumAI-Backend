#!/bin/bash
echo "Starting AstroYorumAI API..."
echo "Python version: $(python --version)"
echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt
echo "Starting Gunicorn server..."
exec gunicorn --bind 0.0.0.0:$PORT --workers 1 --timeout 120 --log-level info astro_api:app
