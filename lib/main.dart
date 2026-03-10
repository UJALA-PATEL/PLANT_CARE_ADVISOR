import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sejjjjj/myplant/uploadimage.dart';
import 'package:sejjjjj/search/upload_palnt_data.dart';
import 'package:sejjjjj/splash_screen.dart';
import 'package:sejjjjj/theme_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'Weather/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  tz.initializeTimeZones(); // ✅ Required for correct scheduling
  NotificationService.initNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),

    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GetMaterialApp(
          title: 'My Project',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home:const SplashScreen(),
        );
      },
    );
  }
}














/*
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminDashboard(), // Admin Dashboard Show Hoga
    );
  }
}*/
