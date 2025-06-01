#!/usr/bin/env python3
"""
Quick test to check API structure and deployment status
"""
import requests
import json
import time

BASE_URL = "https://astroyorumai-api.onrender.com"

def test_api_structure():
    print("🔍 Testing API structure and deployment...")
    
    # Test root endpoint for version
    try:
        print("\n1. Testing root endpoint...")
        response = requests.get(BASE_URL, timeout=10)
        if response.status_code == 200:
            data = response.json()
            print(f"   Version: {data.get('version', 'Unknown')}")
            print(f"   Status: {data.get('status', 'Unknown')}")
        else:
            print(f"   Error: {response.status_code}")
    except Exception as e:
        print(f"   Error: {e}")
    
    # Test health endpoint
    try:
        print("\n2. Testing health endpoint...")
        response = requests.get(f"{BASE_URL}/health", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print(f"   Health version: {data.get('version', 'Unknown')}")
            print(f"   Service: {data.get('service', 'Unknown')}")
        else:
            print(f"   Error: {response.status_code}")
    except Exception as e:
        print(f"   Error: {e}")
    
    # Test natal chart endpoint
    try:
        print("\n3. Testing natal chart endpoint...")
        natal_data = {
            "date": "1990-05-15",
            "time": "14:30",
            "latitude": 41.0082,
            "longitude": 28.9784
        }
        
        response = requests.post(
            f"{BASE_URL}/natal",
            json=natal_data,
            timeout=30
        )
        
        print(f"   Status Code: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"   Response keys: {list(data.keys())}")
            
            # Check if we have planets data (enhanced backend)
            if 'planets' in data:
                print("   ✅ Enhanced backend detected!")
                print(f"   Planets available: {list(data['planets'].keys())}")
                if 'Sun' in data['planets']:
                    sun = data['planets']['Sun']
                    print(f"   Sun: {sun.get('sign', 'N/A')} {sun.get('deg', 'N/A')}°")
                print(f"   Version: {data.get('version', 'Unknown')}")
            else:
                print("   ❌ Simple backend detected")
                print(f"   Message: {data.get('message', 'N/A')}")
        else:
            print(f"   Error response: {response.text[:200]}")
            
    except Exception as e:
        print(f"   Error: {e}")

if __name__ == "__main__":
    print("🚀 AstroYorumAI API Structure Test")
    print("=" * 50)
    test_api_structure()
