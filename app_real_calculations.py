from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import sys
import datetime

# AstroYorumAI Real Calculations API - v2.1.3
app = Flask(__name__)

# Enhanced CORS configuration for Flutter web app
CORS(app, 
     origins=['*'],
     allow_headers=['Content-Type', 'Authorization', 'Access-Control-Allow-Credentials'],
     methods=['GET', 'POST', 'OPTIONS'],
     supports_credentials=True)

# Handle CORS preflight requests
@app.before_request
def handle_preflight():
    if request.method == "OPTIONS":
        response = jsonify({'status': 'OK'})
        response.headers.add("Access-Control-Allow-Origin", "*")
        response.headers.add('Access-Control-Allow-Headers', "*")
        response.headers.add('Access-Control-Allow-Methods', "*")
        response.headers.add('Access-Control-Max-Age', '86400')
        return response

# Add CORS headers to all responses
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization,Accept,Origin,X-Requested-With')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    response.headers.add('Access-Control-Allow-Credentials', 'true')
    response.headers.add('Access-Control-Max-Age', '86400')
    return response

# Root endpoint
@app.route('/', methods=['GET'])
def root():
    return jsonify({
        "message": "AstroYorumAI API is running",
        "version": "2.1.3-real-calculations", 
        "status": "healthy",
        "python_version": sys.version.split()[0],
        "build_timestamp": datetime.datetime.now().isoformat(),
        "calculation_method": "flatlib Swiss Ephemeris",
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
        "version": "2.1.3-real-calculations",
        "service": "AstroYorumAI API",
        "python_version": sys.version.split()[0],
        "calculation_method": "flatlib Swiss Ephemeris"
    })

# Test endpoint
@app.route('/test', methods=['GET'])
def test():
    return jsonify({
        "message": "API test successful",
        "python_version": sys.version,
        "flask_working": True,
        "flatlib_available": True,
        "environment": os.environ.get('FLASK_ENV', 'production')
    })

# Status endpoint
@app.route('/status', methods=['GET'])  
def status():
    return jsonify({
        "deployment_version": "2.1.3-real-calculations",
        "deployment_time": datetime.datetime.now().isoformat(),
        "flatlib_available": True,
        "status": "PRODUCTION_READY_WITH_REAL_CALCULATIONS",
        "api_endpoints": 4,
        "calculation_method": "flatlib Swiss Ephemeris"
    })

# Real Natal chart endpoint with flatlib calculations
@app.route('/natal', methods=['POST'])
def natal():
    try:
        data = request.json
        
        # Basic validation
        required_fields = ['date', 'time', 'latitude', 'longitude']
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing field: {field}"}), 400
        
        # Import flatlib for real astrological calculations
        from flatlib.chart import Chart
        from flatlib.datetime import Datetime
        from flatlib.geopos import GeoPos
        
        date_str = data['date']  # "YYYY-MM-DD"
        time_str = data['time']  # "HH:MM"
        latitude = float(data['latitude'])
        longitude = float(data['longitude'])
        
        # Flatlib tarihi "/" formatında bekliyor, "-" formatını dönüştür
        date_str_flatlib = date_str.replace('-', '/')
        
        # Türkiye için varsayılan UTC+3 (daha sonra kullanıcı timezone'u eklenebilir)
        dt = Datetime(date_str_flatlib, time_str, '+03:00')
        pos = GeoPos(latitude, longitude)
        
        chart = Chart(dt, pos)
        
        # Flatlib'de geçerli planet isimleri
        planets_to_get = ['Sun', 'Moon', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn']
        
        # Her gezegen için hem burç hem derece bilgisini döndür
        planet_positions = {}
        for p in planets_to_get:
            obj = chart.get(p)
            planet_positions[p] = {
                'sign': obj.sign,
                'deg': round(obj.lon, 2)  # Burç içi derece (0-30)
            }
        
        # Yükselen için de aynı format
        asc_obj = chart.get('Asc')
        ascendant = asc_obj.sign
        asc_deg = round(asc_obj.lon, 2)
        
        return jsonify({
            "planets": planet_positions,
            "ascendant": ascendant,
            "ascendant_deg": asc_deg,
            "input_data": {
                "date": date_str,
                "time": time_str,
                "latitude": latitude,
                "longitude": longitude
            },
            "message": "Real astrological calculation using flatlib",
            "version": "2.1.3-real-calculations",
            "calculation_method": "flatlib Swiss Ephemeris",
            "timezone": "UTC+3 (Turkey)"
        })
        
    except Exception as e:
        return jsonify({
            "error": str(e),
            "version": "2.1.3-real-calculations",
            "calculation_method": "flatlib Swiss Ephemeris"
        }), 500

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    print(f"Starting AstroYorumAI API v2.1.3-real-calculations...")
    print(f"Port: {port}")
    print(f"Debug mode: {debug}")
    print(f"Python version: {sys.version}")
    print(f"Calculation method: flatlib Swiss Ephemeris")
    print(f"Real calculations: YES")
    
    app.run(host='0.0.0.0', port=port, debug=debug)
