import "package:razorpay_flutter/razorpay_flutter.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // ✅ For debugPrint

class RazorpayService {
  late Razorpay _razorpay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentOrderId; // To store Firestore order ID

  RazorpayService() {
    _razorpay = Razorpay();

    // Event listeners for payment
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Function to start payment
  void startPayment({
    required String orderId,
    required String productName,
    required double amount,
    required String description,
    required String userPhone,
    required String userEmail,
    required Function(String) onSuccess,
    required Function(String) onFailure,
  }) {
    _currentOrderId = orderId; // Store Firestore order ID

    var options = {
      'key': 'rzp_test_SSbqaYS66229Xd', // Replace with your Razorpay API Key
      'amount': (amount * 100).toInt(), // ✅ Convert amount to integer
      'name': productName,
      'description': description,
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
      }
    };

    try {
      debugPrint("🚀 Opening Razorpay with options: $options"); // ✅ Debugging Only
      _razorpay.clear(); // ✅ Ensure previous session is cleared
      _razorpay.open(options);
    } catch (e) {
      debugPrint("🔥 Error starting payment: $e");
      onFailure(e.toString());
    }
  }

  // Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_currentOrderId == null) {
      debugPrint("❌ Error: Order ID not found!");
      return;
    }

    debugPrint("✅ Payment Successful: ${response.paymentId}");

    try {
      await _firestore.collection('orders').doc(_currentOrderId).update({
        'paymentStatus': 'completed',
        'transactionId': response.paymentId,
      });

      debugPrint("✅ Firestore Updated: Order $_currentOrderId Completed");
    } catch (e) {
      debugPrint("❌ Firestore Update Error: $e");
    }
  }

  // Handle payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("❌ Payment Failed: ${response.message}");
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("ℹ️ External Wallet: ${response.walletName}");
  }

  // Dispose method to clear Razorpay instance
  void dispose() {
    try {
      _razorpay.clear();
    } catch (e) {
      debugPrint("⚠️ Error clearing Razorpay: $e");
    }
  }
}
