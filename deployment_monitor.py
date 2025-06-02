#!/usr/bin/env python3
"""
Deployment Monitor - AstroYorumAI API
Monitors Render.com deployment and provides guidance
"""
import requests
import time
import json
from datetime import datetime

def check_api_version():
    """Check current API version"""
    try:
        response = requests.get("https://astroyorumai-api.onrender.com/", timeout=30)
        if response.status_code == 200:
            data = response.json()
            return data.get("version", "unknown")
        return None
    except Exception as e:
        print(f"❌ Error checking API: {e}")
        return None

def check_enhanced_features():
    """Check if enhanced features are available"""
    features = {
        "status_endpoint": False,
        "enhanced_natal": False,
        "correct_version": False
    }
    
    # Check /status endpoint
    try:
        response = requests.get("https://astroyorumai-api.onrender.com/status", timeout=30)
        features["status_endpoint"] = response.status_code == 200
    except:
        pass
    
    # Check natal endpoint structure
    try:
        test_data = {
            "date": "1990-06-15",
            "time": "14:30",
            "latitude": 41.0082,
            "longitude": 28.9784
        }
        response = requests.post("https://astroyorumai-api.onrender.com/natal", 
                               json=test_data, timeout=30)
        if response.status_code == 200:
            data = response.json()
            features["enhanced_natal"] = "planets" in data and "ascendant" in data
    except:
        pass
    
    # Check version
    version = check_api_version()
    features["correct_version"] = version == "2.1.2-stable"
    
    return features, version

def main():
    """Monitor deployment status"""
    print("🚀 AstroYorumAI Deployment Monitor")
    print("=" * 50)
    print(f"⏰ Started at: {datetime.now().strftime('%H:%M:%S')}")
    print("🔍 Monitoring Render.com deployment...")
    print("=" * 50)
    
    check_count = 0
    max_checks = 20  # Check for 10 minutes (every 30 seconds)
    
    while check_count < max_checks:
        check_count += 1
        current_time = datetime.now().strftime('%H:%M:%S')
        
        print(f"\n📋 Check #{check_count} at {current_time}")
        
        # Check features
        features, version = check_enhanced_features()
        
        print(f"📦 Current Version: {version}")
        print(f"✅ Status Endpoint: {'YES' if features['status_endpoint'] else 'NO'}")
        print(f"🪐 Enhanced Natal: {'YES' if features['enhanced_natal'] else 'NO'}")
        print(f"🎯 Correct Version: {'YES' if features['correct_version'] else 'NO'}")
        
        # Check if deployment is complete
        if all(features.values()):
            print("\n🎉 SUCCESS! Enhanced API (v2.1.2-stable) is LIVE!")
            print("=" * 50)
            print("✅ All features confirmed working:")
            print("   • Version: 2.1.2-stable")
            print("   • Status endpoint available")
            print("   • Enhanced natal chart data")
            print("   • Planetary positions with signs/degrees")
            print("   • Ascendant calculation")
            print("\n🚀 READY FOR NEXT STEPS:")
            print("   1. Test Flutter app with production API")
            print("   2. Set up Firebase production environment")
            print("   3. Begin beta testing recruitment")
            print("   4. Create beta APK for testing")
            print("=" * 50)
            return True
        
        if check_count >= max_checks:
            break
            
        # Wait before next check
        if check_count < max_checks:
            print("⏳ Waiting 30 seconds for next check...")
            time.sleep(30)
    
    # If we get here, deployment didn't complete
    print("\n⚠️ DEPLOYMENT MONITOR TIMEOUT")
    print("=" * 50)
    print("🔍 After 10 minutes of monitoring:")
    print(f"📦 Current Version: {version}")
    print(f"🎯 Enhanced Features: {sum(features.values())}/3 working")
    
    if version == "1.0.0":
        print("\n💡 MANUAL INTERVENTION NEEDED:")
        print("   Render.com is not picking up the latest commits.")
        print("   You need to manually trigger deployment:")
        print("\n📋 STEPS TO FIX:")
        print("   1. Go to https://dashboard.render.com/")
        print("   2. Find your 'astroyorumai-api' service")
        print("   3. Click 'Manual Deploy' button")
        print("   4. Select 'Deploy latest commit (1778303)'")
        print("   5. Wait 2-3 minutes for deployment")
        print("   6. Run this script again to verify")
    elif version and version != "2.1.2-stable":
        print(f"\n💡 PARTIAL DEPLOYMENT:")
        print(f"   Version {version} detected, expecting 2.1.2-stable")
        print("   Wait 5 more minutes and run script again")
    else:
        print("\n💡 API CONNECTIVITY ISSUES:")
        print("   Check internet connection and Render service status")
    
    print("=" * 50)
    return False

if __name__ == "__main__":
    success = main()
    if not success:
        print("\n🔄 To run this monitor again:")
        print("   python deployment_monitor.py")
