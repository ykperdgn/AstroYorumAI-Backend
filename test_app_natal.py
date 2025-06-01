#!/usr/bin/env python3
"""
Test the updated app.py natal endpoint locally
"""
import json
import sys
import os

# Add current directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

def test_app_natal_endpoint():
    try:
        from app import app
        
        # Test data
        test_data = {
            "date": "1990-01-15",
            "time": "14:30",
            "latitude": 40.7128,
            "longitude": -74.0060
        }
        
        print("Testing app.py natal endpoint locally...")
        print(f"Test data: {json.dumps(test_data, indent=2)}")
        
        with app.test_client() as client:
            response = client.post('/natal', json=test_data)
            
            print(f"Status Code: {response.status_code}")
            
            if response.status_code == 200:
                data = response.get_json()
                print("SUCCESS: Request successful!")
                print(f"Response keys: {list(data.keys())}")
                
                if "planets" in data and "message" in data:
                    message = data.get("message", "")
                    print(f"Message: {message}")
                    
                    if "Real astrological calculation completed" in message:
                        print("SUCCESS: Real flatlib calculations working!")
                        print("Planets:")
                        for planet, info in data.get("planets", {}).items():
                            print(f"  {planet}: {info}")
                        return True
                    else:
                        print("INFO: Using fallback data")
                        print(f"Full response: {json.dumps(data, indent=2)}")
                        return False
                else:
                    print(f"ERROR: Unexpected response structure: {data}")
                    return False
            else:
                print(f"ERROR: Request failed with status {response.status_code}")
                print(f"Response: {response.get_data(as_text=True)}")
                return False
                
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_app_natal_endpoint()
    print(f"\nTest result: {'PASSED' if success else 'FAILED'}")
