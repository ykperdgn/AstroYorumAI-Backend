#!/usr/bin/env python3
"""
Quick test for the version-check endpoint
"""
import requests

def test_version_endpoint():
    url = "https://astroyorumai-api.onrender.com/version-check"
    
    try:
        print(f"🔍 Testing {url}")
        response = requests.get(url, timeout=10)
        
        if response.status_code == 200:
            print("✅ New endpoint found! Latest deployment is active.")
            data = response.json()
            print(f"📦 Version: {data.get('current_version')}")
            print(f"🔧 Flatlib: {data.get('flatlib_status')}")
            return True
        elif response.status_code == 404:
            print("❌ Endpoint not found - old deployment still active")
            return False
        else:
            print(f"❓ Unexpected status: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"💥 Error: {str(e)}")
        return False

if __name__ == "__main__":
    test_version_endpoint()
