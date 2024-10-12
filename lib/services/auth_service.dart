import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/controller/user_controller.dart';
import 'package:quite_courier/models/auth_res.dart';
import 'package:quite_courier/models/user_data.dart';
import 'package:quite_courier/models/user_sign_up_data.dart';
import 'package:quite_courier/models/rider_sign_up_data.dart';
import 'package:quite_courier/services/firebase_service.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService =
      FirebaseService(); // Create an instance of FirebaseService

  Future<AuthResponse> registerUser(
    UserSignUpData signUpData,
    File? profileImage,
  ) async {
    // Check if the telephone number already exists
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(signUpData.telephone).get();

    if (userDoc.exists) {
      return AuthResponse(
          success: false,
          message: 'This telephone number is already registered.');
    }

    // Upload the profile image first if it exists
    String? profileImageUrl;
    if (profileImage != null) {
      profileImageUrl = await _firebaseService.uploadImage(
          profileImage, 'profile_images/${signUpData.telephone}');
      if (profileImageUrl == null) {
        return AuthResponse(
            success: false, message: "Failed to upload profile image.");
      }
    } else {
      return AuthResponse(
          success: false, message: "Please upload a profile image");
    }

    // Save the user data with the uploaded image URL
    try {
      await _firestore.collection('users').doc(signUpData.telephone).set({
        'telephone': signUpData.telephone,
        'password': signUpData.password,
        'name': signUpData.name,
        'addressDescription': signUpData.addressDescription,
        'location': {
          'latitude': signUpData.location!.latitude,
          'longitude': signUpData.location!.longitude,
        },
        'profileImageUrl': profileImageUrl,
      });
      return AuthResponse(
          success: true, message: 'User registered successfully');
    } catch (e) {
      return AuthResponse(
          success: false, message: 'Failed to register user: ${e.toString()}');
    }
  }

  Future<AuthResponse> registerRider(
    RiderSignUpData signUpData,
    File? profileImage,
    File? vehicleImage,
  ) async {
    // Check if the telephone number already exists
    DocumentSnapshot riderDoc =
        await _firestore.collection('riders').doc(signUpData.telephone).get();
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(signUpData.telephone).get();

    if (userDoc.exists || riderDoc.exists) {
      return AuthResponse(
          success: false,
          message: 'This telephone number is already registered.');
    }

    // Upload the profile image first if it exists
    String? profileImageUrl;
    String? vehicleImageUrl;
    if (profileImage != null) {
      profileImageUrl = await _firebaseService.uploadImage(
          profileImage, 'profile_images/${signUpData.telephone}');
    }
    if (vehicleImage != null) {
      vehicleImageUrl = await _firebaseService.uploadImage(
          vehicleImage, 'vehicle_images/${signUpData.telephone}');
      if (vehicleImageUrl == null) {
        return AuthResponse(
            success: false, message: "Failed to upload vehicle image.");
      }
    } else {
      return AuthResponse(
          success: false, message: "Please upload a profile image");
    }

    // Save the user data with the uploaded image URL
    try {
      await _firestore.collection('riders').doc(signUpData.telephone).set({
        'profileImageUrl': profileImageUrl,
        'telephone': signUpData.telephone,
        'password': signUpData.password,
        'name': signUpData.name,
        'vehicleImage': vehicleImageUrl,
        'vehicleRegistration': signUpData.vehicleRegistration,
        'location': {
          'latitude': signUpData.location.latitude,
          'longitude': signUpData.location.longitude,
        },
      });
      return AuthResponse(
          success: true, message: 'User registered successfully');
    } catch (e) {
      return AuthResponse(
          success: false, message: 'Failed to register user: ${e.toString()}');
    }
  }

  Future<AuthResponse> updateProfileUser(
      UserData userData, File? profileImage) async {
    // name profileImage location and addressDescription
    String? profileImageUrl;
    if (profileImage != null) {
      profileImageUrl = await _firebaseService.uploadImage(
          profileImage, 'profile_images/${userData.telephone}');
      dev.log('profileImageUrl: $profileImageUrl');
      if (profileImageUrl == null) {
        return AuthResponse(
            success: false, message: "Failed to upload profile image.");
      }
    }

    if (userData.addressDescription == null) {
      return AuthResponse(
          success: false, message: "Please fill in all the fields.");
    }

    try {
      // upadate user data
      await _firestore.collection('users').doc(userData.telephone).update({
        'name': userData.name,
        'profileImageUrl': profileImageUrl ?? userData.profileImageUrl,
        'location': {
          'latitude': userData.location.latitude,
          'longitude': userData.location.longitude,
        },
        'addressDescription': userData.addressDescription,
      });

      // update user data in user controller
      UserController userController = Get.find<UserController>();
      dev.log('userData.name: ${userData.name}');
      userController.userData.value = userData;
      dev.log('userController.userData.value: ${userController.userData.value.toString()}');
      return AuthResponse(
          success: true, message: 'Profile updated successfully');
    } catch (e) {
      return AuthResponse(
          success: false, message: 'Failed to update profile: ${e.toString()}');
    }
  }

  Future<List<UserData>> fetchOtherUsers(String currentUserTelephone) async {
    try {
      QuerySnapshot userDocs = await _firestore
          .collection('users')
          .where('telephone', isNotEqualTo: currentUserTelephone)
          .get();

      dev.log('userDocs: ${userDocs.docs.length}');

      return userDocs.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserData(
          profileImageUrl: data['profileImageUrl'] ?? '',
          telephone: data['telephone'] ?? '',
          name: data['name'] ?? '',
          location: LatLng(
            data['location']['latitude'] ?? 0.0,
            data['location']['longitude'] ?? 0.0,
          ),
          addressDescription: data['addressDescription'] ?? '',
        );
      }).toList();
    } catch (e) {
      dev.log('Error fetching other users: $e');
      return [];
    }
  }
}
