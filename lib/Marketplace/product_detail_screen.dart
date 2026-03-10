import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'razorpay_service.dart';
import 'Address_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  ProductDetailScreenState createState() => ProductDetailScreenState();
}

class ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RazorpayService _razorpayService = RazorpayService();
  String? _savedAddress;

  @override
  void initState() {
    super.initState();
    _fetchSavedAddress();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  Future<void> _fetchSavedAddress() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    final userData = userDoc.data() as Map<String, dynamic>?;

    if (userData != null && userData.containsKey('address')) {
      setState(() {
        _savedAddress = userData['address'];
      });
    }
  }

  Future<String> _placeOrder(String address) async {
    try {
      int quantity = 1;
      double price = widget.product['price'] ?? 0;
      double totalPrice = quantity * price;

      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        print('User not logged in');
        return '';
      }

      var orderRef = await _firestore.collection('orders').add({
        'productId': widget.product['productId'],
        'name': widget.product['name'],
        'price': price,
        'quantity': quantity,
        'totalPrice': totalPrice,
        'imageUrl': widget.product['imageUrl'],
        'description': widget.product['description'],
        'status': 'pending',
        'paymentStatus': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
        'userId': userId,
        'deliveryAddress': address,
      });

      return orderRef.id;
    } catch (e) {
      print('Error placing order: $e');
      return '';
    }
  }

  Future<void> _onPaymentSuccess(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'completed',
        'paymentStatus': 'successful',
        'paymentDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating order: $e');
    }
  }

  void _buyNow(String address) async {
    String orderId = await _placeOrder(address);

    if (orderId.isNotEmpty) {
      _razorpayService.startPayment(
        orderId: orderId,
        productName: widget.product['name'],
        amount: widget.product['price'],
        description: widget.product['description'],
        userPhone: '1234567890', // Replace with actual user phone
        userEmail: 'user@example.com', // Replace with actual user email
        onSuccess: (paymentId) {
          _onPaymentSuccess(orderId);
        },
        onFailure: (errorMessage) {
          print('Payment failed: $errorMessage');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(widget.product['imageUrl']),
            const SizedBox(height: 20),
            Text(widget.product['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("₹${widget.product['price']}", style: const TextStyle(fontSize: 20, color: Colors.green)),
            const SizedBox(height: 10),
            Text(widget.product['description'] ?? "No description available", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // ✅ Address Section
            _savedAddress != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Delivery Address:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_savedAddress!),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddressScreen(
                          onAddressSaved: () {
                            _fetchSavedAddress();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text("Change Address"),
                )
              ],
            )
                : ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddressScreen(
                      onAddressSaved: () {
                        _fetchSavedAddress();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
              child: const Text("Add Delivery Address"),
            ),

            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_savedAddress != null) {
                  _buyNow(_savedAddress!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please add an address first")),
                  );
                }
              },
              child: const Text("Buy Now"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String imagePath) {
    return imagePath.startsWith("assets/")
        ? Image.asset(imagePath, width: double.infinity, height: 200, fit: BoxFit.cover)
        : Image.network(imagePath, width: double.infinity, height: 200, fit: BoxFit.cover);
  }
}
