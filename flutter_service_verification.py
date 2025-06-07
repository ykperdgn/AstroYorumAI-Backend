#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Complete Integration Verification
Tests the exact same calls that Flutter will make to the backend
"""

import requests
import json
import time

def test_exact_flutter_integration():
    """Test using the exact same payloads and format as Flutter service"""
    
    print("🔧 FLUTTER SERVICE INTEGRATION VERIFICATION")
    print("=" * 60)
    print("Testing exact service method calls from Flutter frontend")
    print()
    
    base_url = "https://astroyorumai-api.onrender.com"
    
    # Flutter service method headers
    headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
    }
    
    test_results = {}
    
    # Test 1: getSynastryAnalysis (exact Flutter service parameters)
    print("🔍 Testing getSynastryAnalysis()")
    try:
        payload = {
            'person1': {
                'name': 'Test Person 1',
                'date': '1990-05-15',
                'time': '14:30:00',
                'latitude': 41.0082,
                'longitude': 28.9784,
            },
            'person2': {
                'name': 'Test Person 2',
                'date': '1992-08-22',
                'time': '09:15:00',
                'latitude': 39.9334,
                'longitude': 32.8597,
            },
        }
        
        response = requests.post(
            f"{base_url}/synastry",
            headers=headers,
            json=payload,
            timeout=30
        )
        
        success = response.status_code == 200
        test_results['synastry'] = {
            'success': success,
            'status_code': response.status_code,
            'has_data': 'synastry_analysis' in response.json() if success else False
        }
        print(f"   Status: {response.status_code} {'✅' if success else '❌'}")
        
    except Exception as e:
        test_results['synastry'] = {'success': False, 'error': str(e)}
        print(f"   Error: {str(e)} ❌")
    
    # Test 2: getTransitAnalysis
    print("🔍 Testing getTransitAnalysis()")
    try:
        payload = {
            'birth_date': '1990-05-15',
            'birth_time': '14:30:00',
            'latitude': 41.0082,
            'longitude': 28.9784,
        }
        
        response = requests.post(
            f"{base_url}/transit",
            headers=headers,
            json=payload,
            timeout=30
        )
        
        success = response.status_code == 200
        test_results['transit'] = {
            'success': success,
            'status_code': response.status_code,
            'has_data': 'transit_analysis' in response.json() if success else False
        }
        print(f"   Status: {response.status_code} {'✅' if success else '❌'}")
        
    except Exception as e:
        test_results['transit'] = {'success': False, 'error': str(e)}
        print(f"   Error: {str(e)} ❌")
    
    # Test 3: getSolarReturn
    print("🔍 Testing getSolarReturn()")
    try:
        payload = {
            'birth_date': '1990-05-15',
            'birth_time': '14:30:00',
            'latitude': 41.0082,
            'longitude': 28.9784,
            'year': 2024,
        }
        
        response = requests.post(
            f"{base_url}/solar-return",
            headers=headers,
            json=payload,
            timeout=30
        )
        
        success = response.status_code == 200
        test_results['solar_return'] = {
            'success': success,
            'status_code': response.status_code,
            'has_data': 'solar_return' in response.json() if success else False
        }
        print(f"   Status: {response.status_code} {'✅' if success else '❌'}")
        
    except Exception as e:
        test_results['solar_return'] = {'success': False, 'error': str(e)}
        print(f"   Error: {str(e)} ❌")
    
    # Test 4: getProgressionAnalysis
    print("🔍 Testing getProgressionAnalysis()")
    try:
        payload = {
            'birth_date': '1990-05-15',
            'birth_time': '14:30:00',
            'latitude': 41.0082,
            'longitude': 28.9784,
        }
        
        response = requests.post(
            f"{base_url}/progression",
            headers=headers,
            json=payload,
            timeout=30
        )
        
        success = response.status_code == 200
        test_results['progression'] = {
            'success': success,
            'status_code': response.status_code,
            'has_data': 'progression_analysis' in response.json() if success else False
        }
        print(f"   Status: {response.status_code} {'✅' if success else '❌'}")
        
    except Exception as e:
        test_results['progression'] = {'success': False, 'error': str(e)}
        print(f"   Error: {str(e)} ❌")
    
    # Test 5: getHoraryAnalysis  
    print("🔍 Testing getHoraryAnalysis()")
    try:
        payload = {
            'question': 'Test sorusu için analiz',
            'latitude': 41.0082,
            'longitude': 28.9784,
        }
        
        response = requests.post(
            f"{base_url}/horary",
            headers=headers,
            json=payload,
            timeout=30
        )
        
        success = response.status_code == 200
        test_results['horary'] = {
            'success': success,
            'status_code': response.status_code,
            'has_data': 'horary_analysis' in response.json() if success else False
        }
        print(f"   Status: {response.status_code} {'✅' if success else '❌'}")
        
    except Exception as e:
        test_results['horary'] = {'success': False, 'error': str(e)}
        print(f"   Error: {str(e)} ❌")
    
    # Test 6: getCompositeChart
    print("🔍 Testing getCompositeChart()")
    try:
        payload = {
            'person1': {
                'name': 'Test Person 1',
                'date': '1990-05-15',
                'time': '14:30:00',
                'latitude': 41.0082,
                'longitude': 28.9784,
            },
            'person2': {
                'name': 'Test Person 2',
                'date': '1992-08-22',
                'time': '09:15:00',
                'latitude': 39.9334,
                'longitude': 32.8597,
            },
        }
        
        response = requests.post(
            f"{base_url}/composite",
            headers=headers,
            json=payload,
            timeout=30
        )
        
        success = response.status_code == 200
        test_results['composite'] = {
            'success': success,
            'status_code': response.status_code,
            'has_data': 'composite_chart' in response.json() if success else False
        }
        print(f"   Status: {response.status_code} {'✅' if success else '❌'}")
        
    except Exception as e:
        test_results['composite'] = {'success': False, 'error': str(e)}
        print(f"   Error: {str(e)} ❌")
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 FLUTTER SERVICE INTEGRATION SUMMARY")
    print("=" * 60)
    
    successful_tests = sum(1 for result in test_results.values() if result.get('success', False))
    total_tests = len(test_results)
    
    print(f"✅ Successful Tests: {successful_tests}/{total_tests}")
    print(f"❌ Failed Tests: {total_tests - successful_tests}/{total_tests}")
    
    if successful_tests == total_tests:
        print("\n🎉 ALL FLUTTER SERVICE METHODS VERIFIED!")
        print("✅ Flutter frontend is ready to use all advanced features")
        print("✅ Backend API is fully compatible with Flutter service calls")
        print("✅ Production deployment is ready")
    else:
        print(f"\n⚠️ {total_tests - successful_tests} service method(s) need attention")
    
    print("\n🎯 NEXT STEPS:")
    print("1. ✅ Open Flutter app: http://127.0.0.1:59470/Sd_dXkYZiDw=")
    print("2. 🔄 Click 'Test Advanced Features' button (visible in debug mode)")
    print("3. 🔄 Verify all tests pass in Flutter UI")
    print("4. 🔄 Check Turkish text displays correctly")
    print("5. 📋 Create remaining visualization screens")
    
    return test_results

if __name__ == "__main__":
    results = test_exact_flutter_integration()
    
    # Save results for documentation
    with open('flutter_integration_results.json', 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
