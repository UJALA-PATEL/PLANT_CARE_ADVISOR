import 'package:flutter/material.dart';

class PlantDetailScreen extends StatelessWidget {
  final dynamic plantData; // The data passed from GrowthHistory

  PlantDetailScreen({required this.plantData});

  @override
  Widget build(BuildContext context) {
    // Extract plant data
    String plantName = plantData['name'];
    double plantHeight = plantData['height'].toDouble();
    String plantImage = plantData['image'];
    DateTime plantDate = plantData['date'].toDate();

    return Scaffold(
      appBar: AppBar(
        title: Text("Plant Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display plant image
            Center(
              child: plantImage.isNotEmpty
                  ? Image.network(plantImage, width: 150, height: 150, fit: BoxFit.cover)
                  : Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
            ),
            SizedBox(height: 16.0),

            // Display plant name
            Text(
              "Plant Name: $plantName",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),

            // Display plant height
            Text(
              "Height: ${plantHeight.toStringAsFixed(2)} cm",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8.0),

            // Display plant date
            Text(
              "Date Recorded: ${plantDate.toLocal().toString().split(' ')[0]}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16.0),

            // Button to go back
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text("Back to History"),
            ),
          ],
        ),
      ),
    );
  }
}
