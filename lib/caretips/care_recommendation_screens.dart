import 'package:flutter/material.dart';
import 'package:sejjjjj/caretips/care_service.dart';

class CareRecommendationScreen extends StatefulWidget {
  const CareRecommendationScreen({super.key});

  @override
  _CareRecommendationScreenState createState() => _CareRecommendationScreenState();
}

class _CareRecommendationScreenState extends State<CareRecommendationScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _careData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    CareService.initialize();  // ✅ Initialize the Care Service
  }

  void _searchPlantCare() async {
    setState(() => _isLoading = true);

    String plantName = _searchController.text.trim();
    if (plantName.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    var careData = CareService.getCareTips(plantName);  // ✅ Use CareService instead of ModelService

    setState(() {
      _careData = careData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🌱 Care Recommendations')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Plant",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchPlantCare,
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : _careData != null
                ? Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildText("🌿 Scientific Name", _careData!['scientific_name']),
                    _buildText("📖 Description", _careData!['description']),
                    _buildList("🛡 Prevention", _careData!['prevention']),
                    _buildList("✅ Best Practices", _careData!['best_practices']),
                    _buildList("🌱 Resistant Varieties", _careData!['resistant_varieties']),
                  ],
                ),
              ),
            )
                : Text("🔍 Search for a plant to see care recommendations!"),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String title, String? content) {
    if (content == null || content.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(content, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildList(String title, List<dynamic>? items) {
    if (items == null || items.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...items.map((item) => Text("• $item", style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
