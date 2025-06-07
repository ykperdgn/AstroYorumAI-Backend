#!/usr/bin/env python3
"""
Comprehensive backend API test to verify all astrology features
"""
import requests
import json
import sys
from datetime import datetime

# Backend URL'leri
PRODUCTION_URL = "https://astroyorumai-backend-production.up.railway.app"
AZTRO_API_URL = "https://aztro.sameerkumar.website"

def test_health_check():
    """Test backend health check"""
    print("🔍 Testing Backend Health Check...")
    try:
        response = requests.get(f"{PRODUCTION_URL}/health", timeout=10)
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Health Check: {data}")
            return True
        else:
            print(f"❌ Health Check Failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health Check Error: {e}")
        return False

def test_natal_chart_api():
    """Test natal chart calculation API"""
    print("\n🔍 Testing Natal Chart API...")
    try:
        payload = {
            "date": "1990-05-15",
            "time": "14:30",
            "latitude": 41.0082,
            "longitude": 28.9784
        }
        
        response = requests.post(
            f"{PRODUCTION_URL}/natal",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Natal Chart API Success")
            print(f"   Planets: {list(data.get('planets', {}).keys())}")
            print(f"   Ascendant: {data.get('ascendant', 'N/A')}")
            print(f"   Turkish Converted: {data.get('turkish_converted', False)}")
            return True
        else:
            print(f"❌ Natal Chart API Failed: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Natal Chart API Error: {e}")
        return False

def test_aztro_daily_horoscope():
    """Test Aztro daily horoscope API"""
    print("\n🔍 Testing Aztro Daily Horoscope API...")
    try:
        # Test with Aries sign
        response = requests.post(
            f"{AZTRO_API_URL}/?sign=aries&day=today",
            timeout=10
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Aztro API Success")
            print(f"   Current Date: {data.get('current_date', 'N/A')}")
            print(f"   Description Length: {len(data.get('description', ''))}")
            print(f"   Compatibility: {data.get('compatibility', 'N/A')}")
            print(f"   Mood: {data.get('mood', 'N/A')}")
            return True
        else:
            print(f"❌ Aztro API Failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Aztro API Error: {e}")
        return False

def test_missing_endpoints():
    """Test for missing advanced features"""
    print("\n🔍 Testing Missing Advanced Features...")
    
    missing_features = []
    
    # Test for synastry/compatibility endpoint
    try:
        response = requests.post(f"{PRODUCTION_URL}/synastry", json={}, timeout=5)
        if response.status_code == 404:
            missing_features.append("Synastry/Compatibility Analysis")
    except:
        missing_features.append("Synastry/Compatibility Analysis")
    
    # Test for transit endpoint
    try:
        response = requests.post(f"{PRODUCTION_URL}/transit", json={}, timeout=5)
        if response.status_code == 404:
            missing_features.append("Transit Analysis")
    except:
        missing_features.append("Transit Analysis")
    
    # Test for solar return endpoint
    try:
        response = requests.post(f"{PRODUCTION_URL}/solar-return", json={}, timeout=5)
        if response.status_code == 404:
            missing_features.append("Solar Return Analysis")
    except:
        missing_features.append("Solar Return Analysis")
        
    # Test for progression endpoint
    try:
        response = requests.post(f"{PRODUCTION_URL}/progression", json={}, timeout=5)
        if response.status_code == 404:
            missing_features.append("Progression Analysis")
    except:
        missing_features.append("Progression Analysis")
    
    # Test for horary endpoint
    try:
        response = requests.post(f"{PRODUCTION_URL}/horary", json={}, timeout=5)
        if response.status_code == 404:
            missing_features.append("Horary Astrology")
    except:
        missing_features.append("Horary Astrology")
    
    # Test for composite endpoint
    try:
        response = requests.post(f"{PRODUCTION_URL}/composite", json={}, timeout=5)
        if response.status_code == 404:
            missing_features.append("Composite Chart")
    except:
        missing_features.append("Composite Chart")
    
    if missing_features:
        print("❌ Missing Backend Features:")
        for feature in missing_features:
            print(f"   - {feature}")
        return False
    else:
        print("✅ All advanced features available")
        return True

def check_frontend_features():
    """Check what frontend features exist vs what actually works"""
    print("\n🔍 Frontend Features Analysis...")
    
    # Features that exist in code but may not work
    frontend_features = {
        "Natal Chart Display": "✅ EXISTS - Basic implementation",
        "Daily Horoscope": "⚠️ PARTIAL - Depends on Aztro API",
        "Weekly Horoscope": "⚠️ PARTIAL - Depends on Aztro API", 
        "Monthly Horoscope": "⚠️ PARTIAL - Depends on Aztro API",
        "Transit Analysis": "❓ UNCLEAR - UI exists but backend missing",
        "Synastry Analysis": "❓ UNCLEAR - UI exists but backend incomplete",
        "Astrology Calendar": "✅ EXISTS - Basic celestial events",
        "Horary Questions": "❓ UNCLEAR - UI exists but functionality limited",
        "Notification System": "✅ EXISTS - Basic notification scheduling",
        "PDF Export": "❓ UNCLEAR - Code exists but needs testing",
        "User Profiles": "✅ EXISTS - Profile management working",
        "Solar Return": "❌ MISSING - No implementation found",
        "Progression": "❌ MISSING - No implementation found", 
        "Composite Charts": "❌ MISSING - No implementation found",
        "AI Interpretations": "❌ MISSING - No AI integration found",
        "Advanced Transit Tracking": "❌ MISSING - Only basic transit UI",
        "Real-time Planetary Positions": "⚠️ PARTIAL - Only natal chart"
    }
    
    print("Frontend Feature Status:")
    for feature, status in frontend_features.items():
        print(f"   {feature}: {status}")
    
    return frontend_features

def main():
    """Run comprehensive tests"""
    print("🚀 AstroYorumAI Comprehensive Feature Test")
    print("=" * 50)
    
    # Test backend APIs
    health_ok = test_health_check()
    natal_ok = test_natal_chart_api()
    horoscope_ok = test_aztro_daily_horoscope()
    advanced_ok = test_missing_endpoints()
    
    # Check frontend features
    frontend_features = check_frontend_features()
    
    # Summary
    print("\n" + "=" * 50)
    print("📊 TEST SUMMARY")
    print("=" * 50)
    
    backend_score = sum([health_ok, natal_ok, horoscope_ok]) / 3 * 100
    print(f"Backend Basic Features: {backend_score:.0f}% Working")
    
    if not advanced_ok:
        print("❌ Advanced Backend Features: 0% Working (All missing)")
    
    # Count frontend features
    total_features = len(frontend_features)
    working_features = sum(1 for status in frontend_features.values() if "✅" in status)
    partial_features = sum(1 for status in frontend_features.values() if "⚠️" in status)
    missing_features = sum(1 for status in frontend_features.values() if "❌" in status)
    
    print(f"Frontend Features:")
    print(f"   ✅ Working: {working_features}/{total_features}")
    print(f"   ⚠️ Partial: {partial_features}/{total_features}")
    print(f"   ❌ Missing: {missing_features}/{total_features}")
    
    overall_score = (working_features + partial_features * 0.5) / total_features * 100
    print(f"   Overall Frontend: {overall_score:.0f}% Complete")
    
    print("\n🎯 RECOMMENDATIONS:")
    if missing_features > 0:
        print("   1. Implement missing backend endpoints for advanced features")
        print("   2. Complete partial frontend implementations")
        print("   3. Add comprehensive testing for all features")
        print("   4. Implement AI-powered interpretations")
        print("   5. Add real PDF export functionality")
    
    if overall_score < 80:
        print(f"   ⚠️ Application only {overall_score:.0f}% complete - NOT READY for publication")
    else:
        print(f"   ✅ Application {overall_score:.0f}% complete - Ready for publication")

if __name__ == "__main__":
    main()
