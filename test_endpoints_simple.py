import requests
import json
from datetime import datetime

# Backend URL
BASE_URL = "https://astroyorumai-backend-production.up.railway.app"

def test_endpoint(endpoint, data, description):
    print(f"\nTesting {description}")
    print(f"Endpoint: {endpoint}")
    
    try:
        response = requests.post(f"{BASE_URL}{endpoint}", json=data, timeout=30)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print("SUCCESS")
            print(f"Response keys: {list(result.keys())}")
            return True
        else:
            print("FAILED")
            print(f"Error: {response.text}")
            return False
            
    except Exception as e:
        print(f"ERROR: {str(e)}")
        return False

def main():
    print("Testing Newly Implemented Astrology Endpoints")
    print("=" * 50)
    
    # Test data
    person1_data = {
        "date": "1990-05-15",
        "time": "14:30:00",
        "latitude": 41.0082,
        "longitude": 28.9784,
        "name": "Ali"
    }
    
    person2_data = {
        "date": "1992-08-22",
        "time": "09:15:00",
        "latitude": 39.9334,
        "longitude": 32.8597,
        "name": "Ayse"
    }
    
    # Test 1: Synastry
    synastry_data = {
        "person1": person1_data,
        "person2": person2_data
    }
    test_endpoint("/synastry", synastry_data, "Synastry Analysis")
    
    # Test 2: Transit
    transit_data = {
        "birth_date": "1990-05-15",
        "birth_time": "14:30:00",
        "latitude": 41.0082,
        "longitude": 28.9784,
        "transit_date": datetime.now().strftime('%Y-%m-%d')
    }
    test_endpoint("/transit", transit_data, "Transit Analysis")
    
    print("\nEndpoint testing completed!")

if __name__ == "__main__":
    main()
