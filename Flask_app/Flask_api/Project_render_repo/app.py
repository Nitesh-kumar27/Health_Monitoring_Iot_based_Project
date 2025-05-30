from flask import Flask, request, jsonify
import pickle
import numpy as np

# Load the trained model, scaler, and label encoder
with open('random_forest.pkl', 'rb') as package_file:
    model_package = pickle.load(package_file)

model = model_package["model"]
scaler = model_package["scaler"]
label_encoder = model_package["label_encoder"]

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"message": "Health Monitoring!"})

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get JSON request
        data = request.get_json()
        
        # Extract features in the correct order
        features = [
            data['Heart Rate'],
            data['Respiratory Rate'], 
            data['Body Temperature'],  
            data['Oxygen Saturation'], 
            data['Age'],               
            data['Gender'],
            data['Weight (kg)'],       
            data['Height (m)']        
        ]
        
        # Convert to numpy array and reshape
        features_array = np.array(features).reshape(1, -1)
        
        # Standardize input features
        features_scaled = scaler.transform(features_array)
        
        # Make prediction
        prediction = model.predict(features_scaled)
        
        # Decode predicted label
        predicted_label = label_encoder.inverse_transform(prediction)[0]
        
        # Return response
        return jsonify({"Risk Category": predicted_label})
    
    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == '__main__':
    app.run(debug=True)
