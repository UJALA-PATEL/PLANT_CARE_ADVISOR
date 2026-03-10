import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:math';

class ModelService {
  static Interpreter? _interpreter;
  static List<String> _labels = [];
  static Map<String, dynamic> _diseaseInfo = {};

  static Future<void> initialize() async {
    await _loadModel();
    await _loadLabels();
    await _loadDiseaseInfo();
  }

  static Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset("assets/model/RightModel.tflite");
      print("✅ Model Loaded Successfully!");
    } catch (e) {
      print("❌ Error Loading Model: $e");
    }
  }

  static Future<void> _loadLabels() async {
    try {
      String labelsData = await rootBundle.loadString('assets/model/labels.txt');
      _labels = labelsData.split('\n').map((label) => label.trim()).toList();
      print("✅ Labels Loaded Successfully!");
    } catch (e) {
      print("❌ Error Loading Labels: $e");
    }
  }

  static Future<void> _loadDiseaseInfo() async {
    try {
      String jsonData = await rootBundle.loadString('assets/model/disease_info.json');
      _diseaseInfo = json.decode(jsonData);
      print("✅ Disease Info Loaded Successfully!");
    } catch (e) {
      print("❌ Error Loading Disease Info: $e");
    }
  }

  static Map<String, dynamic> getCareTips(String disease) {
    return _diseaseInfo[disease] ?? {
      "scientific_name": "N/A",
      "common_name": "Unknown",
      "description": "No specific details available.",
    };
  }

  // **✅ FIXED `predictDisease()`**
  static Future<Map<String, String>> predictDisease(File imageFile) async {
    if (_interpreter == null) await initialize();

    List<List<List<double>>> processedImage = await _processImage(imageFile);
    var input = [processedImage];

    List<List<double>> outputRaw = List.generate(1, (_) => List.filled(38, 0.0));
    _interpreter!.run(input, outputRaw);

    int index = outputRaw[0].indexOf(outputRaw[0].reduce(max));

    String predictedLabel = index != -1 && index < _labels.length ? _labels[index] : "Unknown Disease";
    String diseaseDescription = _diseaseInfo[predictedLabel]?["description"] ?? "No description available.";

    return {'label': predictedLabel, 'description': diseaseDescription};
  }

  // **✅ FIXED `_processImage()`**
  static Future<List<List<List<double>>>> _processImage(File imageFile) async {
    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception("❌ Image Decoding Failed!");
    }

    img.Image resizedImage = img.copyResize(image, width: 128, height: 128);

    return List.generate(
      128,
          (y) => List.generate(
        128,
            (x) => [
          resizedImage.getPixel(x, y).r.toDouble(),
          resizedImage.getPixel(x, y).g.toDouble(),
          resizedImage.getPixel(x, y).b.toDouble(),
        ],
      ),
    );
  }
}