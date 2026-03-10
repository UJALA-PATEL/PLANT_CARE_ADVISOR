import 'package:geocoding/geocoding.dart';

Future<String> getPlaceNameFromCoordinates(double lat, double lon) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
  if (placemarks.isNotEmpty) {
    final place = placemarks.first;
    return "${place.locality}, ${place.subLocality}";
  }
  return "Unknown location";
}
