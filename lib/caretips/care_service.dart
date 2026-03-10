import 'dart:convert';
import 'package:flutter/services.dart';

class CareService {
  static Map<String, dynamic> _careData = {};

  static Future<void> initialize() async {
    await _loadCareData();
  }

  static Future<void> _loadCareData() async {
    try {
      String jsonData = await rootBundle.loadString('assets/model/care_data.json');
      Map<String, dynamic> originalData = json.decode(jsonData);

      // ✅ Convert keys to lowercase for case-insensitive search
      _careData = {
        for (var key in originalData.keys) key.toLowerCase(): originalData[key]
      };

      print("✅ Care Data Loaded Successfully!");
    } catch (e) {
      print("❌ Error Loading Care Data: $e");
    }
  }

  static Map<String, dynamic> getCareTips(String plantName) {
    String key = plantName.toLowerCase();  // Convert input to lowercase
    return _careData.containsKey(key)
        ? _careData[key]
        : {
      "scientific_name": "N/A",
      "common_name": "Unknown",
      "description": "No specific details available.",
    };
  }
}
