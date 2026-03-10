import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sejjjjj/Screens/login.dart';
import 'package:sejjjjj/dashboard.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // User logged in hai, Splash Screen dikhao
              return DashboardPage();
            } else {
              // User logged in nahi hai, Login Screen dikhao
              return const Login();
            }
          }),
    );
  }
}