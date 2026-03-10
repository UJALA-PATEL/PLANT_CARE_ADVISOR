import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> data;

  const EditProductScreen({super.key, required this.productId, required this.data});

  @override
  EditProductScreenState createState() => EditProductScreenState();
}

class EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController imageUrlController;
  late TextEditingController descriptionController;

  String selectedCategory = "Plant"; // Default category

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.data['name']);
    priceController = TextEditingController(text: widget.data['price'].toString());
    imageUrlController = TextEditingController(text: widget.data['imageUrl']);
    descriptionController = TextEditingController(text: widget.data['description']);

    // Jo category Firestore me saved hai, wo default selected hogi
    selectedCategory = widget.data['category'] ?? "Plant";
  }

  Future<void> updateProduct() async {
    final BuildContext currentContext = context; // Store context before async call

    try {
      await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
        'name': nameController.text,
        'price': double.tryParse(priceController.text) ?? 0.0, // Handle invalid input
        'imageUrl': imageUrlController.text,
        'description': descriptionController.text,
        'category': selectedCategory, // Update category
      });

      if (mounted) {
        Navigator.pop(currentContext); // Ensure context is still valid
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text("Error updating product: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Product Name")),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            TextField(controller: imageUrlController, decoration: const InputDecoration(labelText: "Image URL")),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),

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
            ElevatedButton(onPressed: updateProduct, child: const Text("Update Product")),
          ],
        ),
      ),
    );
  }
}
