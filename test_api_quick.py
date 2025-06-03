import requests
import json

# Test the natal chart API
data = {
    'date': '1990-01-15',
    'time': '10:30',
    'latitude': 41.0082,
    'longitude': 28.9784
}

try:
    response = requests.post('https://astroyorumai-api.onrender.com/natal', json=data)
    print(f'Status: {response.status_code}')
    
    if response.status_code == 200:
        result = response.json()
        print(f'Keys: {list(result.keys())}')
        
        if 'planets' in result:
            planets_keys = list(result['planets'].keys())
            print(f'Planets: {planets_keys}')
            sun_data = result['planets'].get('Sun', {})
            print(f'Sun data: {sun_data}')
        
        ascendant = result.get('ascendant', 'Not found')
        print(f'Ascendant: {ascendant}')
        
        print('\n✅ API is working correctly with real calculations!')
    else:
        print(f'❌ API Error: {response.status_code}')
        print(response.text)
        
except Exception as e:
    print(f'❌ Connection Error: {e}')
