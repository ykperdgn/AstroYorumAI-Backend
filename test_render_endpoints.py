#!/usr/bin/env python3
"""
Test yeni eklenen astroloji endpoint'lerini - Render backend'i ile
"""
import requests
import json
from datetime import datetime

# Render backend URL'i
RENDER_URL = "https://astroyorumai-api.onrender.com"

def test_new_endpoints():
    """Test all newly implemented astrology endpoints"""
    print("🚀 Testing New Astrology Endpoints on Render Backend")
    print("=" * 60)
    
    # Test data
    person1_data = {
        "date": "1990-05-15",
        "time": "14:30:00",
        "latitude": 41.0082,
        "longitude": 28.9784,
        "name": "Ali"
    }
    
    person2_data = {
        "date": "1992-08-22",
        "time": "09:15:00",
        "latitude": 39.9334,
        "longitude": 32.8597,
        "name": "Ayşe"
    }
    
    # Test endpoints
    endpoints_to_test = [
        {
            "endpoint": "/synastry",
            "data": {"person1": person1_data, "person2": person2_data},
            "name": "Synastry (Uyumluluk Analizi)"
        },
        {
            "endpoint": "/transit", 
            "data": {
                "birth_date": "1990-05-15",
                "birth_time": "14:30:00",
                "latitude": 41.0082,
                "longitude": 28.9784,
                "transit_date": datetime.now().strftime('%Y-%m-%d')
            },
            "name": "Transit Analysis"
        },
        {
            "endpoint": "/solar-return",
            "data": {
                "birth_date": "1990-05-15",
                "birth_time": "14:30:00", 
                "latitude": 41.0082,
                "longitude": 28.9784,
                "year": 2024
            },
            "name": "Solar Return Chart"
        },
        {
            "endpoint": "/progression",
            "data": {
                "birth_date": "1990-05-15",
                "birth_time": "14:30:00",
                "latitude": 41.0082,
                "longitude": 28.9784,
                "progression_date": datetime.now().strftime('%Y-%m-%d')
            },
            "name": "Secondary Progressions"
        },
        {
            "endpoint": "/horary",
            "data": {
                "question": "İş değişikliği yapmalı mıyım?",
                "latitude": 41.0082,
                "longitude": 28.9784,
                "question_time": datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            },
            "name": "Enhanced Horary Astrology"
        },
        {
            "endpoint": "/composite",
            "data": {"person1": person1_data, "person2": person2_data},
            "name": "Composite Chart Analysis"
        }
    ]
    
    results = []
    
    for test in endpoints_to_test:
        print(f"\n🔍 Testing {test['name']}")
        print(f"Endpoint: {test['endpoint']}")
        
        try:
            response = requests.post(
                f"{RENDER_URL}{test['endpoint']}", 
                json=test['data'], 
                timeout=30
            )
            
            print(f"Status Code: {response.status_code}")
            
            if response.status_code == 200:
                result = response.json()
                print("✅ SUCCESS")
                print(f"Response keys: {list(result.keys())}")
                results.append({"endpoint": test['endpoint'], "status": "SUCCESS"})
            elif response.status_code == 404:
                print("❌ NOT FOUND - Endpoint not deployed yet")
                results.append({"endpoint": test['endpoint'], "status": "NOT_DEPLOYED"})
            else:
                print(f"❌ FAILED - Status: {response.status_code}")
                print(f"Error: {response.text}")
                results.append({"endpoint": test['endpoint'], "status": "ERROR"})
                
        except Exception as e:
            print(f"❌ CONNECTION ERROR: {str(e)}")
            results.append({"endpoint": test['endpoint'], "status": "CONNECTION_ERROR"})
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 TEST SUMMARY")
    print("=" * 60)
    
    success_count = len([r for r in results if r['status'] == 'SUCCESS'])
    not_deployed_count = len([r for r in results if r['status'] == 'NOT_DEPLOYED'])
    error_count = len([r for r in results if r['status'] in ['ERROR', 'CONNECTION_ERROR']])
    
    print(f"✅ Working Endpoints: {success_count}/6")
    print(f"❌ Not Deployed: {not_deployed_count}/6") 
    print(f"⚠️ Errors: {error_count}/6")
    
    if not_deployed_count > 0:
        print("\n🚀 NEXT STEPS:")
        print("1. Deploy updated app.py to Render backend")
        print("2. Re-test all endpoints after deployment")
        print("3. Update Flutter frontend to connect to new endpoints")
        
    return results

if __name__ == "__main__":
    test_new_endpoints()
