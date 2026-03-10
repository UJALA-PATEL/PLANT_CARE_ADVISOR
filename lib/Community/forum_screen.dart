import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:sejjjjj/Community/Services/firebase_services.dart';
import 'package:sejjjjj/Community/widget/post_card.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  ForumScreenState createState() => ForumScreenState();
}

class ForumScreenState extends State<ForumScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _plantNameController = TextEditingController();
  File? _mediaFile;
  String? _mediaUrl;
  bool _isUploading = false;

  /// 📸 **Pick Image/Video**
  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    final picker = ImagePicker();
    final pickedFile = isVideo
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
      });
    }
  }

  /// 🔄 **Upload Media to Firebase Storage**
  Future<void> _uploadMedia() async {
    if (_mediaFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('posts/$fileName');
      final uploadTask = ref.putFile(_mediaFile!);
      final snapshot = await uploadTask.whenComplete(() => {});
      final url = await snapshot.ref.getDownloadURL();

      setState(() {
        _mediaUrl = url;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      print("Media upload failed: $e");
    }
  }

  /// 📝 **Add Post to Firestore**
  Future<void> _addPost() async {
    if (_postController.text.isNotEmpty && _plantNameController.text.isNotEmpty) {
      String? userId = FirebaseService.getCurrentUserId();

      // If media exists, upload it first
      if (_mediaFile != null) {
        await _uploadMedia();
      }

      await FirebaseService.addPost(
        userId: userId,
        plantName: _plantNameController.text,
        text: _postController.text,
        mediaUrl: _mediaUrl,
      );

      _postController.clear();
      _plantNameController.clear();
      setState(() {
        _mediaFile = null;
        _mediaUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseService.getCurrentUserId();

    return Scaffold(
      appBar: AppBar(title: const Text('Community Forum')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _plantNameController,
                  decoration: const InputDecoration(labelText: 'Plant Name'),
                ),
                TextField(
                  controller: _postController,
                  decoration: const InputDecoration(labelText: 'Share your thoughts...'),
                ),
                const SizedBox(height: 10),

                // 📸 Media Picker Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.image, color: Colors.green),
                      onPressed: () => _pickMedia(ImageSource.gallery),
                    ),
                    IconButton(
                      icon: Icon(Icons.video_camera_back, color: Colors.red),
                      onPressed: () => _pickMedia(ImageSource.gallery, isVideo: true),
                    ),
                  ],
                ),

                // 🎥 Show Selected Media
                if (_mediaFile != null)
                  Container(
                    height: 150,
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _mediaFile!.path.endsWith('.mp4')
                        ? Center(child: Text("Video selected"))
                        : Image.file(_mediaFile!, fit: BoxFit.cover),
                  ),

                ElevatedButton(
                  onPressed: _isUploading ? null : _addPost,
                  child: _isUploading ? CircularProgressIndicator() : const Text('Post'),
                ),
              ],
            ),
          ),

          // ✅ Show only logged-in user's posts
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('userId', isEqualTo: userId)  // ✅ Filter user's posts
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView(
                  children: snapshot.data!.docs.map((doc) => PostCard(doc)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
