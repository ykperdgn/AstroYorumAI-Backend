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
COPY app.py .
COPY .env.production .env
COPY Procfile .

# Set environment variables
ENV FLASK_ENV=production
ENV FLASK_DEBUG=False
ENV PYTHONUNBUFFERED=1

# Set a fixed port for Railway
ENV PORT=8080

# Expose port (for local testing)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Use a direct command with the fixed port
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:8080", "--workers", "2", "--timeout", "120"]
