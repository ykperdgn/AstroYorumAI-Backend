import requests
import json

def test_missing_endpoints():
    base_url = "https://astroyorumai-api.onrender.com"
    endpoints = ['/synastry', '/transit', '/solar-return', '/progression', '/horary', '/composite']
    
    print("Testing missing backend endpoints...")
    missing = []
    
    for endpoint in endpoints:
        try:
            response = requests.post(f"{base_url}{endpoint}", json={}, timeout=5)
            print(f"{endpoint}: {response.status_code}")
            if response.status_code == 404:
                missing.append(endpoint)
        except Exception as e:
            print(f"{endpoint}: ERROR - {str(e)[:50]}")
            missing.append(endpoint)
    
    print(f"\nMissing endpoints: {missing}")
    return missing

if __name__ == "__main__":
    test_missing_endpoints()
