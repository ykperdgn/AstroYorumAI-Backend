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

# Railway will inject PORT env var
# Don't set a default PORT here, let Railway handle it

# Expose the port that Railway will use (Railway handles port mapping dynamically)
EXPOSE $PORT

# Health check - Railway will map the correct port
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:$PORT/health || exit 1

# Start application directly with Python - Railway compatible
# Use exec form with shell to properly expand environment variables
CMD python app.py
