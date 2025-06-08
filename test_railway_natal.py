#!/usr/bin/env python3
"""
Test Railway deployed /natal endpoint
"""
import requests
import json
from datetime import datetime

# Railway deployed URL
BASE_URL = "https://astroyorumai-backend-production.up.railway.app"

def test_railway_natal():
    """Test the Railway deployed /natal endpoint"""
    
    print("🚀 TESTING RAILWAY DEPLOYED NATAL ENDPOINT")
    print("=" * 60)
    print(f"🌐 Base URL: {BASE_URL}")
    print()
    
    # Test data
    test_data = {
        "date": "1990-06-15",
        "time": "14:30",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    print(f"📋 Test data: {json.dumps(test_data, indent=2)}")
    print()
    
    try:
        # Test health endpoint first
        print("1️⃣ Testing health endpoint...")
        health_response = requests.get(f"{BASE_URL}/health", timeout=30)
        
        if health_response.status_code == 200:
            health_data = health_response.json()
            print(f"✅ Health OK: {health_data.get('status')}")
            print(f"🔧 Version: {health_data.get('version')}")
            print(f"🚀 Platform: {health_data.get('platform')}")
            print()
        else:
            print(f"❌ Health failed: {health_response.status_code}")
            return False
            
        # Test natal endpoint
        print("2️⃣ Testing /natal endpoint...")
        natal_response = requests.post(
            f"{BASE_URL}/natal", 
            json=test_data, 
            headers={"Content-Type": "application/json"},
            timeout=60
        )
        
        print(f"📡 Status Code: {natal_response.status_code}")
        
        if natal_response.status_code == 200:
            natal_data = natal_response.json()
            print("🎉 SUCCESS: Natal endpoint working!")
            print()
            
            # Show key information
            if "planets" in natal_data:
                planets = natal_data["planets"]
                print(f"🪐 Planets calculated: {len(planets)}")
                
                for planet, data in planets.items():
                    sign = data.get("sign", "Unknown")
                    degree = data.get("degree", 0)
                    house = data.get("house", "Unknown")
                    print(f"   {planet}: {sign} {degree:.1f}° (House {house})")
                
                print()
                
            if "message" in natal_data:
                print(f"💬 Message: {natal_data['message']}")
                
            if "calculation_method" in natal_data:
                print(f"🔬 Calculation: {natal_data['calculation_method']}")
                
            print()
            print("🎯 RAILWAY DEPLOYMENT SUCCESSFUL!")
            print("✅ /natal endpoint working in production")
            return True
            
        else:
            print(f"❌ Natal endpoint failed: {natal_response.status_code}")
            print(f"Response: {natal_response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return False

if __name__ == "__main__":
    success = test_railway_natal()
    
    if success:
        print()
        print("🎊 DEPLOYMENT COMPLETE!")
        print("🌟 AstroYorumAI backend is live on Railway!")
        print(f"🔗 Production URL: {BASE_URL}")
        print("📱 Flutter app can now connect to production backend")
    else:
        print()
        print("❌ Deployment test failed")
