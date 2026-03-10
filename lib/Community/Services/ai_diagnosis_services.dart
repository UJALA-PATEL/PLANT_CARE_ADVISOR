import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiDiagnosisService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📌 Save Diagnosis without Image
  static Future<void> saveDiagnosis(String diagnosis, String userComment) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("🔥 User not logged in");
      throw Exception("User not logged in");
    }

    try {
      await _firestore.collection('plant_diagnoses').add({
        'userId': userId,
        'diagnosis': diagnosis,
        'userComment': userComment,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("🔥 Error saving diagnosis: $e");
    }
  }

  // 📌 Retrieve all diagnoses for a specific user
  static Future<List<Map<String, dynamic>>> getUserDiagnoses() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("User not logged in");
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('plant_diagnoses')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("🔥 Error retrieving diagnoses: $e");
      return [];
    }
  }

  // 📌 Retrieve a specific diagnosis by its ID
  static Future<Map<String, dynamic>?> getDiagnosisById(String diagnosisId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('plant_diagnoses').doc(diagnosisId).get();
      return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("🔥 Error retrieving diagnosis: $e");
      return null;
    }
  }

  // 📌 Delete a diagnosis
  static Future<void> deleteDiagnosis(String diagnosisId) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("User not logged in");
    }

    try {
      DocumentSnapshot snapshot = await _firestore.collection('plant_diagnoses').doc(diagnosisId).get();
      if (snapshot.exists && snapshot['userId'] == userId) {
        await _firestore.collection('plant_diagnoses').doc(diagnosisId).delete();
        print("🔥 Diagnosis deleted successfully.");
      } else {
        throw Exception("You cannot delete someone else's diagnosis.");
      }
    } catch (e) {
      print("🔥 Error deleting diagnosis: $e");
    }
  }
}