import requests
import json

# Test data
data = {
    "date": "1990-01-15",
    "time": "14:30",
    "latitude": 41.0082,
    "longitude": 28.9784
}

# Test health endpoint
print("Testing health endpoint...")
health_response = requests.get("http://localhost:5000/health")
print(f"Health status: {health_response.status_code}")
print(f"Health response: {health_response.json()}")

# Test natal chart endpoint
print("\nTesting natal chart endpoint...")
natal_response = requests.post(
    "http://localhost:5000/natal",
    headers={"Content-Type": "application/json"},
    json=data
)
print(f"Natal status: {natal_response.status_code}")
if natal_response.status_code == 200:
    print(f"Natal response: {natal_response.json()}")
else:
    print(f"Error: {natal_response.text}")
