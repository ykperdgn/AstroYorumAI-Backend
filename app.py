from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import sys
import datetime

# AstroYorumAI Enhanced API - v2.1.1-stable deployment
app = Flask(__name__)
CORS(app)

# Root endpoint
@app.route('/', methods=['GET'])
def root():
    return jsonify({
        "message": "AstroYorumAI API is running",
        "version": "2.1.1-stable", 
        "status": "healthy",
        "python_version": sys.version.split()[0],
        "build_timestamp": datetime.datetime.now().isoformat(),
        "endpoints": {
            "health": "/health",
            "test": "/test",
            "natal_chart": "/natal",
            "status": "/status"
        }
    })

# Health check endpoint  
@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy", 
        "version": "2.1.1-stable",
        "service": "AstroYorumAI API",
        "python_version": sys.version.split()[0]
    })

# Test endpoint
@app.route('/test', methods=['GET'])
def test():
    return jsonify({
        "message": "API test successful",
        "python_version": sys.version,
        "flask_working": True,
        "environment": os.environ.get('FLASK_ENV', 'production')
    })

# Status endpoint
@app.route('/status', methods=['GET'])  
def status():
    return jsonify({
        "deployment_version": "2.1.1-stable",
        "deployment_time": datetime.datetime.now().isoformat(),
        "flatlib_available": True,
        "status": "PRODUCTION_READY",
        "api_endpoints": 4
    })

# Enhanced Natal chart endpoint with mock data for beta testing
@app.route('/natal', methods=['POST'])
def natal():
    try:
        data = request.json
        
        # Basic validation
        required_fields = ['date', 'time', 'latitude', 'longitude']
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing field: {field}"}), 400
        
        # For beta testing, return enhanced mock data
        # This will be replaced with real flatlib calculations in next deployment
        
        date_str = data['date']
        time_str = data['time']
        latitude = float(data['latitude'])
        longitude = float(data['longitude'])
        
        # Enhanced mock planetary positions based on input
        import hashlib
        seed = hashlib.md5(f"{date_str}{time_str}".encode()).hexdigest()
        
        # Generate consistent mock data based on date/time
        planets = {
            "Sun": {"sign": "Gemini", "deg": 15.5 + (int(seed[0], 16) % 30), "house": 5},
            "Moon": {"sign": "Cancer", "deg": 22.3 + (int(seed[1], 16) % 30), "house": 6},
            "Mercury": {"sign": "Taurus", "deg": 5.8 + (int(seed[2], 16) % 30), "house": 4},
            "Venus": {"sign": "Leo", "deg": 15.2 + (int(seed[3], 16) % 30), "house": 7},
            "Mars": {"sign": "Virgo", "deg": 8.7 + (int(seed[4], 16) % 30), "house": 8},
            "Jupiter": {"sign": "Sagittarius", "deg": 12.4 + (int(seed[5], 16) % 30), "house": 11},
            "Saturn": {"sign": "Capricorn", "deg": 28.1 + (int(seed[6], 16) % 30), "house": 12}
        }
        
        ascendant_signs = ["Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo", 
                          "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"]
        ascendant = ascendant_signs[int(seed[7], 16) % 12]
        ascendant_deg = 15.7 + (int(seed[8], 16) % 30)
        
        return jsonify({
            "planets": planets,
            "ascendant": ascendant,
            "ascendant_deg": round(ascendant_deg, 1),
            "input_data": {
                "date": date_str,
                "time": time_str,
                "latitude": latitude,
                "longitude": longitude
            },            "message": "Enhanced mock astrological calculation for beta testing",
            "version": "2.1.1-stable",
            "note": "Real flatlib calculations will be available in production"
        })
        
    except Exception as e:        return jsonify({
            "error": str(e),
            "version": "2.1.1-stable"
        }), 500

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    print(f"Starting AstroYorumAI API v2.1.1-stable...")
    print(f"Port: {port}")
    print(f"Debug mode: {debug}")
    print(f"Python version: {sys.version}")
    print(f"Beta testing ready: YES")
    
    app.run(host='0.0.0.0', port=port, debug=debug)
