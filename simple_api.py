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
            "test": "/test",
            "natal_chart": "/natal"
        }
    })

# Health check endpoint
@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy", 
        "version": "1.0.0",
        "service": "AstroYorumAI API"
    })

# Test endpoint
@app.route('/test', methods=['GET'])
def test():
    return jsonify({
        "message": "API test successful",
        "python_version": sys.version,
        "flask_working": True,
        "environment": os.environ.get('FLASK_ENV', 'not_set')
    })

# Simple natal chart endpoint (we'll add flatlib later once basic deployment works)
@app.route('/natal', methods=['POST'])
def natal():
    try:
        data = request.json
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
            
        required_fields = ['date', 'time', 'latitude', 'longitude']
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing required field: {field}"}), 400
        
        # For now, return a simple response to test basic functionality
        return jsonify({
            "message": "Natal chart endpoint is working",
            "received_data": {
                "date": data.get('date'),
                "time": data.get('time'),
                "latitude": data.get('latitude'),
                "longitude": data.get('longitude')
            },
            "status": "success",
            "note": "Astrological calculations will be added once basic deployment is confirmed"
        })
        
    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    
    print(f"🚀 Starting AstroYorumAI API...")
    print(f"📍 Port: {port}")
    print(f"🔧 Debug mode: {debug}")
    print(f"🐍 Python version: {sys.version}")
    
    app.run(host='0.0.0.0', port=port, debug=debug)
