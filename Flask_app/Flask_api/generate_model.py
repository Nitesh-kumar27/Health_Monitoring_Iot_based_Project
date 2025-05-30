import pandas as pd
import numpy as np
import pickle
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import accuracy_score, classification_report

# Load dataset
df = pd.read_csv('human_vital_signs_dataset_2024.csv')

# Drop irrelevant columns
df = df.drop(columns=["Patient ID", "Timestamp", "Systolic Blood Pressure", "Diastolic Blood Pressure", 
                       "Derived_HRV", "Derived_Pulse_Pressure", "Derived_BMI", "Derived_MAP"])

# Convert 'Gender' to numerical format
df['Gender'] = df['Gender'].map({'Male': 0, 'Female': 1})

# Encode target variable 'Risk Category'
label_encoder = LabelEncoder()
df['Risk Category'] = label_encoder.fit_transform(df['Risk Category'])

# Define features and target
X = df.drop(columns=['Risk Category'])
y = df['Risk Category']

# Standardize features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Split dataset
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.3, random_state=42, stratify=y)

# Train Random Forest model
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Evaluate model
y_pred = model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)
print(f'Accuracy: {accuracy:.2%}')
print(classification_report(y_test, y_pred))

# Save model, scaler, and encoder
model_package = {
    "model": model,
    "scaler": scaler,
    "label_encoder": label_encoder
}

with open('random_forest.pkl', 'wb') as package_file:
    pickle.dump(model_package, package_file)

print("Model saved as 'random_forest.pkl' successfully!")


