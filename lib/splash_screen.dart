import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sejjjjj/Screens/login.dart';
import 'package:sejjjjj/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Rotation Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 3 sec mein full rotation
    );

    // Jab animation complete ho, tab screen change karein
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        User? user = FirebaseAuth.instance.currentUser;
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => user != null ? const DashboardPage() :  const Login(),
            ),
          );
        }
      }
    });

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Memory leak na ho
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF014C07),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rotating Icon
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * 3.1416, // 360° rotation
                    child: child,
                  );
                },
                child: const Icon(
                  Icons.eco,
                  color: Colors.greenAccent,
                  size: 100,
                ),
              ),
              const SizedBox(height: 20),

              // Styled Text
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Plant",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: " Care",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
