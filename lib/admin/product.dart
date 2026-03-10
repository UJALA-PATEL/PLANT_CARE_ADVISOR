class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final String description;
  final int stock;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.description,
    required this.stock,
    required this.rating,
  });

  // Firestore se data fetch karne ke liye factory method
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? 'Unknown',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      stock: data['stock'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
    );
  }
}
