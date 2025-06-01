import requests
import time

def test_render_deployment():
    """Test the Render.com deployment after manual redeploy"""
    url = "https://astroyorumai-api.onrender.com"
    
    print("🔄 Testing Render.com deployment...")
    print("⏳ Waiting for service to wake up (this may take 30-60 seconds)...")
    
    # Test root endpoint
    try:
        print(f"Testing: {url}/")
        response = requests.get(f"{url}/", timeout=90)
        print(f"✅ Root Status: {response.status_code}")
        if response.status_code == 200:
            print(f"Response: {response.json()}")
        else:
            print(f"Response: {response.text[:200]}")
    except Exception as e:
        print(f"❌ Root test failed: {e}")
        return False
    
    # Test health endpoint
    try:
        print(f"\nTesting: {url}/health")
        response = requests.get(f"{url}/health", timeout=60)
        print(f"✅ Health Status: {response.status_code}")
        if response.status_code == 200:
            print(f"Response: {response.json()}")
        else:
            print(f"Response: {response.text[:200]}")
    except Exception as e:
        print(f"❌ Health test failed: {e}")
    
    # Test natal endpoint
    try:
        print(f"\nTesting: {url}/natal")
        test_data = {
            "date": "1990-01-01",
            "time": "12:00",
            "latitude": 41.0082,
            "longitude": 28.9784
        }
        response = requests.post(f"{url}/natal", json=test_data, timeout=60)
        print(f"✅ Natal Status: {response.status_code}")
        if response.status_code == 200:
            print(f"Response: {response.json()}")
        else:
            print(f"Response: {response.text[:200]}")
    except Exception as e:
        print(f"❌ Natal test failed: {e}")
    
    print("\n🎉 Basic deployment test completed!")
    return True

if __name__ == "__main__":
    test_render_deployment()
