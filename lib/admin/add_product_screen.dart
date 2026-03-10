import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  AddProductScreenState createState() => AddProductScreenState();
}

class AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedCategory = "Plant"; // Default category

  Future<void> addProduct() async {
    final BuildContext currentContext = context; // Store context before async call

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': nameController.text,
        'price': double.tryParse(priceController.text) ?? 0.0, // Handle invalid input
        'imageUrl': imageUrlController.text,
        'description': descriptionController.text,
        'category': selectedCategory, // Save category in Firestore
      });

      if (mounted) {
        Navigator.pop(currentContext); // Ensure context is still valid
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text("Error adding product: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: "Image URL"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),

            // Dropdown for Category Selection
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: "Category"),
              items: ["Plant", "Tools"].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(onPressed: addProduct, child: const Text("Add Product")),
          ],
        ),
      ),
    );
  }
}
