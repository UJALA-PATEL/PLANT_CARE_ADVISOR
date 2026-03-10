import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  final String _apiKey = "2b3441c1f5846c5af11dac3b4ee1e1ec"; // Replace if needed

  Future<String> fetchWeatherData() async {
    try {
      Position position = await _getCurrentLocation();
      final latitude = position.latitude;
      final longitude = position.longitude;

      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weatherCondition = data['weather'][0]['main'];
        final temperature = data['main']['temp'];
        return '$weatherCondition, Temp: $temperature°C';
      } else {
        return 'Failed to load weather data';
      }
    } catch (e) {
      return 'Error fetching weather data';
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception("Location permission denied.");
      }
    }

    return await Geolocator.getCurrentPosition();
  }
}
