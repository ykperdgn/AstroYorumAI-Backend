# AstroYorumAI Backend Dockerfile - Railway Production Ready
FROM python:3.11-slim-bullseye

# Set working directory
WORKDIR /app

# Install system dependencies for astronomy libraries and curl for health checks
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (for better caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Create necessary directories
RUN mkdir -p /app/static /app/templates

# Set environment variables
ENV FLASK_ENV=production
ENV FLASK_DEBUG=False
ENV PYTHONUNBUFFERED=1

# Railway will inject PORT env var, default to 8080 if not provided  
ENV PORT=8080

# Expose port
EXPOSE $PORT

# Health check - use curl with port
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start application with gunicorn - Railway compatible
# Use shell form to properly expand environment variables
CMD ["sh", "-c", "exec gunicorn --bind 0.0.0.0:$PORT --workers 1 --threads 4 --worker-class gthread --timeout 120 --keep-alive 2 --max-requests 1000 --max-requests-jitter 100 app:app"]
