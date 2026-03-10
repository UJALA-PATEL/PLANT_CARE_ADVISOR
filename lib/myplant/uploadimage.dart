import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadImageToFirebase(File image) async {
  final fileName = DateTime.now().millisecondsSinceEpoch.toString();
  final ref = FirebaseStorage.instance.ref().child('plant_images/$fileName.jpg');

  final uploadTask = await ref.putFile(image);
  final downloadUrl = await ref.getDownloadURL(); // 🔥 This throws if file not uploaded

  return downloadUrl;
}
