import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  static Future<void> sendMessage({
    required String userId,
    required String userName, // This should accept the userName parameter
    required String message,
  }) async {
    await FirebaseFirestore.instance.collection('live_chats').add({
      'userId': userId,   // Store userId
      'name': userName,   // Store the userName (from Firestore)
      'message': message, // Store the message
      'timestamp': FieldValue.serverTimestamp(), // Store the timestamp
    });
  }

  static Stream<QuerySnapshot> getMessages() {
    return FirebaseFirestore.instance
        .collection('live_chats')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
