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
        "version": "2.0.0-flatlib", 
        "status": "healthy",
        "python_version": sys.version.split()[0],
        "endpoints": {
            "health": "/health",
            "test": "/test",
            "natal_chart": "/natal"
        }
    })

# Health check endpoint  
@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy", 
        "version": "2.0.0-flatlib",
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
        "environment": os.environ.get('FLASK_ENV', 'development')
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
            
            # Create datetime object
            year, month, day = map(int, date_str.split('-'))
            hour, minute = map(int, time_str.split(':'))
            
            date_time = Datetime(f'{date_str} {time_str}', '+00:00')
            pos = GeoPos(latitude, longitude)
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
      print(f"🚀 Starting AstroYorumAI API with Flatlib...")
    print(f"📍 Port: {port}")
    print(f"🔧 Debug mode: {debug}")
    print(f"🐍 Python version: {sys.version}")
    print(f"🌟 Flatlib integration: ENABLED")
    
    app.run(host='0.0.0.0', port=port, debug=debug)
