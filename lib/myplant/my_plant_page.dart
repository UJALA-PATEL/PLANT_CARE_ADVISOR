import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sejjjjj/myplant/add_new%20_plant.dart';
import 'package:sejjjjj/myplant/plantdetailscreen.dart';

class MyPlantsScreen extends StatefulWidget {
  @override
  _MyPlantsScreenState createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  void _addNewPlant() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPlantScreen()),
    );
  }

  void _deletePlant(String docId) async {
    await FirebaseFirestore.instance.collection('plants').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Plants'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('plants')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final plantDocs = snapshot.data!.docs;

          if (plantDocs.isEmpty) {
            return Center(child: Text('No plants added yet!'));
          }

          return ListView.builder(
            itemCount: plantDocs.length,
            itemBuilder: (context, index) {
              final plant = plantDocs[index];
              final plantData = plant.data() as Map<String, dynamic>;

              return ListTile(
                contentPadding: EdgeInsets.all(10),
                leading: plantData['image'] != null && plantData['image'].toString().isNotEmpty
                    ? Image.network(plantData['image'], width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.local_florist, size: 50),
                title: Text(plantData['name'] ?? 'Unnamed Plant'),
                subtitle: Text("Reminder: ${plantData['reminder'] ?? 'N/A'}"),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deletePlant(plant.id),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlantDetailScreen(plantData: plantData),
                    ),
                  );
                },

              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPlant,
        child: Icon(Icons.add),
        tooltip: 'Add New Plant',
      ),
    );
  }
}
