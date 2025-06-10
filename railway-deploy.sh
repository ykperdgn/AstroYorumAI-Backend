#!/bin/bash
# Railway.app deployment script for AstroYorumAI

echo "🚀 Starting AstroYorumAI Phase 3 Production Deployment"

# Install dependencies
echo "📦 Installing Python dependencies..."
pip install -r requirements.txt

# Set environment
export FLASK_ENV=production
export FLASK_DEBUG=False

echo "✅ AstroYorumAI backend ready for production"
echo "🌟 Version: 2.1.3 - Phase 3 Production Ready"
