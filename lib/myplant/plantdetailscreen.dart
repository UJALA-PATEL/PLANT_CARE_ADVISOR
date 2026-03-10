import 'package:flutter/material.dart';

class PlantDetailScreen extends StatelessWidget {
  final Map<String, dynamic> plantData;

  PlantDetailScreen({required this.plantData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plantData['name'] ?? 'Plant Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            plantData['image'] != null && plantData['image'].toString().isNotEmpty
                ? Image.network(plantData['image'], width: 150, height: 150, fit: BoxFit.cover)
                : Icon(Icons.local_florist, size: 150),
            SizedBox(height: 16),
            Text('Plant Name: ${plantData['name']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Reminder: ${plantData['reminder'] ?? 'No Reminder'}', style: TextStyle(fontSize: 16)),
            // Add other plant details here
          ],
        ),
      ),
    );
  }
}
