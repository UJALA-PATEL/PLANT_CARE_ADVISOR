
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class PlantDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot plant;

  PlantDetailScreen({required this.plant});

  @override
  Widget build(BuildContext context) {
    String imagePath = plant["image"]; // Could be a local file path, asset path, or URL

    Widget buildImage(String path) {
      if (path.startsWith('http')) {
        return Image.network(
          path,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else if (path.startsWith('assets/')) {
        return Image.asset(
          path,
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else {
        return Image.file(
          File(path),
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plant["name"]),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: buildImage(imagePath),
              ),
            ),
            SizedBox(height: 10),
            Text("Scientific Name: ${plant["scientific_name"]}", style: TextStyle(fontSize: 18)),
            Text("Family: ${plant["family"]}", style: TextStyle(fontSize: 16)),
            Text("Uses: ${plant["uses"]}", style: TextStyle(fontSize: 16)),
            Text("Habitat: ${plant["habitat"]}", style: TextStyle(fontSize: 16)),
            Text("Growth Conditions: ${plant["growth_conditions"]}", style: TextStyle(fontSize: 16)),
            Text("Watering: ${plant["watering"]}", style: TextStyle(fontSize: 16)),
            Text("Sunlight: ${plant["sunlight"]}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Description:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(plant["description"], style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
