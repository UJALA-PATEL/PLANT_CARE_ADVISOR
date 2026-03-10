import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sejjjjj/search/plant_Detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = "";
  final TextEditingController _controller = TextEditingController();

  void _searchAndNavigate() {
    setState(() {
      searchQuery = _controller.text.trim();
      print("🔍 Search Query: $searchQuery");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Plants"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Search by plant name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.green),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Colors.red),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      searchQuery = "";
                    });
                  },
                ),
              ),
              onSubmitted: (value) => _searchAndNavigate(),
            ),
            SizedBox(height: 12),
            Expanded(
              child: StreamBuilder(
                stream: searchQuery.isEmpty
                    ? null
                    : FirebaseFirestore.instance
                    .collection("plants")
                    .where("name_lowercase", isGreaterThanOrEqualTo: searchQuery.toLowerCase())
                    .where("name_lowercase", isLessThanOrEqualTo: searchQuery.toLowerCase() + '\uf8ff')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (searchQuery.isEmpty) {
                    return Center(
                      child: Text(
                        "Search for a plant by name.",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No matching plants found!",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  var plants = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      var plant = plants[index];
                      var data = plant.data() as Map<String, dynamic>;

                      String plantName = data["name"] ?? "Unknown";
                      String scientificName = data.containsKey("scientific_name") ? data["scientific_name"] : "N/A";
                      String imageUrl = data["image"] ?? "https://via.placeholder.com/150";

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(imageUrl),
                            radius: 30,
                          ),
                          title: Text(plantName, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(scientificName),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlantDetailScreen(plant: plant),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
