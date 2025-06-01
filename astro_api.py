from flask import Flask, request, jsonify
from flask_cors import CORS
from flatlib.chart import Chart
from flatlib.datetime import Datetime
from flatlib.geopos import GeoPos
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
CORS(app, origins=['https://your-app-domain.com'])  # Production için güncellenecek

# Health check endpoint
@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "healthy", "version": "1.0.0"})

@app.route('/natal', methods=['POST'])
def natal():
    data = request.json
    date_str = data['date']  # "YYYY-MM-DD"
    time_str = data['time']  # "HH:MM"
    lat = data['latitude']  # örn. 41.0082 (İstanbul için)
    lon = data['longitude']  # örn. 28.9784
    
    # Türkiye için varsayılan UTC+3
    # Flatlib saat dilimini +/-HH:MM formatında bekler, ör: "+03:00"
    # Veya saat dilimi bilgisini kullanıcıdan alabilir veya koordinata göre belirleyebilirsiniz.
    # Şimdilik sabit +03:00 kullanıyoruz.
    dt = Datetime(date_str, time_str, '+03:00')
    pos = GeoPos(str(lat), str(lon))
    
    try:
        chart = Chart(dt, pos)
        planets_to_get = ['Sun', 'Moon', 'Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto']
        
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
            "ascendant_deg": asc_deg
        })
    except Exception as e:
        # Hata durumunda daha açıklayıcı bir mesaj döndür
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    print(f"Starting Flask server on port {port}")
    print(f"Debug mode: {debug}")
    app.run(host='0.0.0.0', port=port, debug=debug)
    print("Debug mode: True")
    # Debug modunu geliştirme sırasında açabilirsiniz, ancak canlıya alırken kapatın.
    app.run(host='0.0.0.0', port=5000, debug=True) # host='0.0.0.0' ağdaki diğer cihazların erişebilmesi için
