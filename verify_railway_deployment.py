#!/usr/bin/env python3
"""
Railway Deployment Verification Script
Tests Railway deployment status and API endpoints
"""

import requests
import json
import time
from datetime import datetime

# Railway URL - will be updated after deployment
RAILWAY_URL = "https://astroyorumai-backend-production.up.railway.app"
LOCAL_URL = "http://localhost:5000"

def test_endpoint(url, endpoint, method="GET", data=None):
    """Test a specific API endpoint"""
    full_url = f"{url}{endpoint}"
    print(f"🧪 Testing {method} {full_url}")
    
    try:
        if method == "GET":
            response = requests.get(full_url, timeout=30)
        elif method == "POST":
            response = requests.post(full_url, json=data, timeout=30)
        
        print(f"   Status: {response.status_code}")
        if response.status_code == 200:
            print(f"   ✅ SUCCESS")
            if response.headers.get('content-type', '').startswith('application/json'):
                try:
                    json_data = response.json()
                    if 'version' in json_data:
                        print(f"   📊 Version: {json_data['version']}")
                    if 'status' in json_data:
                        print(f"   📊 Status: {json_data['status']}")
                except:
                    pass
        else:
            print(f"   ❌ FAILED: {response.status_code}")
            
        return response.status_code == 200
    except requests.exceptions.RequestException as e:
        print(f"   ❌ ERROR: {e}")
        return False

def main():
    print("🚂 RAILWAY DEPLOYMENT VERIFICATION")
    print("=" * 50)
    print(f"⏰ Test Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # Test Railway deployment
    print("🌐 TESTING RAILWAY DEPLOYMENT")
    print(f"🔗 URL: {RAILWAY_URL}")
    print("-" * 30)
    
    # Basic endpoints
    endpoints = [
        ("/", "GET"),
        ("/health", "GET"),
        ("/status", "GET"),
        ("/test", "GET"),
        ("/api/version", "GET"),
    ]
    
    railway_results = []
    for endpoint, method in endpoints:
        result = test_endpoint(RAILWAY_URL, endpoint, method)
        railway_results.append(result)
        time.sleep(1)
    
    print()
    
    # Test natal chart endpoint
    print("🔮 TESTING NATAL CHART ENDPOINT")
    print("-" * 30)
    natal_data = {
        "birth_date": "1990-05-15",
        "birth_time": "10:30",
        "birth_place": "Istanbul",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    natal_result = test_endpoint(RAILWAY_URL, "/natal", "POST", natal_data)
    time.sleep(1)
    
    print()
    
    # Compare with local if available
    print("🏠 TESTING LOCAL DEVELOPMENT (if running)")
    print("-" * 30)
    local_health = test_endpoint(LOCAL_URL, "/health", "GET")
    
    print()
    
    # Summary
    print("📊 VERIFICATION SUMMARY")
    print("=" * 50)
    
    railway_success = sum(railway_results)
    railway_total = len(railway_results)
    
    print(f"Railway Basic Endpoints: {railway_success}/{railway_total} ✅")
    print(f"Railway Natal Endpoint: {'✅' if natal_result else '❌'}")
    print(f"Local Development: {'✅' if local_health else '❌ (not running)'}")
    
    print()
    
    if railway_success >= 3 and natal_result:
        print("🎉 RAILWAY DEPLOYMENT: SUCCESS!")
        print("🚀 Ready for production use")
        print()
        print("📱 UPDATE FLUTTER APP with Railway URL:")
        print(f"   {RAILWAY_URL}")
    else:
        print("⚠️  RAILWAY DEPLOYMENT: ISSUES DETECTED")
        print("🔧 Check Railway logs and configuration")
        print()
        print("🛠️  TROUBLESHOOTING STEPS:")
        print("1. Check Railway dashboard for deployment status")
        print("2. Verify environment variables are set")
        print("3. Check Railway logs: railway logs")
        print("4. Verify build completed successfully")
    
    print()
    print("🔗 USEFUL LINKS:")
    print(f"   Railway Dashboard: https://railway.app/dashboard")
    print(f"   API Health Check: {RAILWAY_URL}/health")
    print(f"   API Documentation: {RAILWAY_URL}/")

if __name__ == "__main__":
    main()
