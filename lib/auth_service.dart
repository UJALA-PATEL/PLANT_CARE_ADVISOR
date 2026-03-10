import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveUserData(User? user) async { // User? use kiya null check ke liye
  if (user == null) {
    print("User is null, skipping save.");
    return;
  }

  print("Saving user data: ${user.uid}");

  try {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "name": user.displayName ?? "No Name",
      "email": user.email ?? "No Email",
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print("User data saved successfully!");
  } catch (error) {
    print("Error saving user data: $error");
  }
}
