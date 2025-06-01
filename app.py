from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import sys

app = Flask(__name__)
CORS(app)

# Root endpoint
@app.route('/', methods=['GET'])
def root():
    return jsonify({
        "message": "AstroYorumAI API is running",
        "version": "1.0.0", 
        "status": "healthy",
        "python_version": sys.version.split()[0],
        "endpoints": {
            "health": "/health",
            "test": "/test"
        }
    })

# Health check endpoint  
@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy", 
        "version": "1.0.0",
        "python_version": sys.version.split()[0]
    })

# Test endpoint
@app.route('/test', methods=['GET'])
def test():
    return jsonify({
        "message": "API test successful",
        "python_version": sys.version,
        "flask_working": True,
        "environment": os.environ.get('FLASK_ENV', 'development')
    })

# Simple natal endpoint (without flatlib for now)
@app.route('/natal', methods=['POST'])
def natal():
    try:
        data = request.json
        
        # Basic validation
        required_fields = ['date', 'time', 'latitude', 'longitude']
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing field: {field}"}), 400
        
        # Mock response for now (will add real astrology calculation later)
        return jsonify({
            "planets": {
                "Sun": {"sign": "Capricorn", "deg": 10.5},
                "Moon": {"sign": "Leo", "deg": 22.3},
                "Mercury": {"sign": "Sagittarius", "deg": 5.8},
                "Venus": {"sign": "Aquarius", "deg": 15.2},
                "Mars": {"sign": "Pisces", "deg": 8.7}
            },
            "ascendant": "Virgo", 
            "ascendant_deg": 15.7,
            "message": "Mock data - real calculation will be added soon"
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    
    print(f"🚀 Starting AstroYorumAI API...")
    print(f"📍 Port: {port}")
    print(f"🔧 Debug mode: {debug}")
    print(f"🐍 Python version: {sys.version}")
    
    app.run(host='0.0.0.0', port=port, debug=debug)
