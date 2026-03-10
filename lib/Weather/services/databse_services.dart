/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../services/weather_services.dart';
import 'location_service.dart';


class DatabaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> addPlant(String name, int wateringDays, File imageFile) async {
    try {
      // ✅ Get Actual Location
      Position? position = await LocationService.getCurrentLocation();
      if (position == null) {
        print("❌ Could not get location!");
        return;
      }

      double latitude = position.latitude;
      double longitude = position.longitude;
      print("📍 User Location: $latitude, $longitude");

      // ✅ Fetch Current Weather
      WeatherService weatherService = WeatherService();
      Map<String, dynamic>? weatherData = await weatherService.fetchCurrentWeather(latitude, longitude);
      String weather = weatherData?['weather'][0]['description'];

      // ✅ Upload Image & Store Data (Same as before)
      String imageUrl = await _uploadImage(imageFile, "plants");
      await firestore.collection("plants").add({
        "name": name,
        "wateringSchedule": wateringDays,
        "imageUrl": imageUrl,
        "weather": weather,
        "createdAt": FieldValue.serverTimestamp(),
      });

      print("✅ Plant added with real location weather!");

    } catch (e) {
      print("❌ Error adding plant: $e");
    }
  }


  /// ✅ Add Growth Image for a Plant
  Future<void> addGrowthImage(String plantId, File imageFile) async {
    try {
      String imageUrl = await _uploadImage(imageFile, "growth");

      await firestore.collection("plants").doc(plantId).update({
        "growthImages": FieldValue.arrayUnion([imageUrl])
      });

      print("📸 Growth image added successfully!");
    } catch (e) {
      print("❌ Error adding growth image: $e");
    }
  }

  /// ✅ Upload Image to Firebase Storage
  Future<String> _uploadImage(File imageFile, String folder) async {
    try {
      final ref = storage.ref().child("$folder/${DateTime.now().millisecondsSinceEpoch}.jpg");
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("❌ Image upload failed: $e");
      return "";
    }
  }
}
*/