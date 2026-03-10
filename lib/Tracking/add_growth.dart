import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addGrowthData(double height) async {
  await FirebaseFirestore.instance.collection('plants').add({
    'height': height,
    'date': Timestamp.now(),  // current date and time
  });
}
