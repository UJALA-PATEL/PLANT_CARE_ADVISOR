import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sejjjjj/myplant/weather_service.dart';
import 'package:timezone/timezone.dart' as tz;

class AddPlantScreen extends StatefulWidget {
  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();

  String plantName = '';
  String reminderTime = '';
  String imageUrl = '';
  DateTime selectedTime = DateTime.now();
  String weatherInfo = '';

  File? _image;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchUserWeather();
  }

  void _initializeNotifications() {
    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imageUrl = pickedFile.path;
      });
    }
  }

  Future<void> _fetchUserWeather() async {
    try {
      WeatherService weatherService = WeatherService();
      String weather = await weatherService.fetchWeatherData();
      setState(() {
        weatherInfo = weather;
      });

      if (weather.contains('Rain')) {
        _sendWeatherNotification(
            'It\'s raining, don\'t water the plant today!');
      } else if (weather.contains('Sunny') ||
          _getTemperature(weather) > 30) {
        _sendWeatherNotification('It\'s hot, make sure to water the plant!');
      }
    } catch (e) {
      setState(() {
        weatherInfo = 'Unable to fetch weather data.';
      });
    }
  }

  double _getTemperature(String weather) {
    final tempStr = weather.split('Temp: ')[1].split('°')[0];
    return double.parse(tempStr);
  }

  void _sendWeatherNotification(String message) async {
    await flutterLocalNotificationsPlugin.show(
      0,
      'Plant Care Reminder',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weather_channel',
          'Weather Notifications',
          channelDescription: 'Notifications based on weather conditions',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  void _scheduleReminder() async {
    // Parsing the reminder time
    final timeParts = reminderTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1].split(' ')[0]);
    final isAM = reminderTime.contains('AM');

    // Adjust the hour for AM/PM
    int adjustedHour = isAM ? hour % 12 : (hour % 12) + 12;

    // Create a DateTime object using today's date and the parsed reminder time
    DateTime reminderDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      adjustedHour,
      minute,
    );

    // If the reminder time is in the past, set it for the next day
    if (reminderDateTime.isBefore(DateTime.now())) {
      reminderDateTime = reminderDateTime.add(Duration(days: 1));
    }

    tz.TZDateTime tzDateTime = tz.TZDateTime.from(reminderDateTime, tz.local);

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Plant Reminder',
      'Time to water your plant!',
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminder Notifications',
          channelDescription: 'Reminder channel for plant care',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }


  Future<Position> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error('Location permissions are denied.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String imageUrlInFirebase = '';
      if (_image != null) {
        try {
          // Debugging file path
          print("Picked file path: ${_image!.path}");

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('plant_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

          // Upload image
          await storageRef.putFile(_image!);
          imageUrlInFirebase = await storageRef.getDownloadURL();

          // Debugging image URL after upload
          print("Image URL in Firebase: $imageUrlInFirebase");
        } catch (e) {
          print("Error uploading image: $e");
        }
      }

      // Save data to Firestore
      try {
        await FirebaseFirestore.instance.collection('plants').add({
          'name': plantName,
          'reminder': reminderTime,
          'image': imageUrlInFirebase,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _scheduleReminder();
        Navigator.pop(context);
      } catch (e) {
        print("Error saving plant data to Firestore: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Plant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Plant Name'),
                onSaved: (value) => plantName = value!,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter plant name';
                  return null;
                },
              ),
              TextFormField(
                decoration:
                InputDecoration(labelText: 'Reminder Time (e.g., 8:00 AM)'),
                onSaved: (value) => reminderTime = value!,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter reminder time';
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.camera_alt),
                label: Text('Pick a Plant Image'),
              ),
              if (_image != null) Image.file(_image!),
              SizedBox(height: 20),
              Text('Current Weather: $weatherInfo'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Save Plant'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
