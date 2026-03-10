import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _requestPermissions();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.high);
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  // Request permissions for camera and gallery
  Future<void> _requestPermissions() async {
    var cameraStatus = await Permission.camera.request();
    var galleryStatus = await Permission.photos.request();
    if (cameraStatus.isGranted && galleryStatus.isGranted) {
      print("Camera and Gallery permissions granted.");
    } else {
      print("Camera and/or Gallery permissions denied.");
    }
  }

  // Capture image from the camera
  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      XFile image = await _cameraController!.takePicture();
      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Dispose the camera controller
  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera and Gallery Image Picker"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isCameraInitialized)
            // Show Camera Preview
              SizedBox(
                width: double.infinity,
                height: 300,
                child: CameraPreview(_cameraController!),
              ),
            const SizedBox(height: 20),
            // If image is selected (either from gallery or camera), show it
            if (_selectedImage != null)
              Image.file(
                _selectedImage!,
                height: 250,
                width: 250,
              ),
            const SizedBox(height: 20),
            // Button to capture image from the camera
            ElevatedButton(
              onPressed: _captureImage,
              child: const Text("Capture Image from Camera"),
            ),
            // Button to pick image from the gallery
            ElevatedButton(
              onPressed: _pickImageFromGallery,
              child: const Text("Pick Image from Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}
