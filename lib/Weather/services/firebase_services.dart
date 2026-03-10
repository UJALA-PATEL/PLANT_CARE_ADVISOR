import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Function to Upload Image to Firebase Storage
  Future<String> uploadPlantImage(File imageFile) async {
    try {
      String fileName = "plant_${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = _storage.ref().child("plants/$fileName");
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }

  // Function to Add Plant to Firebase Firestore
  Future<void> addPlant({
    required String name,
    required File? imageFile,
    required String wateringSchedule,
    required String wateringTime,
    required String location,
    required String userID,
  }) async {
    try {
      String imageUrl = "";
      if (imageFile != null) {
        imageUrl = await uploadPlantImage(imageFile);
      }

      await _firestore.collection("plants").add({
        "name": name,
        "imageUrl": imageUrl,
        "wateringSchedule": wateringSchedule,
        "wateringTime": wateringTime,
        "location": location,
        "userID": userID,
        "createdAt": FieldValue.serverTimestamp(),
      });

      print("Plant added successfully!");
    } catch (e) {
      print("Error adding plant: $e");
    }
  }
}
