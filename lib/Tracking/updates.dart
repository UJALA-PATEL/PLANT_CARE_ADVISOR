import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addPlantUpdate(String plantId, double height, String imageUrl) async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Reference to the updates sub-collection
  DocumentReference updateRef = _firestore.collection('plants')
      .doc(plantId)
      .collection('updates')
      .doc(); // Auto-generate unique ID for update

  // 🔹 Save new height, image, and timestamp
  await updateRef.set({
    'height': height,
    'image': imageUrl,
    'date': Timestamp.now(),
  });

  print("✅ Plant update added successfully!");
}
