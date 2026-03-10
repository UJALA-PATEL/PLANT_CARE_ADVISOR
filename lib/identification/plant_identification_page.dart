import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:sejjjjj/identification/model_service.dart';

class PlantIdentificationScreen extends StatefulWidget {
  const PlantIdentificationScreen({Key? key}) : super(key: key);

  @override
  State<PlantIdentificationScreen> createState() => _PlantIdentificationScreenState();
}

class _PlantIdentificationScreenState extends State<PlantIdentificationScreen> {
  File? _image;
  String? _label;
  final picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      final result = await ModelService.predictDisease(image);
      final label = result['label'];
      setState(() {
        _image = image;
        _label = label;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FFF6),
      appBar: AppBar(
        title: const Text("Plant Disease Identifier"),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_image != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.shade600, width: 3),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade100,
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Column(
                children: const [
                  Icon(Icons.image, size: 100, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No image selected",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 30),
            if (_label != null)
              Column(
                children: [
                  const Text(
                    "Detected Disease:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 25),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Text(
                      _label!,
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _getImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text("Select from Gallery"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
