#!/usr/bin/env python3
"""
Real-time deployment monitoring for AstroYorumAI
"""
import requests
import time
from datetime import datetime

def check_deployment_status():
    """Check current deployment and provide status update"""
    print("🚀 AstroYorumAI Deployment Status Monitor")
    print("=" * 50)
    print(f"⏰ {datetime.now().strftime('%H:%M:%S')} UTC")
    print("=" * 50)
    
    try:
        # Test main endpoint
        response = requests.get("https://astroyorumai-api.onrender.com/", timeout=30)
        if response.status_code == 200:
            data = response.json()
            version = data.get("version", "unknown")
            
            print(f"📦 Current Version: {version}")
            print(f"🌐 API Status: {response.status_code} OK")
            
            if version == "2.1.2-stable":
                print("🎉 SUCCESS! Enhanced API is LIVE!")
                
                # Test enhanced features
                print("\n🧪 Testing Enhanced Features...")
                
                # Test status endpoint
                try:
                    status_resp = requests.get("https://astroyorumai-api.onrender.com/status", timeout=30)
                    if status_resp.status_code == 200:
                        print("✅ Status endpoint: Working")
                    else:
                        print(f"❌ Status endpoint: {status_resp.status_code}")
                except:
                    print("❌ Status endpoint: Failed")
                
                # Test natal chart
                try:
                    natal_data = {
                        "date": "1990-06-15",
                        "time": "14:30",
                        "latitude": 41.0082,
                        "longitude": 28.9784
                    }
                    natal_resp = requests.post("https://astroyorumai-api.onrender.com/natal", 
                                             json=natal_data, timeout=30)
                    if natal_resp.status_code == 200:
                        result = natal_resp.json()
                        if "planets" in result:
                            planets = result["planets"]
                            print(f"✅ Enhanced natal chart: {len(planets)} planets")
                        else:
                            print("❌ Enhanced natal chart: Missing planets")
                    else:
                        print(f"❌ Enhanced natal chart: {natal_resp.status_code}")
                except Exception as e:
                    print(f"❌ Enhanced natal chart: Error - {e}")
                
                print("\n🚀 READY FOR NEXT STEPS:")
                print("1. Test Flutter app with production API")
                print("2. Set up Firebase production environment")
                print("3. Create beta APK for testing")
                print("4. Begin beta user recruitment")
                
                return True
                
            else:
                print(f"⚠️  Old version still active: {version}")
                print("💡 Manual deployment may be needed on Render.com")
                
                print("\n📋 WHAT TO DO:")
                print("1. Go to https://dashboard.render.com/")
                print("2. Find 'astroyorumai-api' service")
                print("3. Click 'Manual Deploy'")
                print("4. Select latest commit (121ec6c)")
                print("5. Wait 3-5 minutes for deployment")
                
                return False
        else:
            print(f"❌ API Error: {response.status_code}")
            print("💡 Service may be starting up, try again in 2 minutes")
            return False
            
    except Exception as e:
        print(f"❌ Connection Error: {e}")
        print("💡 Check internet connection or Render service status")
        return False

def main():
    """Main monitoring function"""
    success = check_deployment_status()
    
    if not success:
        print("\n" + "=" * 50)
        print("⏰ Will check again in 2 minutes...")
        print("🔄 Run this script again to monitor deployment progress")
        print("=" * 50)
    
    return success

if __name__ == "__main__":
    main()
