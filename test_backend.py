# Test script to verify backend functionality
import requests
import json

def test_backend():
    url = "http://localhost:5000/natal"
    test_data = {
        "date": "1990-01-01",
        "time": "12:00",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    try:
        response = requests.post(url, json=test_data, timeout=10)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_backend()
