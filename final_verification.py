#!/usr/bin/env python3
"""
Final deployment verification script for AstroYorumAI API
Run this script AFTER manually deploying on Render.com to verify everything works
"""
import requests
import json
import time

def test_full_deployment():
    """Test the complete API deployment"""
    base_url = "https://astroyorumai-api.onrender.com"
    
    print("🚀 AstroYorumAI API - Final Deployment Verification")
    print("=" * 60)
    print("This script verifies that the manual Render.com deployment is working")
    print("=" * 60)
    
    # Test 1: Health Check
    print("\n1️⃣ Testing Health Check...")
    try:
        response = requests.get(f"{base_url}/health", timeout=30)
        if response.status_code == 200:
            print("✅ Health check passed!")
            print(f"   Response: {response.json()}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {e}")
        print("💡 Tip: Service might be starting up, wait 1-2 minutes and try again")
        return False
    
    # Test 2: Root Endpoint
    print("\n2️⃣ Testing Root Endpoint...")
    try:
        response = requests.get(f"{base_url}/", timeout=30)
        if response.status_code == 200:
            print("✅ Root endpoint passed!")
            print(f"   Response: {response.json()}")
        else:
            print(f"❌ Root endpoint failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Root endpoint error: {e}")
    
    # Test 3: Natal Chart API
    print("\n3️⃣ Testing Natal Chart API...")
    test_data = {
        "date": "1990-01-01",
        "time": "12:00",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    try:
        response = requests.post(f"{base_url}/natal", json=test_data, timeout=30)
        if response.status_code == 200:
            result = response.json()
            print("✅ Natal chart API passed!")
            print(f"   Planets found: {len(result.get('planets', {}))}")
            print(f"   Ascendant: {result.get('ascendant', 'N/A')}")
            print(f"   Sample planet: {list(result.get('planets', {}).items())[0] if result.get('planets') else 'None'}")
        else:
            print(f"❌ Natal chart API failed: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Natal chart API error: {e}")
        return False
    
    # Test 4: CORS Headers
    print("\n4️⃣ Testing CORS Headers...")
    try:
        response = requests.options(f"{base_url}/natal", headers={
            'Origin': 'http://localhost:3000',
            'Access-Control-Request-Method': 'POST',
            'Access-Control-Request-Headers': 'Content-Type'
        })
        cors_header = response.headers.get('Access-Control-Allow-Origin')
        if cors_header:
            print("✅ CORS headers present!")
            print(f"   Access-Control-Allow-Origin: {cors_header}")
        else:
            print("⚠️  CORS headers not found (might still work)")
    except Exception as e:
        print(f"⚠️  CORS test error: {e}")
    
    print("\n" + "=" * 60)
    print("🎉 DEPLOYMENT VERIFICATION COMPLETE!")
    print("✅ Your AstroYorumAI API is ready for production use!")
    print("\n📱 Next Steps:")
    print("1. Test the Flutter app with the production API")
    print("2. Set up Firebase production environment")
    print("3. Prepare for beta testing")
    print("=" * 60)
    
    return True

if __name__ == "__main__":
    success = test_full_deployment()
    if not success:
        print("\n🔧 Troubleshooting:")
        print("- Check Render.com dashboard for deployment status")
        print("- Verify build logs for any errors")
        print("- Ensure the service is not sleeping (first request might be slow)")
        print("- Try again in 2-3 minutes")
