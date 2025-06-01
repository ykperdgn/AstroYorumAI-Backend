#!/usr/bin/env python3
"""
Test script to verify Render.com deployment status
"""
import requests
import json
import time

def test_api_endpoint(url, endpoint_name):
    """Test a single API endpoint"""
    print(f"\n🔍 Testing {endpoint_name}...")
    print(f"URL: {url}")
    
    try:
        response = requests.get(url, timeout=30)
        print(f"✅ Status Code: {response.status_code}")
        
        if response.status_code == 200:
            try:
                data = response.json()
                print(f"✅ Response: {json.dumps(data, indent=2)}")
                return True
            except json.JSONDecodeError:
                print(f"✅ Response (text): {response.text}")
                return True
        else:
            print(f"❌ Error: HTTP {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except requests.exceptions.ConnectTimeout:
        print("❌ Connection timeout - service might be starting up")
        return False
    except requests.exceptions.ConnectionError:
        print("❌ Connection error - service might not be deployed yet")
        return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Request error: {e}")
        return False

def main():
    """Main test function"""
    base_url = "https://astroyorumai-api.onrender.com"
    
    print("🚀 AstroYorumAI API Deployment Test")
    print("=" * 50)
    
    # Test health endpoint
    health_success = test_api_endpoint(f"{base_url}/health", "Health Check")
    
    if health_success:
        # Test natal chart endpoint with sample data
        natal_url = f"{base_url}/natal"
        print(f"\n🔍 Testing Natal Chart API...")
        print(f"URL: {natal_url}")
        
        test_data = {
            "birth_date": "1990/01/01",
            "birth_time": "12:00",
            "birth_lat": 41.0082,
            "birth_lon": 28.9784
        }
        
        try:
            response = requests.post(natal_url, json=test_data, timeout=30)
            print(f"✅ Status Code: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                print(f"✅ Natal Chart Response: {json.dumps(data, indent=2)}")
            else:
                print(f"❌ Error: HTTP {response.status_code}")
                print(f"Response: {response.text}")
                
        except requests.exceptions.RequestException as e:
            print(f"❌ Natal Chart Request error: {e}")
    
    print("\n" + "=" * 50)
    print("🏁 Test completed")

if __name__ == "__main__":
    main()
