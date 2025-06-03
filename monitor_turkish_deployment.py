#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import time
import json
from datetime import datetime

def monitor_turkish_deployment():
    """Monitor Render deployment for Turkish API"""
    
    print("🚀 Monitoring Turkish API Deployment on Render...")
    print("=" * 60)
    
    start_time = time.time()
    max_wait_time = 300  # 5 minutes max
    check_interval = 30  # Check every 30 seconds
    
    target_version_keywords = ['2.1.3', 'turkish', 'real-calculations']
    
    while (time.time() - start_time) < max_wait_time:
        try:
            print(f"\n🔍 Checking API at {datetime.now().strftime('%H:%M:%S')}...")
            
            # Check main endpoint
            response = requests.get('https://astroyorumai-api.onrender.com/', timeout=15)
            
            if response.status_code == 200:
                data = response.json()
                version = data.get('version', 'N/A')
                build_time = data.get('build_timestamp', 'N/A')
                calc_method = data.get('calculation_method', 'N/A')
                language = data.get('language', 'N/A')
                
                print(f"📊 Current Status:")
                print(f"   Version: {version}")
                print(f"   Build Time: {build_time}")
                print(f"   Calculation Method: {calc_method}")
                print(f"   Language: {language}")
                
                # Check if Turkish version is deployed
                version_lower = version.lower()
                is_turkish_deployed = any(keyword in version_lower for keyword in target_version_keywords)
                
                if is_turkish_deployed:
                    print("\n✅ TURKISH VERSION DETECTED!")
                    
                    # Test natal chart with Turkish names
                    print("\n🧪 Testing Turkish natal chart...")
                    test_data = {
                        "date": "1990-06-15",
                        "time": "14:30", 
                        "latitude": 41.0082,
                        "longitude": 28.9784
                    }
                    
                    natal_response = requests.post('https://astroyorumai-api.onrender.com/natal', 
                                                 json=test_data, timeout=30)
                    
                    if natal_response.status_code == 200:
                        natal_data = natal_response.json()
                        planets = natal_data.get('planets', {})
                        
                        print("🌟 Sample Planets:")
                        count = 0
                        for planet, info in planets.items():
                            if count < 3:  # Show first 3 planets
                                if isinstance(info, dict):
                                    sign = info.get('sign', 'N/A')
                                    deg = info.get('deg', 'N/A')
                                    print(f"   {planet}: {sign} ({deg}°)")
                                count += 1
                        
                        # Check for Turkish planet names
                        turkish_planets = ['Güneş', 'Ay', 'Merkür', 'Venüs', 'Mars', 'Jüpiter', 'Satürn']
                        found_turkish = any(planet in planets for planet in turkish_planets)
                        
                        if found_turkish:
                            print("\n🎉 SUCCESS! Turkish planet names are working!")
                            print("✅ Deployment completed successfully!")
                            return True
                        else:
                            print("\n⚠️ API updated but still using English names...")
                    else:
                        print(f"\n❌ Natal chart test failed: {natal_response.status_code}")
                
                else:
                    print(f"\n⏳ Still waiting for Turkish deployment...")
                    print(f"   Expected keywords: {target_version_keywords}")
                    
            else:
                print(f"❌ API Error: {response.status_code}")
                
        except requests.exceptions.RequestException as e:
            print(f"❌ Connection Error: {e}")
        except Exception as e:
            print(f"❌ Unexpected Error: {e}")
        
        # Wait before next check
        elapsed = int(time.time() - start_time)
        remaining = int(max_wait_time - elapsed)
        
        if remaining > 0:
            print(f"\n⏰ Waiting {check_interval}s... ({remaining}s remaining)")
            time.sleep(check_interval)
        else:
            break
    
    print(f"\n⏰ Monitoring timeout after {max_wait_time}s")
    print("💡 Deployment might take longer. Try testing manually in Flutter app.")
    return False

if __name__ == "__main__":
    monitor_turkish_deployment()
