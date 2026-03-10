import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  // ✅ Firestore se user ka naam fetch karne ka function
  Future<String> _getUserName(String userId) async {
    if (userId.isEmpty || userId == "Unknown User") {
      print('❌ Invalid User ID: $userId');
      return 'Unknown User';
    }

    try {
      print("🔍 Fetching user name for ID: $userId");

      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        print("✅ User found in Firestore: ${userDoc['name']}");
        return userDoc['name'] ?? 'Unknown User';
      } else {
        print("❌ User not found in Firestore!");
        return 'Unknown User';
      }
    } catch (e) {
      print("❌ Error fetching user name: $e");
      return 'Unknown User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Orders")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var orderData = order.data() as Map<String, dynamic>? ?? {};
              String userId = orderData['userId'] ?? 'Unknown User';

              print("⚡ Checking User ID: $userId"); // ✅ Debugging ke liye

              return FutureBuilder<String>(
                future: _getUserName(userId),
                builder: (context, AsyncSnapshot<String> userNameSnapshot) {
                  String userName =
                  userNameSnapshot.hasData ? userNameSnapshot.data! : 'Loading...';

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(orderData['name'] ?? 'Unknown Product'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("User ID: $userId"),
                          Text("User Name: $userName"),
                          Text("Quantity: ${orderData['quantity']?.toString() ?? 'N/A'}"),
                          Text("Total Price: ₹${orderData['totalPrice']?.toString() ?? 'N/A'}"),
                          Text("Status: ${orderData['status'] ?? 'N/A'}"),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          FirebaseFirestore.instance
                              .collection('orders')
                              .doc(order.id)
                              .update({'status': value});
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: "Pending", child: Text("Pending")),
                          const PopupMenuItem(value: "Shipped", child: Text("Shipped")),
                          const PopupMenuItem(value: "Delivered", child: Text("Delivered")),
                        ],
                        icon: const Icon(Icons.more_vert),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
