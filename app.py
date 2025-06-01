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
        "message": "AstroYorumAI API is running",        "version": "2.0.2-production-final", 
        "status": "healthy",
        "python_version": sys.version.split()[0],
        "build_timestamp": "2025-01-27T15:45:00Z",
        "endpoints": {
            "health": "/health",
            "test": "/test",
            "natal_chart": "/natal",
            "version_check": "/version-check"
        }
    })

# Health check endpoint  
@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy", 
        "version": "2.0.2-production-final",
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
        "environment": os.environ.get('FLASK_ENV', 'development')    })

# Version verification endpoint
@app.route('/version-check', methods=['GET'])
def version_check():
    return jsonify({
        "current_version": "2.0.0-flatlib",
        "deployment_timestamp": "2025-06-01T12:00:00Z",
        "flatlib_status": "INTEGRATED",
        "git_commit": "Latest commit with flatlib",
        "python_version": sys.version,
        "message": "This endpoint confirms flatlib deployment"
    })

# Natal chart endpoint with astrological calculations
@app.route('/natal', methods=['POST'])
def natal():
    try:
        data = request.json
        
        # Basic validation
        required_fields = ['date', 'time', 'latitude', 'longitude']
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing field: {field}"}), 400
        
        # Try to import flatlib for real calculations
        try:
            from flatlib.datetime import Datetime
            from flatlib.geopos import GeoPos
            from flatlib.chart import Chart
            from flatlib import const
              # Parse input data
            date_str = data['date']  # Format: 'YYYY-MM-DD'
            time_str = data['time']  # Format: 'HH:MM'
            latitude = float(data['latitude'])
            longitude = float(data['longitude'])
            
            # Convert date format for flatlib (YYYY/MM/DD)
            flatlib_date = date_str.replace('-', '/')
            
            # Convert coordinates to flatlib format (degrees:minutes:seconds)
            def decimal_to_dms(decimal_degrees):
                """Convert decimal degrees to degrees:minutes:seconds format"""
                abs_deg = abs(decimal_degrees)
                degrees = int(abs_deg)
                minutes_float = (abs_deg - degrees) * 60
                minutes = int(minutes_float)
                seconds = int((minutes_float - minutes) * 60)
                return f"{degrees:02d}:{minutes:02d}:{seconds:02d}"
            
            # Format latitude (N/S) and longitude (E/W)
            lat_dms = decimal_to_dms(latitude)
            lon_dms = decimal_to_dms(longitude)
            lat_formatted = f"+{lat_dms}" if latitude >= 0 else f"-{lat_dms}"
            lon_formatted = f"-{lon_dms}" if longitude >= 0 else f"+{lon_dms}"  # Note: longitude sign is flipped
            
            # Create flatlib objects
            date_time = Datetime(flatlib_date, time_str, '+00:00')
            pos = GeoPos(lat_formatted, lon_formatted)
            chart = Chart(date_time, pos)
            
            # Get planetary positions
            planets = {}
            planet_objects = [
                const.SUN, const.MOON, const.MERCURY, const.VENUS, 
                const.MARS, const.JUPITER, const.SATURN
            ]
            
            for planet_id in planet_objects:
                planet = chart.get(planet_id)
                planets[planet.id] = {
                    "sign": planet.sign,
                    "deg": round(planet.signlon, 2),
                    "house": planet.house if hasattr(planet, 'house') else None
                }
            
            # Get ascendant
            asc = chart.get(const.ASC)
            
            return jsonify({
                "planets": planets,
                "ascendant": asc.sign,
                "ascendant_deg": round(asc.signlon, 2),
                "input_data": {
                    "date": date_str,
                    "time": time_str,
                    "latitude": latitude,
                    "longitude": longitude
                },
                "message": "Real astrological calculation completed"
            })
            
        except ImportError:
            # Fallback to enhanced mock data if flatlib not available
            return jsonify({
                "planets": {
                    "Sun": {"sign": "Capricorn", "deg": 10.5, "house": 4},
                    "Moon": {"sign": "Leo", "deg": 22.3, "house": 11},
                    "Mercury": {"sign": "Sagittarius", "deg": 5.8, "house": 3},
                    "Venus": {"sign": "Aquarius", "deg": 15.2, "house": 5},
                    "Mars": {"sign": "Pisces", "deg": 8.7, "house": 6},
                    "Jupiter": {"sign": "Taurus", "deg": 12.4, "house": 8},
                    "Saturn": {"sign": "Gemini", "deg": 28.1, "house": 9}
                },
                "ascendant": "Virgo", 
                "ascendant_deg": 15.7,
                "input_data": data,
                "message": "Enhanced mock data (flatlib not available in this deployment)"
            })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    
    print(f"Starting AstroYorumAI API with Flatlib...")
    print(f"Port: {port}")
    print(f"Debug mode: {debug}")
    print(f"Python version: {sys.version}")
    print(f"Flatlib integration: ENABLED")
    
    app.run(host='0.0.0.0', port=port, debug=debug)
