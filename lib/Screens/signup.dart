import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sejjjjj/Screens/login.dart';
import 'package:sejjjjj/Screens/verifyemail.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isLoading = false;

  Future<void> saveUserData(User user) async {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "name": user.displayName ?? "No Name",
      "email": user.email,
      "profilePic": user.photoURL ?? "",
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> signup() async {
    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email.text.trim(), password: password.text);

      User? user = userCredential.user;
      if (user != null) {
        await saveUserData(user);
        Get.offAll(const Verify());
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Signup failed. Please try again.";
      switch (e.code) {
        case "email-already-in-use":
          errorMessage = "This email is already in use. Try logging in.";
          break;
        case "invalid-email":
          errorMessage = "Invalid email format.";
          break;
        case "weak-password":
          errorMessage = "Password is too weak.";
          break;
      }
      Get.snackbar("Error", errorMessage, snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Sign Up",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: email,
                style: const TextStyle(color: Colors.black), // ✅ Text inside input is now black
                decoration: InputDecoration(
                  hintText: 'Enter Email',
                  hintStyle: const TextStyle(color: Colors.black), // ✅ Hint text is now black
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: password,
                obscureText: true,
                style: const TextStyle(color: Colors.black), // ✅ Text inside input is now black
                decoration: InputDecoration(
                  hintText: 'Enter Password',
                  hintStyle: const TextStyle(color: Colors.black), // ✅ Hint text is now black
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: signup,
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.black, // ✅ Button text is now black
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Continue", style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ", style: TextStyle(color: Colors.black)),
                  TextButton(
                    onPressed: () => Get.to(const Login()),
                    child: const Text("Login", style: TextStyle(color: Colors.black)), // ✅ Changed to black
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
