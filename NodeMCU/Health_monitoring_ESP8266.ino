#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <Wire.h>
#include "MAX30105.h"
#include <OneWire.h>
#include <DallasTemperature.h>

// WiFi Credentials
#define WIFI_SSID "###"
#define WIFI_PASSWORD "1@2WiFi89101"

// Firebase Credentials
#define FIREBASE_HOST "health-monitering27-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH "dy--------------YE"

// Firebase objects
FirebaseData firebaseData;
FirebaseAuth auth;
FirebaseConfig config;

// MAX30102 Setup
MAX30105 particleSensor;
float beatAvg = 0, bpmSum = 0, SpO2Sum = 0;
int bpmCount = 0, SpO2Count = 0;
const int IR_THRESHOLD = 50000;
const unsigned long MONITOR_DURATION_MS = 60000;
const unsigned long PAUSE_AFTER_MONITOR = 10000;

unsigned long monitorStartTime = 0;
bool monitoring = false;
float lastBPM = 0, lastSpO2 = 0;

// DS18B20 Setup
#define ONE_WIRE_BUS D4
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);
float temperatureSum = 0;
int temperatureCount = 0;
float lastTemperature = 0;

// Respiratory Rate Buffer
const int BUFFER_SIZE = 100;
unsigned long rrTimestamps[BUFFER_SIZE];
int rrIndex = 0;

void setup() {
  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH); // Off initially

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi!");

  // Firebase Init
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  delay(1000);

  // I2C Init
  Wire.begin(D2, D1);

  // MAX30102 Init
  if (!particleSensor.begin(Wire, I2C_SPEED_STANDARD)) {
    Serial.println("❌ MAX30102 not found. Check wiring!");
    while (1);
  }

  particleSensor.setup(70, 4, 2, 411, 4096);
  sensors.begin();

  Serial.println("✅ All sensors initialized. Waiting for finger placement...");
}

void loop() {
  long irRaw = particleSensor.getIR();
  long redRaw = particleSensor.getRed();

  static float irAvg = 0, redAvg = 0;
  irAvg = (irAvg * 0.8) + (irRaw * 0.2);
  redAvg = (redAvg * 0.8) + (redRaw * 0.2);

  // Detecting finger removal
  if (monitoring && irAvg < IR_THRESHOLD) {
    Serial.println("❌ Finger removed. Restarting monitoring...");
    monitoring = false;  // Stop monitoring if finger is removed
    digitalWrite(LED_BUILTIN, HIGH);  // LED OFF
    delay(PAUSE_AFTER_MONITOR); // Wait before restarting
    Serial.println("Ready. Waiting for finger placement...");
  }

  // Start monitoring when the finger is detected
  if (!monitoring && irAvg > IR_THRESHOLD) {
    Serial.println("🟢 Finger detected. Starting 60s monitoring...");
    monitoring = true;
    monitorStartTime = millis();
    resetAverages();
    digitalWrite(LED_BUILTIN, LOW);  // LED ON
  }

  if (monitoring) {
    detectPulse(irAvg);

    // SpO2 Calculation
    if (redAvg > 5000 && irAvg > 5000) {
      float ratio = redAvg / irAvg;
      float SpO2 = constrain(110 - 25 * ratio, 70, 100);
      SpO2Sum += smooth(SpO2, lastSpO2);
      SpO2Count++;
    }

    // BPM Average
    if (beatAvg > 20 && beatAvg < 200) {
      bpmSum += smooth(beatAvg, lastBPM);
      bpmCount++;
    }

    // Temperature every 1s
    static unsigned long lastTempRead = 0;
    if (millis() - lastTempRead >= 1000) {
      sensors.requestTemperatures();
      float tempC = sensors.getTempCByIndex(0);
      if (tempC > 10 && tempC < 50) {
        temperatureSum += smooth(tempC, lastTemperature);
        temperatureCount++;
      }
      lastTempRead = millis();
    }

    // End of monitoring after 60s
    if (millis() - monitorStartTime >= MONITOR_DURATION_MS) {
      monitoring = false;
      digitalWrite(LED_BUILTIN, HIGH); // LED OFF
      Serial.println("✅ Monitoring complete! Uploading to Firebase...");
      uploadToFirebase();
      Serial.println("⏳ Waiting 10s before restarting...");
      delay(PAUSE_AFTER_MONITOR);
      Serial.println("Ready. Waiting for finger placement...");
    }
  }

  delay(10);
}

// ---------- Helper Functions ----------

void resetAverages() {
  bpmSum = SpO2Sum = temperatureSum = 0;
  bpmCount = SpO2Count = temperatureCount = 0;
  beatAvg = lastBPM = lastSpO2 = lastTemperature = 0;
  rrIndex = 0;
  for (int i = 0; i < BUFFER_SIZE; i++) rrTimestamps[i] = 0;
}

float smooth(float newVal, float &lastVal) {
  float smooth = (newVal + lastVal) / 2.0;
  lastVal = newVal;
  return smooth;
}

void detectPulse(long irValue) {
  static long lastIR = 0;
  static bool pulseUp = false;
  static long lastPeakTime = 0;

  if (irValue > lastIR && !pulseUp && irValue > IR_THRESHOLD) {
    pulseUp = true;
  } else if (irValue < lastIR && pulseUp) {
    pulseUp = false;
    long delta = millis() - lastPeakTime;
    lastPeakTime = millis();
    float bpm = 60.0 / (delta / 1000.0);
    if (bpm > 20 && bpm < 200) {
      beatAvg = (beatAvg * 0.9) + (bpm * 0.1);
      rrTimestamps[rrIndex++] = millis();
      if (rrIndex >= BUFFER_SIZE) rrIndex = 0;
    }
  }

  lastIR = irValue;
}

int estimateRespiratoryRate() {
  int count = 0;
  unsigned long now = millis();
  for (int i = 0; i < BUFFER_SIZE; i++) {
    if (rrTimestamps[i] != 0 && (now - rrTimestamps[i]) < MONITOR_DURATION_MS) {
      count++;
    }
  }
  float rr = (count / 30.0) / 5.0 * 60.0;
  return (int)rr;
}

void uploadToFirebase() {
  float finalHR = bpmCount > 0 ? bpmSum / bpmCount : 0;
  float finalSpO2 = SpO2Count > 0 ? SpO2Sum / SpO2Count : 0;
  float finalTemp = temperatureCount > 0 ? temperatureSum / temperatureCount : 0;
  int finalRR = estimateRespiratoryRate();

  Serial.printf("❤️ HR: %.1f BPM | 🩸 SpO2: %.1f%% | 🌡️ Temp: %.2f°C | 🫁 RR: %d BPM\n", finalHR, finalSpO2, finalTemp, finalRR);

  if (Firebase.ready()) {
    Firebase.setFloat(firebaseData, "/Health/HR", finalHR);
    Firebase.setFloat(firebaseData, "/Health/SpO2", finalSpO2);
    Firebase.setFloat(firebaseData, "/Health/BT", finalTemp);
    Firebase.setInt(firebaseData, "/Health/RR", finalRR);

    if (firebaseData.httpCode() == 200) {
      Serial.println("✅ Data uploaded successfully!");
    } else {
      Serial.println("❌ Failed to upload data: " + firebaseData.errorReason());
    }
  } else {
    Serial.println("❌ Firebase not ready!");
  }
}
