import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatelessWidget {
  void removeFromCart(String docId) {
    FirebaseFirestore.instance.collection('cart').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('cart').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var cartItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              var item = cartItems[index];

              return Card(
                child: ListTile(
                  leading: Image.network(item['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(item['productName']),
                  subtitle: Text("₹${item['price']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeFromCart(item.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
