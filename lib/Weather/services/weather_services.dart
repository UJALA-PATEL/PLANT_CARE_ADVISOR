import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sejjjjj/Weather/weather_model.dart';


class WeatherService {
  final String apiKey = "2b3441c1f5846c5af11dac3b4ee1e1ec"; // Replace with your real OpenWeather API key

  Future<Weather> fetchWeather(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather');
    }
  }

  Future<Weather> fetchWeatherByLocation(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather');
    }
  }

}
