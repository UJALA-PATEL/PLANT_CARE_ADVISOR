import 'package:flutter/material.dart';
import '../services/model_service.dart';

class CareTipsScreen extends StatelessWidget {
  final String disease;

  const CareTipsScreen({Key? key, required this.disease}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> diseaseData = ModelService.getCareTips(disease);

    return Scaffold(
      appBar: AppBar(
        title: Text("Care Tips for ${diseaseData['common_name']}"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText("🌿 Scientific Name", diseaseData['scientific_name']),
            _buildText("📖 Description", diseaseData['description']),
            _buildList("🩺 Symptoms", diseaseData['symptoms']),
            _buildList("⚠️ Causes", diseaseData['causes']),
            _buildList("🔴 Risk Factors", diseaseData['risk_factor']),
            _buildList("🛡 Prevention", diseaseData['prevention']),
            _buildList("✅ Best Practices", diseaseData['best_practices']),
            _buildClimateSoilSection(diseaseData['climate_soil']),
            _buildList("🌱 Resistant Varieties", diseaseData['resistant_varieties']),
            _buildTreatmentSection(diseaseData['treatments']),
            _buildRecoverySection(diseaseData['recovery']),
            _buildExpertAdviceSection(diseaseData['expert_advice']),
            _buildMarketSection(diseaseData['market']),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String title, String? content) {
    if (content == null || content.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(content, style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildList(String title, List<dynamic>? items) {
    if (items == null || items.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...items.map((item) => Text("• $item", style: TextStyle(fontSize: 16))),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildClimateSoilSection(Map<String, dynamic>? climateSoil) {
    if (climateSoil == null) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🌎 Climate & Soil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("🌦 Preferred Climate: ${climateSoil['preferred_climate']}", style: TextStyle(fontSize: 16)),
          Text("🪴 Soil Requirements: ${climateSoil['soil_requirements']}", style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildTreatmentSection(Map<String, dynamic>? treatments) {
    if (treatments == null) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildList("🩹 Chemical Treatments", treatments['chemical']),
        _buildList("🍃 Organic Treatments", treatments['organic']),
        _buildList("🦠 Biological Treatments", treatments['biological']),
        _buildList("🏡 DIY Treatments", treatments['diy']),
        _buildList("📌 Step-by-Step Treatment", treatments['step_by_step']),
      ],
    );
  }

  Widget _buildRecoverySection(Map<String, dynamic>? recovery) {
    if (recovery == null) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("🛠 Recovery", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        _buildText("👀 Monitoring", recovery['monitoring']),
        _buildText("🌱 Nutrient Boost", recovery['nutrient_boost']),
        _buildText("🌍 Soil Treatment", recovery['soil_treatment']),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildExpertAdviceSection(Map<String, dynamic>? expertAdvice) {
    if (expertAdvice == null) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildList("💡 Pro Tips", expertAdvice['pro_tips']),
        _buildList("⚠️ Common Mistakes", expertAdvice['mistakes']),
        _buildFAQSection(expertAdvice['faq']),
      ],
    );
  }

  Widget _buildFAQSection(Map<String, dynamic>? faq) {
    if (faq == null || faq.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("❓ Frequently Asked Questions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...faq.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Q: ${entry.key}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("A: ${entry.value}", style: TextStyle(fontSize: 16)),
              ],
            ),
          )),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMarketSection(Map<String, dynamic>? market) {
    if (market == null) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildList("🛒 Best Products", market['best_products']),
        _buildList("📍 Where to Buy", market['where_to_buy']),
      ],
    );
  }
}