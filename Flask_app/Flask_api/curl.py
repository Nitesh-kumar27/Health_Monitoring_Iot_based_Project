import requests

# Define the API URL
url = "https://health-monitoring-flask-app.onrender.com/predict"

# Sample data for prediction
data = {
    "Heart Rate": 110,
    "Respiratory Rate": 3,
    "Body Temperature": 34.88,
    "Oxygen Saturation": 20,
    "Age": 68,
    "Gender": 1,
    "Weight (kg)":90.3,
    "Height (m)": 1.77
}

# Send POST request
response = requests.post(url, json=data)

# Print response
print("Status Code:", response.status_code)
print("Response:", response.json())
