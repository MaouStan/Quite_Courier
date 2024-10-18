import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class UserService {
  // {{ edit_12: Define fetchRiderPosition method }}
  static Future<LatLng> fetchRiderPosition(String riderTelephone) async {

    
    // Simulate a network call to fetch rider's position
    // Replace this with your actual database/API call
    // final response =
    //     await http.get(Uri.parse('https://yourapi.com/rider/$riderTelephone/position'));

    // if (response.statusCode == 200) {
    //   final data = json.decode(response.body);
    //   return LatLng(data['latitude'], data['longitude']);
    // } else {
    //   throw Exception('Failed to load rider position');
    // }

    // var random = Random();
    // // in range lat 16.250743 ± 0.05
    // // in range long 103.24796 ± 0.05
    // return LatLng(random.nextDouble() * 0.1 + 16.250743 - 0.05,
    //     random.nextDouble() * 0.1 + 103.24796 - 0.05);

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot riderDoc =
        await firestore.collection('riders').doc(riderTelephone).get();
    return LatLng(
        riderDoc['location']['latitude'], riderDoc['location']['longitude']);
  }

  // {{ edit_13: Define fetchRiderPositions method }}
  static Future<Map<String, LatLng>> fetchRiderPositions(
      List<String> riderTelephones) async {
    Map<String, LatLng> positions = {};
    for (String riderTelephone in riderTelephones) {
      // // Simulate a network call to fetch each rider's position
      // // Replace this with your actual database/API call
      // // final response = await http
      // //     .get(Uri.parse('https://yourapi.com/rider/$riderTelephone/position'));

      // // if (response.statusCode == 200) {
      // //   final data = json.decode(response.body);
      // //   positions[riderTelephone] = LatLng(data['latitude'], data['longitude']);
      // // } else {
      // //   throw Exception('Failed to load rider position for $riderTelephone');
      // // }
      // var random = Random();
      // positions[riderTelephone] = LatLng(random.nextDouble() * 0.1 + 16.250743 - 0.05,
      //     random.nextDouble() * 0.1 + 103.24796 - 0.05);
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      dev.log('Fetching rider position for $riderTelephone');
      DocumentSnapshot riderDoc = await firestore.collection('riders').doc(riderTelephone).get();
      positions[riderTelephone] = LatLng(riderDoc['location']['latitude'], riderDoc['location']['longitude']);
    }
    dev.log('positions: $positions');
    return positions;
  }

  static Stream<LatLng> getRiderPositionStream(String riderTelephone) {
    return FirebaseFirestore.instance
        .collection('riders')
        .doc(riderTelephone)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data != null && data['location'] != null) {
        final LatLng position = LatLng(data['location']['latitude'], data['location']['longitude']);
        return position;
      }
      return const LatLng(0, 0); // Default position if data is not available
    });
  }

}
