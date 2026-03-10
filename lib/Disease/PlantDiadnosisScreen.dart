import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sejjjjj/Disease/screens/care_tips.dart';
import 'package:sejjjjj/Disease/services/image_service.dart';
import 'package:sejjjjj/Disease/services/model_service.dart';

class PlantDiagnosisScreen extends StatefulWidget {
  const PlantDiagnosisScreen({super.key});

  @override
  _PlantDiagnosisScreenState createState() => _PlantDiagnosisScreenState();
}

class _PlantDiagnosisScreenState extends State<PlantDiagnosisScreen> {
  File? _image;
  String _predictedLabel = "";
  String _diseaseDescription = "";

  Future<void> _pickAndPredictImage() async {
    File? image = await ImageService.pickImage();
    if (image != null) {
      setState(() => _image = image);
      var result = await ModelService.predictDisease(image);
      setState(() {
        _predictedLabel = result['label'] ?? "Unknown Disease";
        _diseaseDescription = result['description'] ?? "No description available.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🌱 Plant Diagnosis"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _image != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(_image!, height: 200, fit: BoxFit.cover),
            )
                : Icon(Icons.image, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            _predictedLabel.isNotEmpty
                ? Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "✅ Prediction: $_predictedLabel",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "ℹ️ $_diseaseDescription",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CareTipsScreen(disease: _predictedLabel),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Get Care Tips", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
                : Text("🤖 No Prediction Yet", style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickAndPredictImage,
              icon: Icon(Icons.upload_file, color: Colors.white),
              label: Text("📂 Select Image", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}