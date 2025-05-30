import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

import 'package:percent_indicator/circular_percent_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      home: const SensorDataScreen(),
    );
  }
}
/*
class SensorDataScreen extends StatelessWidget {
  const SensorDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference healthDataRef =
        FirebaseDatabase.instance.ref('Health');

    return Scaffold(
      appBar: AppBar(title: const Text('Live Sensor Data')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade200, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<DatabaseEvent>(
          stream: healthDataRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching data ❌'));
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(child: Text('No data available 😢'));
            }

            var data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            var healthData = data.map((key, value) => MapEntry(key, double.tryParse(value.toString())?.round() ?? value));

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    '👋 Hello! Here\'s your current health status:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildVitalCard("❤️ Heart Rate", "${healthData['HR'].toStringAsFixed(0)} bpm", Icons.favorite, Colors.red),
                        _buildVitalCard("🫁 Respiratory Rate", "${healthData['RR'].toStringAsFixed(0)} breaths/min", Icons.air, Colors.blueAccent),
                        _buildVitalCard("🧠 Oxygen Level", "${healthData['SpO2'].toStringAsFixed(0)}%", Icons.bubble_chart, const Color.fromARGB(255, 95, 244, 100)),
                        _buildVitalCard("🌡️ Body Temperature", "${healthData['BT'].toStringAsFixed(0)} °C", Icons.thermostat, const Color.fromARGB(222, 225, 248, 51)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PredictionScreen(healthData: healthData),
                        ),
                      );
                    },
                    icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                    label: const Text("Predict Health Risk", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVitalCard(String title, String value, IconData icon, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.3),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color)),
        subtitle: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
} */







class SensorDataScreen extends StatelessWidget {
  const SensorDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference healthDataRef = FirebaseDatabase.instance.ref('Health');

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isLandscape ? 32 : 48, // Smaller AppBar in landscape
        title: const Text('Live Sensor Data', style: TextStyle(fontSize: 16)), // Adjusted font size
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: healthDataRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data ❌'));
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('No data available 😢'));
          }

          var rawData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          // Safe double conversion
          Map<String, double> healthData = rawData.map((key, value) {
            double val = 0;
            if (value is int) {
              val = value.toDouble();
            } else if (value is double) {
              val = value;
            } else {
              val = double.tryParse(value.toString()) ?? 0;
            }
            return MapEntry(key.toString(), val);
          });

          return Padding(
            padding: const EdgeInsets.all(8.0), // Reduced padding
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  '👋 Hello! Here\'s your current health status:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // Adjusted font size
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = isLandscape ? 4 : 2; // More rings in landscape
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16, // Reduced spacing between rings
                        mainAxisSpacing: 16,
                        children: [
                          _buildFancyRing(
                            title: 'Heart Rate',
                            value: healthData['HR'] ?? 0,
                            max: 200,
                            unit: 'bpm',
                            gradientColors: [Colors.red, Colors.pinkAccent],
                          ),
                          _buildFancyRing(
                            title: 'Respiratory Rate',
                            value: healthData['RR'] ?? 0,
                            max: 40,
                            unit: 'breaths/m',
                            gradientColors: [Colors.green, Colors.lightGreenAccent],
                          ),
                          _buildFancyRing(
                            title: 'Oxygen Level',
                            value: healthData['SpO2'] ?? 0,
                            max: 100,
                            unit: '%',
                            gradientColors: [Colors.blue, Colors.cyanAccent],
                          ),
                          _buildFancyRing(
                            title: 'Body Temp',
                            value: healthData['BT'] ?? 0,
                            max: 45,
                            unit: '°C',
                            gradientColors: [Colors.orange, Colors.yellow],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10), // Reduced space below rings
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue, width: 2),
                    backgroundColor: Colors.blue,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Reduced padding
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PredictionScreen(healthData: healthData),
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                  label: const Text(
                    "Predict Health Risk",
                    style: TextStyle(fontSize: 14, color: Colors.white), // Reduced font size
                  ),
                ),
                const SizedBox(height: 12), // Reduced space below button
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFancyRing({
    required String title,
    required double value,
    required double max,
    required String unit,
    required List<Color> gradientColors,
  }) {
    double percent = (value / max).clamp(0.0, 1.0);
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 1.0, end: 1.05),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: math.sin(DateTime.now().millisecondsSinceEpoch * 0.002) * 0.02 + 1,
          child: CircularPercentIndicator(
            radius: 70.0,
            lineWidth: 12.0,
            animation: true,
            animateFromLastPercent: true,
            percent: percent,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${value.toStringAsFixed(1)} $unit',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // Reduced font size
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 10), // Reduced font size
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            linearGradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            backgroundColor: Colors.grey.shade300,
          ),
        );
      },
    );
  }
}



