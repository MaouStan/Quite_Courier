import 'dart:convert';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class UserService {
  // {{ edit_12: Define fetchRiderPosition method }}
  static Future<LatLng> fetchRiderPosition(String riderId) async {
    // Simulate a network call to fetch rider's position
    // Replace this with your actual database/API call
    // final response =
    //     await http.get(Uri.parse('https://yourapi.com/rider/$riderId/position'));

    // if (response.statusCode == 200) {
    //   final data = json.decode(response.body);
    //   return LatLng(data['latitude'], data['longitude']);
    // } else {
    //   throw Exception('Failed to load rider position');
    // }

    var random = Random();
    // in range lat 16.250743 ± 0.05
    // in range long 103.24796 ± 0.05
    return LatLng(random.nextDouble() * 0.1 + 16.250743 - 0.05,
        random.nextDouble() * 0.1 + 103.24796 - 0.05);
  }

  // {{ edit_13: Define fetchRiderPositions method }}
  static Future<Map<String, LatLng>> fetchRiderPositions(List<String> riderIds) async {
    Map<String, LatLng> positions = {};
    for (String riderId in riderIds) {
      // Simulate a network call to fetch each rider's position
      // Replace this with your actual database/API call
      // final response = await http
      //     .get(Uri.parse('https://yourapi.com/rider/$riderId/position'));

      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   positions[riderId] = LatLng(data['latitude'], data['longitude']);
      // } else {
      //   throw Exception('Failed to load rider position for $riderId');
      // }
      var random = Random();
      positions[riderId] = LatLng(random.nextDouble() * 0.1 + 16.250743 - 0.05,
          random.nextDouble() * 0.1 + 103.24796 - 0.05);
    }
    return positions;
  }
}
