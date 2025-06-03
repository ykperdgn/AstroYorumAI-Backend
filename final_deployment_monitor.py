#!/usr/bin/env python3
"""
🎯 Final Deployment Status Monitor
Continuously checks if manual deployment succeeded
"""

import requests
import time
import json
from datetime import datetime

def check_api_status():
    """Check if the enhanced API is live"""
    try:
        print("🔍 Checking API status...")
        
        # Check version endpoint
        response = requests.get("https://astroyorumai.onrender.com/status", timeout=10)
        if response.status_code == 200:
            data = response.json()
            version = data.get('version', 'unknown')
            print(f"📦 Current Version: {version}")
            
            if version == "2.1.2-stable":
                print("✅ SUCCESS! Enhanced API is live!")
                
                # Test natal chart endpoint
                print("\n🔍 Testing natal chart endpoint...")
                natal_response = requests.get(
                    "https://astroyorumai.onrender.com/natal?date=1990-05-15&time=14:30&lat=41.0082&lon=28.9784",
                    timeout=10
                )
                
                if natal_response.status_code == 200:
                    natal_data = natal_response.json()
                    if 'planets' in natal_data and len(natal_data['planets']) > 0:
                        print("✅ Natal chart endpoint working!")
                        print("✅ Enhanced planetary data available!")
                        
                        # Show sample planet data
                        first_planet = list(natal_data['planets'].keys())[0]
                        planet_data = natal_data['planets'][first_planet]
                        print(f"📊 Sample: {first_planet} = {planet_data}")
                        
                        return True
                    else:
                        print("❌ Natal chart missing planetary data")
                        return False
                else:
                    print(f"❌ Natal chart endpoint failed: {natal_response.status_code}")
                    return False
            else:
                print(f"❌ Still old version: {version} (expecting 2.1.2-stable)")
                return False
        else:
            print(f"❌ API request failed: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Error checking API: {e}")
        return False

def main():
    """Monitor deployment status"""
    print("🚀 AstroYorumAI - Final Deployment Monitor")
    print("=" * 50)
    print("⏳ Waiting for manual deployment to complete...")
    print("💡 Trigger deployment manually on Render.com dashboard")
    print("📍 Deploy commit: 121ec6c")
    print("-" * 50)
    
    check_count = 0
    while True:
        check_count += 1
        timestamp = datetime.now().strftime("%H:%M:%S")
        print(f"\n[{timestamp}] Check #{check_count}")
        
        if check_api_status():
            print("\n🎉 DEPLOYMENT SUCCESSFUL!")
            print("🎯 Backend is ready for production!")
            print("\n📋 Next Steps:")
            print("1. Update Flutter app backend URL")
            print("2. Set up Firebase production project")
            print("3. Begin beta testing phase")
            break
        else:
            print("⏳ Deployment not ready yet...")
            print("💡 Check Render.com deployment status")
            
        print("\n⏱️  Checking again in 30 seconds...")
        time.sleep(30)

if __name__ == "__main__":
    main()
