#!/usr/bin/env python3
"""
Test script to verify the /natal endpoint is working correctly
"""
import requests
import json
import sys
from datetime import datetime

def test_natal_endpoint():
    """Test the /natal endpoint with sample data"""
    
    # Test both local and deployed URLs
    test_urls = [
        "http://localhost:5000",
        "https://astroyorumai.onrender.com"
    ]
    
    # Sample test data
    test_data = {
        "date": "1990-06-15",
        "time": "14:30",
        "latitude": 41.0082,
        "longitude": 28.9784
    }
    
    print("=" * 60)
    print("NATAL ENDPOINT TEST - AstroYorumAI")
    print("=" * 60)
    print(f"Test data: {json.dumps(test_data, indent=2)}")
    print()
    
    for base_url in test_urls:
        print(f"Testing: {base_url}")
        print("-" * 40)
        
        # Test health endpoint first
        try:
            health_response = requests.get(f"{base_url}/health", timeout=10)
            if health_response.status_code == 200:
                print("✓ Health endpoint: WORKING")
                health_data = health_response.json()
                print(f"  Version: {health_data.get('version', 'unknown')}")
            else:
                print(f"✗ Health endpoint: FAILED ({health_response.status_code})")
                continue
        except Exception as e:
            print(f"✗ Health endpoint: CONNECTION FAILED ({str(e)})")
            continue
        
        # Test natal endpoint
        try:
            natal_url = f"{base_url}/natal"
            headers = {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            }
            
            natal_response = requests.post(
                natal_url, 
                json=test_data, 
                headers=headers,
                timeout=30
            )
            
            print(f"Natal endpoint response: {natal_response.status_code}")
            
            if natal_response.status_code == 200:
                print("✓ Natal endpoint: WORKING")
                result = natal_response.json()
                
                # Check if we have planets data
                if 'planets' in result:
                    print(f"  Planets found: {len(result['planets'])}")
                    for planet, data in result['planets'].items():
                        if isinstance(data, dict) and 'sign' in data:
                            print(f"    {planet}: {data['sign']} ({data.get('deg', 'N/A')}°)")
                
                # Check ascendant
                if 'ascendant' in result:
                    asc_deg = result.get('ascendant_degree', 'N/A')
                    print(f"  Ascendant: {result['ascendant']} ({asc_deg}°)")
                
                print(f"  Calculation method: {result.get('calculation_method', 'unknown')}")
                
            elif natal_response.status_code == 404:
                print("✗ Natal endpoint: NOT FOUND (404)")
                print("  This is the main issue - endpoint exists in code but not accessible")
                
            elif natal_response.status_code == 500:
                print("✗ Natal endpoint: SERVER ERROR (500)")
                try:
                    error_data = natal_response.json()
                    print(f"  Error: {error_data.get('error', 'Unknown error')}")
                except:
                    print(f"  Raw error: {natal_response.text}")
                    
            else:
                print(f"✗ Natal endpoint: UNEXPECTED STATUS ({natal_response.status_code})")
                print(f"  Response: {natal_response.text}")
                
        except requests.exceptions.Timeout:
            print("✗ Natal endpoint: TIMEOUT")
        except requests.exceptions.ConnectionError:
            print("✗ Natal endpoint: CONNECTION ERROR")
        except Exception as e:
            print(f"✗ Natal endpoint: ERROR ({str(e)})")
        
        print()

if __name__ == "__main__":
    test_natal_endpoint()
