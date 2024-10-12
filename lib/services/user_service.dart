import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/services/firebase_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService =
      FirebaseService(); // Create an instance of FirebaseService

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

  Future<String> registerUser({
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
      return 'This telephone number is already registered.';
    }

    // Upload the profile image first if it exists
    String? profileImageUrl;
    if (profileImage != null) {
      profileImageUrl = await _firebaseService.uploadImage(
          profileImage, 'profile_images/$telephone');
      if (profileImageUrl == null) {
        return "Failed to upload profile image.";
      }
    } else {
      return "Please upload a profile image";
    }

    // Save the user data with the uploaded image URL
    try {
      await _firestore.collection('users').doc(telephone).set({
        'telephone': telephone,
        'password': password,
        'name': name,
        'description': description,
        'location': location,
        'profileImageUrl': profileImageUrl,
      });
      return 'User registered successfully';
    } catch (e) {
      return 'Failed to register user: ${e.toString()}';
    }
  }
}
