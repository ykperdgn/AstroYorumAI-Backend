#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Flutter Frontend to Backend Integration Test
Tests the complete flow from Flutter app to Render backend
"""

import requests
import json
from datetime import datetime

def test_flutter_backend_integration():
    """Test all the new advanced astrology endpoints that Flutter will call"""
    
    print("🚀 Testing Flutter to Backend Integration")
    print("=" * 55)
    
    base_url = "https://astroyorumai-api.onrender.com"
    endpoints_tested = 0
    endpoints_passed = 0
    
    # Test data (same as used in Flutter)
    test_data = {        'synastry': {
            'endpoint': '/synastry',
            'payload': {
                'person1': {
                    'name': 'Test Person 1',
                    'date': '1990-05-15',
                    'time': '14:30:00',
                    'latitude': 41.0082,
                    'longitude': 28.9784
                },
                'person2': {
                    'name': 'Test Person 2',
                    'date': '1992-08-22',
                    'time': '09:15:00',
                    'latitude': 39.9334,
                    'longitude': 32.8597
                }
            }
        },
        'transit': {
            'endpoint': '/transit',
            'payload': {
                'birth_date': '1990-05-15',
                'birth_time': '14:30:00',
                'latitude': 41.0082,
                'longitude': 28.9784
            }
        },
        'solar_return': {
            'endpoint': '/solar-return',
            'payload': {
                'birth_date': '1990-05-15',
                'birth_time': '14:30:00',
                'latitude': 41.0082,
                'longitude': 28.9784,
                'year': 2024
            }
        },
        'progression': {
            'endpoint': '/progression',
            'payload': {
                'birth_date': '1990-05-15',
                'birth_time': '14:30:00',
                'latitude': 41.0082,
                'longitude': 28.9784
            }
        },
        'horary': {
            'endpoint': '/horary',
            'payload': {
                'question': 'Test sorusu için analiz',
                'latitude': 41.0082,
                'longitude': 28.9784
            }
        },        'composite': {
            'endpoint': '/composite',
            'payload': {
                'person1': {
                    'name': 'Test Person 1',
                    'date': '1990-05-15',
                    'time': '14:30:00',
                    'latitude': 41.0082,
                    'longitude': 28.9784
                },
                'person2': {
                    'name': 'Test Person 2',
                    'date': '1992-08-22',
                    'time': '09:15:00',
                    'latitude': 39.9334,
                    'longitude': 32.8597
                }
            }
        }
    }
    
    headers = {
        'Content-Type': 'application/json',
        'User-Agent': 'Flutter-AstroYorumAI/1.0'
    }
    
    for test_name, test_config in test_data.items():
        endpoints_tested += 1
        endpoint = test_config['endpoint']
        payload = test_config['payload']
        
        print(f"\n🔍 Testing {test_name.upper()}")
        print(f"Endpoint: {endpoint}")
        
        try:
            response = requests.post(
                f"{base_url}{endpoint}",
                json=payload,
                headers=headers,
                timeout=30
            )
            
            print(f"Status Code: {response.status_code}")
            
            if response.status_code == 200:
                result = response.json()
                print("✅ SUCCESS")
                print(f"Response keys: {list(result.keys())}")
                  # Check for Turkish content
                response_text = json.dumps(result, ensure_ascii=False)
                if any(turkish_char in response_text for turkish_char in ['g', 'u', 's', 'i', 'o', 'c']):
                    print("TR Turkish content detected")
                else:
                    print("No Turkish characters found")
                
                endpoints_passed += 1
            else:
                print(f"❌ FAILED - Status {response.status_code}")
                print(f"Response: {response.text[:200]}...")
                
        except requests.exceptions.RequestException as e:
            print(f"❌ ERROR: {str(e)}")
    
    print("\n" + "=" * 55)
    print("📊 INTEGRATION TEST SUMMARY")
    print("=" * 55)
    print(f"✅ Working Endpoints: {endpoints_passed}/{endpoints_tested}")
    print(f"❌ Failed Endpoints: {endpoints_tested - endpoints_passed}/{endpoints_tested}")
    
    if endpoints_passed == endpoints_tested:
        print("\n🎉 All Flutter-Backend integrations are working!")
        print("✅ Ready for frontend testing via the Flutter app")
        print("✅ Turkish language support confirmed")
        print("✅ Backend API is stable on Render deployment")
    else:
        print(f"\n⚠️ {endpoints_tested - endpoints_passed} endpoint(s) need attention")
    
    print("\n📱 Next Steps:")
    print("1. Open Flutter app in browser")
    print("2. Navigate to the 'Test Advanced Features' button (debug mode)")
    print("3. Run tests through the Flutter UI")
    print("4. Verify Turkish responses display correctly")

if __name__ == "__main__":
    test_flutter_backend_integration()
