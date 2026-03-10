import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AddressScreen extends StatefulWidget {
  final VoidCallback onAddressSaved;

  const AddressScreen({Key? key, required this.onAddressSaved}) : super(key: key);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchSavedAddress();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // Fetch saved address from Firestore if available
  Future<void> _fetchSavedAddress() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;

      _fullNameController.text = userData['fullName'] ?? '';
      _phoneController.text = userData['phone'] ?? '';
      _houseController.text = userData['house'] ?? '';
      _streetController.text = userData['street'] ?? '';
      _cityController.text = userData['city'] ?? '';
      _stateController.text = userData['state'] ?? '';
      _pincodeController.text = userData['pincode'] ?? '';
    }
  }

  // Save the address and trigger address saved callback
  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      String fullAddress =
          "${_houseController.text}, ${_streetController.text}, ${_cityController.text}, ${_stateController.text} - ${_pincodeController.text}";

      String uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'house': _houseController.text.trim(),
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'state': _stateController.text.trim(),
        'address': fullAddress,
      }, SetOptions(merge: true));

      widget.onAddressSaved(); // Go back and trigger Buy Now
      Navigator.pop(context);
    }
  }

  // Show payment option dialog to choose payment method
  void _showPaymentOptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose Payment Method"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Online Payment"),
              leading: Icon(Icons.payment),
              onTap: () {
                Navigator.pop(context); // Close dialog
                _startRazorpayPayment(); // Start Razorpay Payment
              },
            ),
            ListTile(
              title: Text("Cash on Delivery"),
              leading: Icon(Icons.money),
              onTap: () {
                Navigator.pop(context);
                _handleCOD(); // Handle COD
              },
            ),
          ],
        ),
      ),
    );
  }

  // Start Razorpay payment
  void _startRazorpayPayment() {
    var options = {
      'key': 'YOUR_RAZORPAY_KEY_HERE', // Replace with your Razorpay key
      'amount': 50000, // ₹500 in paise
      'name': 'Your Shop',
      'description': 'Purchase Items',
      'prefill': {
        'contact': _phoneController.text,
        'email': 'test@example.com' // Optional
      },
      'external': {
        'wallets': ['paytm'] // Optional, can include wallets like Paytm, PhonePe etc.
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful!")),
    );
    _saveOrderToFirestore("Online Payment");
  }

  // Handle payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed")),
    );
  }

  // Handle external wallet (e.g., Paytm, PhonePe)
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet selected")),
    );
  }

  // Handle Cash on Delivery
  void _handleCOD() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order Placed with COD")),
    );
    _saveOrderToFirestore("Cash on Delivery");
  }

  // Save order info to Firestore
  void _saveOrderToFirestore(String paymentMethod) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String orderId = DateTime.now().millisecondsSinceEpoch.toString();

    await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
      'userId': uid,
      'fullName': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': "${_houseController.text}, ${_streetController.text}, ${_cityController.text}, ${_stateController.text} - ${_pincodeController.text}",
      'paymentMethod': paymentMethod,
      'orderDate': DateTime.now(),
      'status': paymentMethod == "Online Payment" ? "Pending Payment" : "Confirmed",
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order has been placed successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Delivery Address")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: "Full Name"),
                validator: (value) => value!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                validator: (value) => value!.isEmpty ? "Enter phone" : null,
              ),
              TextFormField(
                controller: _houseController,
                decoration: InputDecoration(labelText: "House No./Building"),
                validator: (value) => value!.isEmpty ? "Enter house number" : null,
              ),
              TextFormField(
                controller: _streetController,
                decoration: InputDecoration(labelText: "Street/Area"),
                validator: (value) => value!.isEmpty ? "Enter street" : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City"),
                validator: (value) => value!.isEmpty ? "Enter city" : null,
              ),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(labelText: "State"),
                validator: (value) => value!.isEmpty ? "Enter state" : null,
              ),
              TextFormField(
                controller: _pincodeController,
                decoration: InputDecoration(labelText: "Pincode"),
                validator: (value) => value!.isEmpty ? "Enter pincode" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveAddress().then((_) {
                      _showPaymentOptionDialog(); // Show payment options after saving address
                    });
                  }
                },
                child: Text("Buy Now"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
