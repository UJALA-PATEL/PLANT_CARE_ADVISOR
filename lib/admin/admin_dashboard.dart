import 'package:flutter/material.dart';
import 'package:sejjjjj/admin/edit_product_screen.dart'; // ✅ Import Fix
import 'add_product_screen.dart';
import 'manage_products_screen.dart';
import 'manage_orders_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome, Admin!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              children: [
                _buildDashboardCard(context, "Manage Products", Icons.storefront, ManageProductsScreen()),
                _buildDashboardCard(context, "Orders", Icons.shopping_cart, ManageOrdersScreen()),
                _buildDashboardCard(context, "Add Product", Icons.add_box, const AddProductScreen()),
                _buildDashboardCard(
                  context,
                  "Edit Product",
                  Icons.mode_edit_outline_outlined,
                  EditProductScreen(
                      productId: "test_product_id",
                      data: const {"name": "Sample Plant", "price": 20.0}
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