class PredictionScreen extends StatefulWidget {
  final Map<dynamic, dynamic> healthData;
  const PredictionScreen({super.key, required this.healthData});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  String gender = 'Male';
  String prediction = '';
  String conditionBasedPrediction = '';

  Future<void> getPrediction() async {
    final url = Uri.parse(
      'https://health-monitoring-flask-app.onrender.com/predict',
    );

    Map<String, dynamic> requestData = {
      "Heart Rate": widget.healthData['HR'],
      "Respiratory Rate": widget.healthData['RR'],
      "Body Temperature": widget.healthData['BT'],
      "Oxygen Saturation": widget.healthData['SpO2'],
      "Age": int.tryParse(ageController.text) ?? 0,
      "Gender": gender == 'Male' ? 0 : 1,
      "Weight (kg)": double.tryParse(weightController.text) ?? 0.0,
      "Height (m)": double.tryParse(heightController.text) ?? 0.0,
    };

    double bmi =
        requestData["Weight (kg)"] /
        (requestData["Height (m)"] * requestData["Height (m)"]);
    List<String> conditions = [];

    if (requestData["Heart Rate"] < 55) conditions.add("Bradycardia");
    if (requestData["Heart Rate"] > 105) conditions.add("Tachycardia");
    if (requestData["Respiratory Rate"] < 9)
      conditions.add("Respiratory Depression");
    if (requestData["Respiratory Rate"] > 27)
      conditions.add("Respiratory Distress");
    if (requestData["Body Temperature"] > 38.5)
      conditions.add("Fever (Infection)");
    if (requestData["Body Temperature"] < 34.5) conditions.add("Hypothermia");
    if (requestData["Oxygen Saturation"] < 88) conditions.add("Severe Hypoxia");
    if (bmi < 18.5) conditions.add("Underweight");
    if (bmi > 30) conditions.add("Obesity");

    setState(() {
      conditionBasedPrediction =
          conditions.isNotEmpty
              ? conditions.join(", ")
              : "Normal Health Status";
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        var apiRisk = responseBody['Risk Category'] ?? 'Unknown Risk Level';

        if (conditionBasedPrediction != "Normal Health Status" &&
            apiRisk == "Low Risk") {
          apiRisk = "Moderate Risk";
        } else if (conditionBasedPrediction == "Normal Health Status" &&
            apiRisk == "High Risk") {
          apiRisk = "Moderate Risk";
        }

        setState(() {
          prediction = apiRisk;
        });
      } else {
        setState(() {
          prediction = 'API Error: \${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        prediction = 'API failed: \$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Predict Health Risk')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade200, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Please enter your age' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: gender,
                      items:
                          ['Male', 'Female'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          gender = newValue!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Please enter your weight'
                                  : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (m)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.height),
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Please enter your height'
                                  : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          getPrediction();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.analytics_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Predict Risk using ML',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (prediction.isNotEmpty)
                      Text(
                        "AI Prediction: $prediction",
                        style: const TextStyle(fontSize: 18),
                      ),
                    const SizedBox(height: 10),
                    if (conditionBasedPrediction.isNotEmpty)
                      Text(
                        "Conditions: $conditionBasedPrediction",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
