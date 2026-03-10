import 'package:cloud_firestore/cloud_firestore.dart';

void fetchPlantData(String docId) async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('plants') // <-- apne collection ka naam yahan likho
        .doc(docId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      // Check if the field exists
      if (data.containsKey('scientific_name')) {
        String scientificName = data['scientific_name'];
        print('Scientific Name: $scientificName');
      } else {
        print('Field "scientific_name" not found.');
      }
    } else {
      print('Document does not exist.');
    }
  } catch (e) {
    print('Error: $e');
  }
}
