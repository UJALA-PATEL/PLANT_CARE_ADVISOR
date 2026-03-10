import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sejjjjj/Tracking/plant_detsilscreen.dart';
import 'dart:io';
import 'package:sejjjjj/camera_page.dart';
import 'package:sejjjjj/Tracking/growth_chart.dart';
import 'package:sejjjjj/Tracking/growth_history.dart';

class GrowthTracker extends StatefulWidget {
  @override
  _GrowthTrackerState createState() => _GrowthTrackerState();
}

class _GrowthTrackerState extends State<GrowthTracker> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final User? user = FirebaseAuth.instance.currentUser;
  String? _imagePath;
  bool _isUploading = false;
  final TextEditingController _plantNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  Future<void> _captureImage() async {
    final image = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPage()),
    );

    if (image != null) {
      setState(() {
        _imagePath = image;
      });
      await _uploadImageToFirebase(File(image));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      await _uploadImageToFirebase(File(image.path));
    }
  }

  Future<void> _uploadImageToFirebase(File imageFile) async {
    setState(() {
      _isUploading = true;
    });
    try {
      String fileName = 'plants/${user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      await ref.putFile(imageFile);
      String downloadURL = await ref.getDownloadURL();
      setState(() {
        _imagePath = downloadURL;
      });
    } catch (e) {
      print("Error uploading image: $e");
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _saveData() async {
    if (user == null) return;

    String plantName = _plantNameController.text.trim();
    double height = double.tryParse(_heightController.text) ?? 0.0;

    if (plantName.isEmpty || height <= 0 || _imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter valid details & select an image")),
      );
      return;
    }

    await _firestore.collection('plants').add({
      'userId': user!.uid,  // ✅ Save only logged-in user data
      'name': plantName,
      'image': _imagePath,
      'height': height,
      'date': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Plant Data Saved Successfully!")),
    );

    setState(() {
      _plantNameController.clear();
      _heightController.clear();
      _imagePath = null;
    });
  }

  Widget _buildImageWidget(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
    }
    if (imagePath.startsWith("http")) {
      return Image.network(imagePath, height: 100, width: 100, fit: BoxFit.cover);
    }
    File imageFile = File(imagePath);
    if (!imageFile.existsSync()) {
      return Icon(Icons.broken_image, size: 50, color: Colors.red);
    }
    return Image.file(imageFile, height: 100, width: 100, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plant Growth Tracker')),
      body: Column(
        children: [
          TextField(controller: _plantNameController, decoration: InputDecoration(labelText: "Enter Plant Name")),
          TextField(controller: _heightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Enter Plant Height (cm)")),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: Icon(Icons.camera_alt, size: 40, color: Colors.green), onPressed: _captureImage),
              IconButton(icon: Icon(Icons.photo, size: 40, color: Colors.blue), onPressed: _pickImageFromGallery),
            ],
          ),
          _imagePath != null ? Padding(padding: const EdgeInsets.all(10.0), child: _buildImageWidget(_imagePath)) : Container(),
          ElevatedButton(onPressed: _isUploading ? null : _saveData, child: _isUploading ? CircularProgressIndicator() : Text('Save Plant Data')),
          ElevatedButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => GrowthChart()));
          }, child: Text('View Growth Chart')),
          ElevatedButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => GrowthHistory()));
          }, child: Text('View Growth History')),
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('plants')
                  .where('userId', isEqualTo: user?.uid) // ✅ Filter user-specific data
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                var userPlants = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: userPlants.length,
                  itemBuilder: (context, index) {
                    var plant = userPlants[index];
                    return ListTile(
                      leading: _buildImageWidget(plant['image']),
                      title: Text(plant['name']),
                      subtitle: Text("Height: ${plant['height']} cm"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _firestore.collection('plants').doc(plant.id).delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("✅ Plant removed!")),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlantDetailScreen(plantData: plant),
                          ),
                        );
                      },

                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

