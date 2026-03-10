
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sejjjjj/Tracking/plant_detsilscreen.dart';
import 'dart:io';

class GrowthHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Growth History")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('plants')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var plants = snapshot.data!.docs;

          if (plants.isEmpty) {
            return Center(child: Text("No plant data available"));
          }

          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              var plant = plants[index];
              Map<String, dynamic> data = plant.data() as Map<String, dynamic>;

              String name = data.containsKey('name') ? data['name'] : 'Unnamed Plant';
              double height = data.containsKey('height') ? data['height'].toDouble() : 0.0;
              String imagePath = data.containsKey('image') ? data['image'] : '';
              DateTime? date = data.containsKey('date') ? data['date'].toDate() : null;

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: _buildImageWidget(imagePath),
                  title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "Height: ${height.toStringAsFixed(1)} cm\n"
                        "Date: ${date != null ? date.toLocal().toString().split(' ')[0] : 'Unknown'}",
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlantDetailScreen(plantData: data),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildImageWidget(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
    } else if (imagePath.startsWith('http')) {
      return Image.network(imagePath, width: 50, height: 50, fit: BoxFit.cover);
    } else {
      File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        return Icon(Icons.broken_image, size: 50, color: Colors.red);
      }
      return Image.file(imageFile, width: 50, height: 50, fit: BoxFit.cover);
    }
  }
}
