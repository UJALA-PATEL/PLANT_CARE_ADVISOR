import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlantUploadScreen extends StatelessWidget {
  const PlantUploadScreen({super.key});

  Future<void> uploadData() async {
    try {
      CollectionReference plantsCollection =
      FirebaseFirestore.instance.collection("plants");

      Map<String, Map<String, dynamic>> plantsData = {
        "1": {
          "name": "Aloe Vera",
          "scientific_name": "Aloe barbadensis miller",
          "family": "Asphodelaceae",
          "uses": "Medicinal, skincare",
          "habitat": "Tropical, dry climates",
          "growth_conditions": "Well-drained soil, partial sunlight",
          "watering": "Once a week",
          "sunlight": "4-6 hours of indirect sunlight",
          "description":
          "A succulent plant known for its healing properties and skincare benefits.",
          "image": "assets/images/aloevera.jpg"
        },
        "2": {
          "name": "Basil",
          "scientific_name": "Ocimum basilicum",
          "family": "Lamiaceae",
          "uses": "Culinary, medicinal",
          "habitat": "Warm, temperate regions",
          "growth_conditions": "Full sunlight, moist soil",
          "watering": "Every 2 days",
          "sunlight": "6-8 hours of direct sunlight",
          "description": "A popular herb used in cooking and traditional medicine.",
          "image": "assets/images/basil.jpg"
        },
        "3": {
          "name": "Neem",
          "scientific_name": "Azadirachta indica",
          "family": "Meliaceae",
          "uses": "Medicinal, pesticide",
          "habitat": "Tropical, semi-tropical regions",
          "growth_conditions": "Well-drained soil, full sunlight",
          "watering": "Once a week",
          "sunlight": "6-8 hours of direct sunlight",
          "description": "A fast-growing tree known for its medicinal properties and pest control benefits.",
          "image": "assets/images/neem.jpg"
        },
        "4": {
          "name": "Tulsi",
          "scientific_name": "Ocimum tenuiflorum",
          "family": "Lamiaceae",
          "uses": "Medicinal, religious",
          "habitat": "Indian subcontinent",
          "growth_conditions": "Moist soil, full sunlight",
          "watering": "Every 2 days",
          "sunlight": "6-8 hours of direct sunlight",
          "description": "A sacred plant in Indian culture, known for its medicinal properties.",
          "image": "assets/images//tulsi.jpg"
        },
        "5": {
          "name": "Money Plant",
          "scientific_name": "Epipremnum aureum",
          "family": "Araceae",
          "uses": "Indoor decor, air purification",
          "habitat": "Tropical, indoor environments",
          "growth_conditions": "Indirect sunlight, moderate watering",
          "watering": "Once a week",
          "sunlight": "Indirect sunlight",
          "description": "A popular indoor plant known for its low maintenance and air-purifying qualities.",
          "image": "assets/images/moneyplant.jpg"
        },
        "6": {
          "name": "Mango",
          "scientific_name": "Mangifera indica",
          "family": "Anacardiaceae",
          "uses": "Fruit, shade",
          "habitat": "Tropical regions",
          "growth_conditions": "Full sunlight, deep soil",
          "watering": "Once a week",
          "sunlight": "Full sunlight",
          "description": "A tropical fruit tree producing the delicious mango fruit.",
          "image": "assets/images/mango.jpg"
        },
        "7": {
          "name": "Rose",
          "scientific_name": "Rosa",
          "family": "Rosaceae",
          "uses": "Ornamental, fragrance",
          "habitat": "Temperate regions",
          "growth_conditions": "Well-drained soil, full sunlight",
          "watering": "Every 2 days",
          "sunlight": "6-8 hours of direct sunlight",
          "description": "A beautiful flowering plant known for its fragrance and aesthetic appeal.",
          "image": "assets/images/rose.jpg"
        },
        "8": {
          "name": "Coconut",
          "scientific_name": "Cocos nucifera",
          "family": "Arecaceae",
          "uses": "Food, oil, fiber",
          "habitat": "Coastal regions",
          "growth_conditions": "Sandy soil, full sunlight",
          "watering": "Twice a week",
          "sunlight": "Full sunlight",
          "description": "A tropical tree known for its versatile fruit and oil production.",
          "image": "assets/images/coconut.jpg"
        },
        "9": {
          "name": "Peepal",
          "scientific_name": "Ficus religiosa",
          "family": "Moraceae",
          "uses": "Religious, medicinal",
          "habitat": "Indian subcontinent",
          "growth_conditions": "Full sunlight, deep soil",
          "watering": "Once a week",
          "sunlight": "Full sunlight",
          "description": "A sacred tree in Hindu culture known for its longevity and medicinal benefits.",
          "image": "assets/images/peepal.jpg"
        },
        "10": {
          "name": "Banana",
          "scientific_name": "Musa",
          "family": "Musaceae",
          "uses": "Fruit, fiber",
          "habitat": "Tropical regions",
          "growth_conditions": "Moist soil, warm climate",
          "watering": "Every 2-3 days",
          "sunlight": "Full sunlight",
          "description": "A fast-growing plant known for its nutritious fruit and fiber production.",
          "image": "assets/images/banana.jpg"
        },
        "11": {
          "name": "Lavender",
          "scientific_name": "Lavandula",
          "family": "Lamiaceae",
          "uses": "Fragrance, medicinal",
          "habitat": "Mediterranean regions",
          "growth_conditions": "Well-drained soil, full sunlight",
          "watering": "Once a week",
          "sunlight": "Full sunlight",
          "description": "A fragrant herb known for its calming properties and essential oils.",
          "image": "assets/images/lavendra.jpg"
        },
        "12": {
          "name": "Sunflower",
          "scientific_name": "Helianthus annuus",
          "family": "Asteraceae",
          "uses": "Oil, ornamental",
          "habitat": "Temperate regions",
          "growth_conditions": "Full sunlight, well-drained soil",
          "watering": "Every 3 days",
          "sunlight": "Full sunlight",
          "description": "A tall flowering plant known for its bright yellow flowers and seed oil production.",
          "image": "assets/images/sunflower.jpg"
        },
        "13": {
          "name": "Cactus",
          "scientific_name": "Cactaceae",
          "family": "Cactaceae",
          "uses": "Indoor decor, medicinal",
          "habitat": "Deserts, arid regions",
          "growth_conditions": "Minimal water, full sunlight",
          "watering": "Once every 2 weeks",
          "sunlight": "Full sunlight",
          "description": "A drought-resistant plant known for its ability to store water.",
          "image": "assets/images/cactus.jpg"
        },
        "14": {
          "name": "Pine",
          "scientific_name": "Pinus",
          "family": "Pinaceae",
          "uses": "Timber, resin",
          "habitat": "Mountainous regions",
          "growth_conditions": "Cold climate, deep soil",
          "watering": "Once a week",
          "sunlight": "Full sunlight",
          "description": "A coniferous tree known for its wood and resin production.",
          "image": "assets/images/pine.jpg"
        },
        "15": {
          "name": "Tulip",
          "scientific_name": "Tulipa",
          "family": "Liliaceae",
          "uses": "Ornamental",
          "habitat": "Temperate regions",
          "growth_conditions": "Well-drained soil, partial sunlight",
          "watering": "Every 3-4 days",
          "sunlight": "Partial sunlight",
          "description": "A popular bulbous flower known for its bright and colorful blooms.",
          "image": "assets/images/tulip.jpg"
        },

        "16": {
          "name": "Jasmine",
          "scientific_name": "Jasminum",
          "family": "Oleaceae",
          "uses": "Fragrance, ornamental, medicinal",
          "habitat": "Tropical and subtropical regions",
          "growth_conditions": "Well-drained soil, full sunlight",
          "watering": "Every 2 days",
          "sunlight": "6-8 hours of direct sunlight",
          "description": "A fragrant flowering plant widely used for perfumes and decorations.",
          "image": "assets/images/jasmine.jpg"
        },
        "17": {
          "name": "Guava",
          "scientific_name": "Psidium guajava",
          "family": "Myrtaceae",
          "uses": "Fruit, medicinal",
          "habitat": "Tropical and subtropical regions",
          "growth_conditions": "Well-drained soil, full sunlight",
          "watering": "Once a week",
          "sunlight": "6-8 hours of direct sunlight",
          "description": "A tropical fruit tree producing nutritious and vitamin-rich guavas.",
          "image": "assets/images/guava.jpg"
        },
        "18": {
          "name": "Strawberry",
          "scientific_name": "Fragaria × ananassa",
          "family": "Rosaceae",
          "uses": "Fruit, culinary, medicinal",
          "habitat": "Temperate regions",
          "growth_conditions": "Moist, well-drained soil, full sunlight",
          "watering": "Every 2 days",
          "sunlight": "6-8 hours of direct sunlight",
          "description": "A popular fruit plant producing sweet and juicy strawberries.",
          "image": "assets/images/strawberry.jpg"
        },
        "19": {
          "name": "Papaya",
          "scientific_name": "Carica papaya",
          "family": "Caricaceae",
          "uses": "Fruit, medicinal",
          "habitat": "Tropical regions",
          "growth_conditions": "Full sunlight, well-drained soil",
          "watering": "Twice a week",
          "sunlight": "6-8 hours of direct sunlight",
          "description": "A fast-growing tropical tree known for its sweet, orange-fleshed fruit.",
          "image": "assets/images/papaya.jpg"
        },
        "20": {
          "name": "Peppermint",
          "scientific_name": "Mentha × piperita",
          "family": "Lamiaceae",
          "uses": "Medicinal, culinary",
          "habitat": "Temperate regions",
          "growth_conditions": "Moist soil, partial sunlight",
          "watering": "Keep soil consistently moist",
          "sunlight": "4-6 hours of indirect sunlight",
          "description": "A fragrant herb used for tea, essential oils, and culinary purposes.",
          "image": "assets/images/peppermint.jpg"
        },
        "21": {
          "name": "Chili Pepper",
          "scientific_name": "Capsicum annuum",
          "family": "Solanaceae",
          "uses": "Culinary, medicinal",
          "habitat": "Warm regions",
          "growth_conditions": "Full sunlight, well-drained soil",
          "watering": "Every 2-3 days",
          "sunlight": "6-8 hours of direct sunlight",
          "description": "A spicy fruit used worldwide in various cuisines.",
          "image": "assets/images/chilipeper.jpg"
        },
        "22": {
          "name": "Lemon",
          "scientific_name": "Citrus limon",
          "family": "Rutaceae",
          "uses": "Culinary, medicinal",
          "habitat": "Subtropical regions",
          "growth_conditions": "Full sunlight, moist soil",
          "watering": "Once a week",
          "sunlight": "6-8 hours of direct sunlight",
          "description": "A citrus fruit known for its tangy taste and high vitamin C content.",
          "image": "assets/images/lemon.jpg"
        },
        "23": {
          "name": "Apple",
          "scientific_name": "Malus domestica",
          "family": "Rosaceae",
          "uses": "Fruit, culinary",
          "habitat": "Temperate regions",
          "growth_conditions": "Cold climate, deep soil",
          "watering": "Once a week",
          "sunlight": "6-8 hours of full sunlight",
          "description": "A nutritious fruit known for its crisp texture and variety of flavors.",
          "image": "assets/images/apple.jpg"
        },
        "24": {
          "name": "Ginger",
          "scientific_name": "Zingiber officinale",
          "family": "Zingiberaceae",
          "uses": "Medicinal, culinary",
          "habitat": "Tropical and subtropical regions",
          "growth_conditions": "Moist soil, partial sunlight",
          "watering": "Keep soil consistently moist",
          "sunlight": "4-6 hours of indirect sunlight",
          "description": "A root spice widely used in cooking and traditional medicine.",
          "image": "assets/images/ginger.jpg"
        },
        "25": {
          "name": "Garlic",
          "scientific_name": "Allium sativum",
          "family": "Amaryllidaceae",
          "uses": "Medicinal, culinary",
          "habitat": "Temperate regions",
          "growth_conditions": "Well-drained soil, full sunlight",
          "watering": "Once a week",
          "sunlight": "6 hours of direct sunlight",
          "description": "A pungent bulb used in various dishes and traditional medicine.",
          "image": "assets/images/garlic.jpg"
        },
        "26": {
          "name": "Carrot",
          "scientific_name": "Daucus carota",
          "family": "Apiaceae",
          "uses": "Vegetable, culinary",
          "habitat": "Temperate regions",
          "growth_conditions": "Loose soil, full sunlight",
          "watering": "Twice a week",
          "sunlight": "6-8 hours of sunlight",
          "description": "A root vegetable known for its vibrant orange color and health benefits.",
          "image": "assets/images/carrot.jpg"
        },
        "27": {
          "name": "Onion",
          "scientific_name": "Allium cepa",
          "family": "Amaryllidaceae",
          "uses": "Culinary, medicinal",
          "habitat": "Temperate regions",
          "growth_conditions": "Well-drained soil, partial sunlight",
          "watering": "Once a week",
          "sunlight": "4-6 hours of sunlight",
          "description": "A staple vegetable used in various dishes worldwide.",
          "image": "assets/images/onion.jpg"
        },
        "28": {
          "name": "Coriander",
          "scientific_name": "Coriandrum sativum",
          "family": "Apiaceae",
          "uses": "Culinary, medicinal",
          "habitat": "Temperate regions",
          "growth_conditions": "Moist soil, full sunlight",
          "watering": "Every 2 days",
          "sunlight": "4-6 hours of sunlight",
          "description": "A fragrant herb used in various cuisines for its fresh flavor.",
          "image": "assets/images/corriander.jpg"
        },
        "29": {
          "name": "Pomegranate",
          "scientific_name": "Punica granatum",
          "family": "Lythraceae",
          "uses": "Fruit, medicinal",
          "habitat": "Tropical and subtropical regions",
          "growth_conditions": "Well-drained soil, full sunlight",
          "watering": "Once a week",
          "sunlight": "6-8 hours of direct sunlight",
          "description": "A fruit with a tough outer rind and juicy, seed-filled interior.",
          "image": "assets/images/pome.jpg"
        },
        "30": {
          "name": "Spinach",
          "scientific_name": "Spinacia oleracea",
          "family": "Amaranthaceae",
          "uses": "Leafy vegetable, nutritional",
          "habitat": "Temperate regions",
          "growth_conditions": "Moist soil, partial sunlight",
          "watering": "Keep soil moist",
          "sunlight": "4-6 hours of sunlight",
          "description": "A leafy green vegetable rich in iron and vitamins.",
          "image": "assets/images/spinach.jpg"
        },
      };
      for (var entry in plantsData.entries) {
        // 🔹 Add lowercase name for case-insensitive search
        entry.value["name_lowercase"] = entry.value["name"].toLowerCase();

        await plantsCollection.doc(entry.key).set(entry.value);
      }

      print("✅ All plant data uploaded to Firestore successfully!");
    } catch (e) {
      print("❌ Error uploading plant data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Plants Data")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            uploadData();
          },
          child: Text("Upload Plant Data"),
        ),
      ),
    );
  }
}
