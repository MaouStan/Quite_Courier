import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/models/user_data.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  static Future<Map<String, LatLng>> fetchRiderPositions(
      List<String> riderIds) async {
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

  Future<void> registerUser({
    required String telephone,
    required String password,
    required String name,
    required String description,
    required String location,
    File? profileImage,
  }) async {
    // Check if the telephone number already exists
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(telephone).get();

    if (userDoc.exists) {
      throw Exception('This telephone number is already registered.');
    }

    // If not, save the user data
    await _firestore.collection('users').doc(telephone).set({
      'telephone': telephone,
      'password': password,
      'name': name,
      'description': description,
      'location': location,
      'profileImageUrl': "profileImage",
    });
  }


 
}
