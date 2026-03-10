import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sejjjjj/Screens/forgot.dart';
import 'package:sejjjjj/Screens/signup.dart';
import 'package:sejjjjj/dashboard.dart';
import 'package:sejjjjj/on_boarding_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isLoading = false;

  Future<void> signIn() async {
    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      // Fetch user details from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        Get.offAll(const OnboardingScreen()); // User found, move to Dashboard
      } else {
        Get.snackbar("Error", "User data not found!", snackPosition: SnackPosition.BOTTOM);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again.";
      switch (e.code) {
        case "invalid-email":
          errorMessage = "Invalid email format.";
          break;
        case "user-not-found":
          errorMessage = "No account found. Sign up first!";
          break;
        case "wrong-password":
          errorMessage = "Incorrect password!";
          break;
        case "too-many-requests":
          errorMessage = "Too many attempts. Try later.";
          break;
      }
      Get.snackbar("Login Failed", errorMessage, snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Store user in Firestore
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "name": user.displayName ?? "No Name",
          "email": user.email,
          "profilePic": user.photoURL ?? "",
          "createdAt": DateTime.now(),
        }, SetOptions(merge: true));

        Get.offAll(DashboardPage());
      }
    } catch (e) {
      Get.snackbar("Google Sign-In Failed", "Try again: $e", snackPosition: SnackPosition.BOTTOM);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(" Login", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 40),
              TextField(
                controller: email,
                style: const TextStyle(color: Colors.black), // ✅ Text inside input is now black
                decoration: inputDecoration("Enter Email"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: password,
                obscureText: true,
                style: const TextStyle(color: Colors.black), // ✅ Text inside input is now black
                decoration: inputDecoration("Enter Password"),
              ),
              const SizedBox(height: 20),
              isLoading ? const CircularProgressIndicator() : loginButton(),
              const SizedBox(height: 10),
              googleButton(),
              const SizedBox(height: 20),
              footerLinks()
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black), // ✅ Hint text is now black
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget loginButton() {
    return ElevatedButton(
      onPressed: signIn,
      style: buttonStyle(),
      child: const Text("Login", style: TextStyle(fontSize: 18, color: Colors.black)), // ✅ Button text changed to black
    );
  }

  Widget googleButton() {
    return ElevatedButton(
      onPressed: signInWithGoogle,
      style: buttonStyle(backgroundColor: Colors.white, textColor: Colors.black, border: const BorderSide(color: Colors.grey)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/google_logo.jpg", height: 24),
          const SizedBox(width: 10),
          const Text("Sign in with Google", style: TextStyle(color: Colors.black)), // ✅ Text changed to black
        ],
      ),
    );
  }

  Widget footerLinks() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account? ", style: TextStyle(color: Colors.black)), // ✅ Changed to black
            TextButton(onPressed: () => Get.to(const Signup()), child: const Text("Sign Up", style: TextStyle(color: Colors.black))), // ✅ Changed to black
          ],
        ),
        TextButton(
          onPressed: () => Get.to(const Forgot()),
          child: const Text("Forgot Password?", style: TextStyle(fontSize: 16, color: Colors.black)), // ✅ Changed to black
        ),
      ],
    );
  }

  ButtonStyle buttonStyle({Color backgroundColor = Colors.blueAccent, Color textColor = Colors.black, BorderSide? border}) {
    return ElevatedButton.styleFrom(
      shape: const StadiumBorder(),
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      minimumSize: const Size(double.infinity, 50),
      side: border,
    );
  }
}
