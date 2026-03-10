import 'package:flutter/material.dart';
import 'package:sejjjjj/myplant/my_plant_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'identification/plant_identification_page.dart';
import 'setting_page.dart';
import 'profile_page.dart';
import 'home_page.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString("themeMode");

    if (theme == "light") {
      _themeMode = ThemeMode.light;
    } else if (theme == "dark") {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("themeMode", mode == ThemeMode.light
        ? "light"
        : mode == ThemeMode.dark
        ? "dark"
        : "system");

    notifyListeners();
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    MyPlantsScreen(),
    PlantIdentificationScreen(),
    const SettingsPage(),
    const UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
        backgroundColor: Colors.green, // ✅ Background hamesha Green rahega
        elevation: 0,
        title: Text(
          'Plant Care',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white // 🌙 Dark Mode → White Text
                : Colors.black, // ☀️ Light Mode → Black Text
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : null,

      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.green[100],
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.green[100],
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey[600],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.local_florist), label: "My Plant"),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "Scan"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
