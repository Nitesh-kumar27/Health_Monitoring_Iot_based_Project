
# 💙 Health Mate - IoT & ML-Based Health Monitoring App

**Health Mate** is a Flutter-based mobile application that monitors real-time health vitals using IoT sensors and predicts health risks using machine learning. The system is integrated with Firebase Realtime Database for live updates and uses a Python-based Flask API for health risk prediction.

---

## 🚀 Features

- 🔴 Real-Time Health Monitoring (Heart Rate, SpO₂, Respiratory Rate, Body Temperature)  
- 🧠 Health Risk Prediction using Machine Learning  
- 🔥 Firebase Realtime Database Integration  
- 📊 Beautiful Animated Live Charts  
- 🌗 Dark Mode UI Support  
- 📱 Mobile-Friendly Flutter UI  

---

## 📸 Screenshots

### 1. Live Sensor Data Screen  
Real-time health vitals are displayed in colorful animated circular charts:

![Live Sensor Data](1.jpeg)

### 2. Predict Health Risk Form  
Enter personal details to get a machine learning-based risk prediction:

![Predict Health Risk](2.jpeg)

---

## 🧠 ML Risk Prediction

The ML model is hosted on a Flask API and predicts health risk based on:
- Age
- Gender
- Height
- Weight

**Model:** Logistic Regression / Random Forest (configurable)  
**Output:** Risk Level - *Low*, *Moderate*, or *High*

---

## 🛠 Tech Stack

| Component        | Technology             |
|------------------|-------------------------|
| App Framework    | Flutter 3.29.3          |
| Backend API      | Flask (Python)          |
| Database         | Firebase Realtime DB    |
| IoT Controller   | NodeMCU (ESP8266)       |
| Sensors Used     | MAX30102 (HR & SpO₂), DS18B20 (Temp) |
| Charts & UI      | Custom Animated Widgets |

---

## 🧪 Sensor Parameters

- **Heart Rate:** Beats per minute (bpm)  
- **SpO₂ (Oxygen Level):** Percentage (%)  
- **Respiratory Rate:** Breaths per minute  
- **Body Temperature:** Celsius (°C)  

---

## 🔗 Firebase Integration

The app uses Firebase to:
- Fetch live sensor data  
- Store user predictions  
- Trigger alerts for abnormal vitals  

---

## 🧬 ML Model Details

- **Training Dataset:** Synthesized from clinical open-source data  
- **Preprocessing:** Scikit-learn Pipelines  
- **Deployment:** Flask API running on localhost / Render  

---

## 📂 Folder Structure

```
/Health_Monitoring_Iot_based_project
│
├── /Flask_app             # Jupyter notebook + model generation code
|     ├── Flask_api
            ├── Project_render_repo  # main repo to published on github and shared to render to run
            |      ├── app.py #  flask api
            |      ├──  Procfile # used on render to set
            |      ├──  random_forest.pkl #  Random forest trained module
            |      ├──  requirement.txt  # to get requirement on render   
            ├──  generate_module.py  # is used to generate pkl file
            ├── curl.py  # used to check api working 
├── /Flutter_app            # Flutter source code
|     ├── /health_mate        # Flutter App
├── /NodeMCU               # ESP8266 firmware code (Arduino)         
```

---

## 📥 Installation & Setup

### Prerequisites

- Flutter SDK  
- Firebase Project Setup  
- Python 3 with Flask, scikit-learn, pandas  
- Arduino IDE (for ESP8266 firmware)

---

### 🔧 Project Setup Steps

This project involves **3 main phases**:  
**1. Building the Flutter App**  
**2. Creating and Deploying the ML Module**  
**3. Flashing and Connecting the IoT Device**

---

### 1️⃣ Build the Flutter App

1. Clone the repository:  
   ```bash
   git clone https://github.com/Nitesh-kumar27/Health_Monitoring_Iot_based_Project
   cd Health_Monitoring_Iot_based_Project/Flutter_app/health-mate
   ```

2. Install Flutter dependencies:  
   ```bash
   flutter pub get
   ```

3. Set up Firebase:  
   - Add your `google-services.json` to `android/app/`.

---

### 2️⃣ Build & Deploy ML Model with Flask API

#### a. Train ML Model via Jupyter Notebook  
- Navigate to:
  ```bash
  cd ../../human_vital
  ```
- Open `main.ipynb` and execute cells to train a model (e.g., Random Forest).
- This will generate a `model.pkl` file used for prediction.

#### b. Generate Pickle File (optional script)  
```bash
cd generate_module
python generate_pickle.py
```

#### c. Test API Locally (optional)  
```bash
cd ../app
python app.py
```
- Use `curl` or Postman to test API responses.

#### d. Deploy Flask API to Render  
- Use a **separate repository** that contains the final Flask API code and the `model.pkl` file.  
- Create a new web service on [Render](https://render.com), connect your repo, and deploy it.  
- Ensure your Flask `app.py` properly loads the `model.pkl` and exposes `/predict` endpoint.

---

### 3️⃣ Flash & Connect IoT Device (ESP8266)

1. Use the firmware code in `/iot_firmware/` directory.  
2. Open it in Arduino IDE.  
3. Update the following:
   - Wi-Fi SSID & Password  
   - Firebase Realtime Database URL & API Key  
4. Flash the code to the NodeMCU (ESP8266) board.  
5. Upon connection, the sensor data will automatically start uploading to Firebase.

---

## 📡 Overall System Architecture

```
[ Sensors (HR, Temp, SpO2) ]
           ↓
     [ ESP8266 NodeMCU ]
           ↓
 [ Firebase Realtime DB ]
           ↓
[ Flutter Mobile App ] <→ [ Flask ML API (Render) ]
```

---

## 📞 Contact

Made with 💖 by [Nitesh Kumar](https://linkedin.com/in/nitishsangwan/)  
🔗 [GitHub](https://github.com/Nitesh-Kumar27)

---

## 📄 License

This project is Open Source

