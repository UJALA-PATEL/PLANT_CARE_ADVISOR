import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // ✅ For debugPrint()

Future<void> placeOrder(Map<String, dynamic> product) async {
  final user = FirebaseAuth.instance.currentUser;

  // ✅ Debugging print only runs in debug mode
  if (kDebugMode) debugPrint("⚡ Checking User Login...");

  if (user == null) {
    if (kDebugMode) debugPrint("❌ Error: User not logged in!");
    return;
  }

  String userId = user.uid;
  if (kDebugMode) debugPrint("✅ User Logged In: $userId");

  try {
    await FirebaseFirestore.instance.collection('orders').add({
      'userId': userId,
      'productId': product['productId'],
      'name': product['name'],
      'price': product['price'],
      'quantity': product['quantity'],
      'status': 'Pending',
      'orderDate': FieldValue.serverTimestamp(),
    });

    if (kDebugMode) debugPrint("✅ Order placed successfully for User ID: $userId");
  } catch (e) {
    if (kDebugMode) debugPrint("❌ Error placing order: $e");
  }
}
