import 'dart:convert';
import 'dart:developer' as dev;
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapService {
  // {{ edit_11: Define fetchRoute method }}
  static Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    // Construct the URL for the OSRM API
    final url = 'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson';
    dev.log('URL: $url');

    // Make the HTTP GET request
    dev.log('Fetching route from $start to $end');
    final response = await http.get(Uri.parse(url));

    // Check if the response is successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final data = json.decode(response.body);

      // Extract the coordinates from the response
      final List<dynamic> coordinates =
          data['routes'][0]['geometry']['coordinates'];
      // Convert the coordinates to a list of LatLng objects
      return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
    } else {
      // Throw an exception if the request failed
      throw Exception('Failed to load route');
    }
  }
}
