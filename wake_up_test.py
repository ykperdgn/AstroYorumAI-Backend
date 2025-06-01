import requests
import time

print("Attempting to wake up Render service...")
print("This may take up to 60 seconds for a sleeping free-tier service...")

try:
    response = requests.get('https://astroyorumai-api.onrender.com/health', timeout=60)
    print(f'Status: {response.status_code}')
    print(f'Response: {response.text}')
    
    if response.status_code == 200:
        print("\n✅ API is working! Testing root endpoint...")
        root_response = requests.get('https://astroyorumai-api.onrender.com/', timeout=30)
        print(f'Root Status: {root_response.status_code}')
        print(f'Root Response: {root_response.text}')
    
except Exception as e:
    print(f'Error: {e}')
    print("\nIf you get a connection error, the service might not be deployed yet.")
    print("Please check the Render.com dashboard for deployment status.")
