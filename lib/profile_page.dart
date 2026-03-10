import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sejjjjj/Screens/login.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  TextEditingController nameController = TextEditingController();

  Stream<DocumentSnapshot>? _getUserStream() {
    if (user == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _uploadImage(imageFile);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child("profile_images").child("${user!.uid}.jpg");
      await ref.putFile(imageFile);
      String downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'profileImage': downloadUrl,
      }, SetOptions(merge: true));

      await user!.reload();
      setState(() {});
    } catch (e) {
      print("❌ Image Upload Failed: $e");
    }
  }

  String getProfileImage(Map<String, dynamic> userData) {
    if (userData.containsKey('profileImage') && userData['profileImage'].isNotEmpty) {
      return userData['profileImage'];
    } else if (FirebaseAuth.instance.currentUser?.photoURL != null) {
      return FirebaseAuth.instance.currentUser!.photoURL!;
    } else {
      return "assets/images/profile.jpg";
    }
  }

  void _editProfile(String currentName) {
    nameController.text = currentName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Enter New Name"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Change Profile Image"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
                    'name': newName,
                  }, SetOptions(merge: true));

                  setState(() {});
                }
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout Confirmation"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Get.offAll(() => const Login());
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("User Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text("No user logged in"))
          : StreamBuilder<DocumentSnapshot>(
        stream: _getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found!"));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String userName = userData['name'] ?? "User Name";
          String profileImage = getProfileImage(userData);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profileImage.startsWith("http")
                            ? NetworkImage(profileImage)
                            : AssetImage(profileImage) as ImageProvider,
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.green,
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(user?.email ?? "user@example.com", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _editProfile(userName),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Logout", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
