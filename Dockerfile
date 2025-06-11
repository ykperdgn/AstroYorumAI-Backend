# AstroYorumAI Backend Dockerfile - Phase 3 Production - Railway Optimized
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

# Copy application code - only the essentials
COPY app.py .
COPY .env.production .env
COPY requirements.txt .
COPY start.sh .
COPY railway-debug.sh .
COPY change-port.sh .

# Set environment variables
ENV FLASK_ENV=production
ENV FLASK_DEBUG=False
ENV PYTHONUNBUFFERED=1

# Expose port (for local testing only, Railway will set PORT at runtime)
EXPOSE 8080

# Ensure scripts have proper line endings and are executable
RUN sed -i 's/\r$//' start.sh && \
    chmod +x start.sh && \
    sed -i 's/\r$//' railway-debug.sh && \
    chmod +x railway-debug.sh && \
    sed -i 's/\r$//' change-port.sh && \
    chmod +x change-port.sh

# Health check - port will be determined at runtime
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:$PORT/health || curl -f http://localhost:8080/health || exit 1

# For Railway deployment, we'll use the Procfile
# Do not specify CMD here as Railway will use the Procfile
