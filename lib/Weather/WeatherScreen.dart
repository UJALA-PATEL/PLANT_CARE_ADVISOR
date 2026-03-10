import 'package:flutter/material.dart';
import 'package:sejjjjj/Weather/services/weather_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sejjjjj/Weather/weather_model.dart';
import 'package:geocoding/geocoding.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Weather? _weather;
  bool _isLoading = false;
  final _weatherService = WeatherService();
  String? _customLocation;

  // 📍 Get Place Name from Coordinates
  Future<String> getPlaceNameFromCoordinates(double lat, double lon) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return "${place.subLocality}, ${place.locality}";
    }
    return "Unknown location";
  }

  // 📍 Get Weather from Location
  void _getCurrentLocationWeather() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("Location services are disabled.");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception("Permission denied");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final weather = await _weatherService.fetchWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      final customLoc = await getPlaceNameFromCoordinates(position.latitude, position.longitude);

      setState(() {
        _weather = weather;
        _customLocation = customLoc;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get location.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocationWeather();
  }

  // 🖼️ Weather Icon Helper
  IconData _getWeatherIcon(String description) {
    final d = description.toLowerCase();
    if (d.contains('sun')) return Icons.wb_sunny_rounded;
    if (d.contains('cloud')) return Icons.cloud;
    if (d.contains('rain')) return Icons.beach_access;
    if (d.contains('storm')) return Icons.flash_on;
    if (d.contains('snow')) return Icons.ac_unit;
    return Icons.wb_cloudy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌱 Plant Weather"),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 📍 Refresh Location Weather
              ElevatedButton.icon(
                onPressed: _getCurrentLocationWeather,
                icon: const Icon(Icons.my_location),
                label: const Text("Refresh Weather"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),

              const SizedBox(height: 40),

              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : _weather != null
                      ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getWeatherIcon(_weather!.description),
                        size: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _customLocation ?? _weather!.cityName,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${_weather!.temperature}°C",
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _weather!.description,
                        style: const TextStyle(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  )
                      : const Text(
                    "No weather data available.",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
