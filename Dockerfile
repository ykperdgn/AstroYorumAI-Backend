# AstroYorumAI Backend Dockerfile - Phase 3 Production
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (for better caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Set environment variables
ENV FLASK_ENV=production
ENV FLASK_DEBUG=False
ENV PYTHONUNBUFFERED=1

# Expose port (for local testing)
EXPOSE 8080

# Default CMD, will be overridden by Railway's startCommand in railway.json
CMD ["sh", "-c", "echo 'Application starting...' && exec gunicorn app:app --bind 0.0.0.0:8080 --workers 2 --timeout 120"]
