#!/usr/bin/env python3
"""
Final integration test for all astrology features before production
"""
import requests
import json
from datetime import datetime

API_BASE_URL = "https://astroyorumai-api.onrender.com"

def test_all_endpoints():
    """Test all 6 astrology endpoints with realistic data"""
    
    # Test data for two people
    person1_data = {
        "name": "Test Kişi 1",
        "date": "1990-05-15",
        "time": "14:30",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    person2_data = {
        "name": "Test Kişi 2", 
        "date": "1988-08-22",
        "time": "09:15",
        "latitude": 39.9334,
        "longitude": 32.8597
    }
    
    endpoints_to_test = [
        {
            "name": "Transit Analysis",
            "url": f"{API_BASE_URL}/transit",
            "data": {
                "name": person1_data["name"],
                "birth_date": person1_data["date"],
                "birth_time": person1_data["time"],
                "latitude": person1_data["latitude"],
                "longitude": person1_data["longitude"],
                "transit_date": datetime.now().strftime("%Y-%m-%d")
            }
        },
        {
            "name": "Solar Return",
            "url": f"{API_BASE_URL}/solar-return",
            "data": {
                "name": person1_data["name"],
                "birth_date": person1_data["date"],
                "birth_time": person1_data["time"],
                "latitude": person1_data["latitude"],
                "longitude": person1_data["longitude"],
                "return_year": 2024
            }
        },
        {
            "name": "Secondary Progressions",
            "url": f"{API_BASE_URL}/progression",
            "data": {
                "name": person1_data["name"],
                "birth_date": person1_data["date"],
                "birth_time": person1_data["time"],
                "latitude": person1_data["latitude"],
                "longitude": person1_data["longitude"],
                "progression_date": datetime.now().strftime("%Y-%m-%d")
            }
        },
        {
            "name": "Horary Astrology",
            "url": f"{API_BASE_URL}/horary",
            "data": {
                "question": "Bu proje başarılı olacak mı?",
                "question_date": datetime.now().strftime("%Y-%m-%d"),
                "question_time": "15:30",
                "latitude": 41.0082,
                "longitude": 28.9784
            }
        },
        {
            "name": "Synastry Analysis",
            "url": f"{API_BASE_URL}/synastry",
            "data": {
                "person1": person1_data,
                "person2": person2_data
            }
        },
        {
            "name": "Composite Chart",
            "url": f"{API_BASE_URL}/composite",
            "data": {
                "person1": person1_data,
                "person2": person2_data
            }
        }
    ]
    
    print("🚀 Final Integration Test - All Astrology Features")
    print("=" * 60)
    
    all_passed = True
    
    for endpoint in endpoints_to_test:
        print(f"\n📊 Testing {endpoint['name']}...")
        try:
            response = requests.post(
                endpoint['url'],
                json=endpoint['data'],
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                if 'error' not in data:
                    print(f"✅ {endpoint['name']}: SUCCESS")
                    # Check for Turkish content
                    content_str = json.dumps(data, ensure_ascii=False)
                    if any(char in content_str for char in ['ç', 'ğ', 'ı', 'ö', 'ş', 'ü', 'Ç', 'Ğ', 'İ', 'Ö', 'Ş', 'Ü']):
                        print(f"   🇹🇷 Turkish content detected")
                    else:
                        print(f"   ⚠️  No Turkish characters detected")
                else:
                    print(f"❌ {endpoint['name']}: API Error - {data.get('error', 'Unknown error')}")
                    all_passed = False
            else:
                print(f"❌ {endpoint['name']}: HTTP {response.status_code}")
                print(f"   Response: {response.text[:200]}...")
                all_passed = False
                
        except requests.exceptions.RequestException as e:
            print(f"❌ {endpoint['name']}: Connection Error - {str(e)}")
            all_passed = False
        except Exception as e:
            print(f"❌ {endpoint['name']}: Unexpected Error - {str(e)}")
            all_passed = False
    
    print("\n" + "=" * 60)
    if all_passed:
        print("🎉 ALL TESTS PASSED! Ready for production deployment.")
    else:
        print("⚠️  Some tests failed. Please check the issues above.")
    print("=" * 60)
    
    return all_passed

if __name__ == "__main__":
    test_all_endpoints()
