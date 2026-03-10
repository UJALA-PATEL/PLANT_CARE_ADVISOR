import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Weather/reminder_page.dart';
import 'theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _saveSettings(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationsEnabled', value);
  }

  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear SharedPreferences

    // Delete all reminders from Firestore
    FirebaseFirestore.instance.collection('reminders').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    setState(() {
      notificationsEnabled = true; // Reset settings
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("App data reset successfully!")),
    );
  }

  Future<void> _syncData() async {
    await FirebaseFirestore.instance.collection('syncStatus').doc('lastSync').set({
      "lastSynced": DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data synced successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plant Care Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            subtitle: const Text("Manage watering reminders"),
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (val) {
                setState(() {
                  notificationsEnabled = val;
                });

                _saveSettings(val); // ✅ Settings save karega

                // ✅ Agar switch ON ho to ReminderScreen pe navigate kare
                if (val) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReminderScreen()),
                  );
                }
              },
            ),
          ),


          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text("Plant Database Sync"),
            subtitle: const Text("Sync data with cloud"),
            onTap: _syncData,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text("Reset Data"),
            subtitle: const Text("Clear all app data"),
            onTap: _resetData,
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text("Theme Mode"),
            subtitle: const Text("Dark/Light mode"),
            trailing: Switch(
              value: Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark,
              onChanged: (val) {
                Provider.of<ThemeProvider>(context, listen: false).setTheme(
                  val ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            subtitle: const Text("Learn more about the app"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}


// ✅ Notification Settings Page
class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  NotificationSettingsState createState() => NotificationSettingsState();
}

class NotificationSettingsState extends State<NotificationSettings> {
  bool notificationsEnabled = true;
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool wateringReminder = true;
  bool fertilizingReminder = false;

  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Enable Notifications"),
              subtitle: const Text("Turn notifications on or off"),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
            ListTile(
              title: const Text("Set Reminder Time"),
              subtitle: Text("Selected Time: ${selectedTime.format(context)}"),
              trailing: const Icon(Icons.timer),
              onTap: _pickTime,
            ),
            SwitchListTile(
              title: const Text("Watering Reminders"),
              subtitle: const Text("Get reminders to water your plants"),
              value: wateringReminder,
              onChanged: (value) {
                setState(() {
                  wateringReminder = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text("Fertilizing Reminders"),
              subtitle: const Text("Get reminders to fertilize your plants"),
              value: fertilizingReminder,
              onChanged: (value) {
                setState(() {
                  fertilizingReminder = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Watering Schedule Page
class WateringSchedule extends StatelessWidget {
  const WateringSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Watering Schedule")),
      body: const Center(child: Text("Customize your watering schedule here.")),
    );
  }
}
