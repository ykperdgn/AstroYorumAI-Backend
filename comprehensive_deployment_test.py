#!/usr/bin/env python3
"""
Comprehensive deployment verification for AstroYorumAI API
"""
import requests
import json
import time

def test_url(url, name, method="GET", data=None):
    """Test a URL and return success status"""
    print(f"\n🔍 Testing {name}...")
    print(f"URL: {url}")
    
    try:
        if method == "POST":
            response = requests.post(url, json=data, timeout=30)
        else:
            response = requests.get(url, timeout=30)
        
        print(f"✅ Status: {response.status_code}")
        
        if response.status_code == 200:
            try:
                result = response.json()
                print(f"✅ Response: {json.dumps(result, indent=2)}")
            except:
                print(f"✅ Response: {response.text[:200]}")
            return True
        else:
            print(f"❌ Error Response: {response.text[:200]}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Connection failed - service not accessible")
        return False
    except requests.exceptions.Timeout:
        print("❌ Request timeout - service might be slow")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("🚀 AstroYorumAI API Deployment Verification")
    print("=" * 50)
    
    # Test different possible URLs
    test_urls = [
        ("https://astroyorumai-api.onrender.com", "Main URL"),
        ("https://astroyorumai-api.onrender.com/", "Main URL with slash"),
        ("https://astroyorumai-api.onrender.com/health", "Health endpoint"),
        ("https://astroyorumai-backend.onrender.com", "Alternative URL 1"),
        ("https://astroyorumai-backend.onrender.com/health", "Alternative URL 1 Health"),
        ("https://astroyorum-ai-backend.onrender.com", "Alternative URL 2"),
        ("https://astroyorum-ai-backend.onrender.com/health", "Alternative URL 2 Health"),
        ("https://astro-yorumai-api.onrender.com", "Alternative URL 3"),
        ("https://astro-yorumai-api.onrender.com/health", "Alternative URL 3 Health"),
    ]
    
    success_count = 0
    working_base_url = None
    
    for url, name in test_urls:
        if test_url(url, name):
            success_count += 1
            if not working_base_url and "/health" not in url:
                working_base_url = url.rstrip('/')
    
    # If we found a working URL, test the natal endpoint
    if working_base_url:
        print(f"\n🧪 Testing Natal Chart API on working URL: {working_base_url}")
        test_data = {
            "date": "1990-01-01",
            "time": "12:00", 
            "latitude": 41.0082,
            "longitude": 28.9784
        }
        test_url(f"{working_base_url}/natal", "Natal Chart API", "POST", test_data)
    
    print("\n" + "=" * 50)
    print(f"🏁 Verification completed. Successful tests: {success_count}")
    
    if success_count == 0:
        print("\n💡 Troubleshooting suggestions:")
        print("1. Check Render.com dashboard for deployment status")
        print("2. Verify the service name in render.yaml matches the URL")
        print("3. Check build logs for any errors")
        print("4. Ensure Procfile and requirements.txt are correct")
        print("5. Wait for deployment to complete (can take 5-10 minutes)")
        print("6. Check if the service is sleeping (free tier limitation)")

if __name__ == "__main__":
    main()
