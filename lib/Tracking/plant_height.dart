import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HeightEntryScreen extends StatefulWidget {
  final String imagePath;
  HeightEntryScreen({required this.imagePath});

  @override
  _HeightEntryScreenState createState() => _HeightEntryScreenState();
}

class _HeightEntryScreenState extends State<HeightEntryScreen> {
  final TextEditingController _heightController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void saveData() {
    double height = double.tryParse(_heightController.text) ?? 0.0;
    _firestore.collection('plants').add({
      'name': 'Unknown Plant',
      'height': height,
      'date': Timestamp.now(),
      'image': widget.imagePath
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Plant Height")),
      body: Column(
        children: [
          Image.file(File(widget.imagePath)),
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Enter Plant Height (cm)"),
          ),
          ElevatedButton(
            onPressed: saveData,
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}
