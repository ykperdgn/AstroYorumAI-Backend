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

# Set default port for Railway (fallback if $PORT not provided)
ENV PORT=8080

# Expose port 8080 (fixed port for Docker build-time)
EXPOSE 8080

# Health check - use fixed port since Railway maps internally
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start application directly with Python - Railway compatible
# Use exec form for better signal handling
CMD ["python", "app.py"]
