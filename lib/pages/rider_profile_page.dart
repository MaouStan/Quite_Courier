import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/rider_controller.dart';
import 'package:quite_courier/models/auth_res.dart';
import 'package:quite_courier/models/rider_data.dart';
import 'dart:io';

import 'package:quite_courier/services/utils.dart'; // To handle File
import 'package:quite_courier/services/auth_service.dart';

class RiderProfilePage extends StatefulWidget {
  const RiderProfilePage({super.key});

  @override
  _RiderProfilePageState createState() => _RiderProfilePageState();
}

class _RiderProfilePageState extends State<RiderProfilePage> {
  final RiderController riderController = Get.find<RiderController>();
  final AuthService _authService = AuthService();
  Map<String, TextEditingController>? controllers;
  bool isEditMode = false; // Track edit mode
  File?
      _selectedProfileImage; // Temporary variable to hold selected profile image
  File?
      _selectedVehicleImage; // Temporary variable to hold selected vehicle image

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    controllers = {
      'telephone': TextEditingController(
          text: riderController.riderData.value.telephone),
      'name': TextEditingController(text: riderController.riderData.value.name),
      'vehicleRegistration': TextEditingController(
          text: riderController.riderData.value.vehicleRegistration),
      // Add other fields as necessary
    };
  }

  @override
  void dispose() {
    controllers?.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controllers == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5),
                    ),
                    child: Obx(() {
                      final imageUrl =
                          riderController.riderData.value.profileImageUrl;
                      return CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _selectedProfileImage != null
                            ? FileImage(_selectedProfileImage!) as ImageProvider
                            : (imageUrl != null && imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null),
                        child: (_selectedProfileImage == null &&
                                imageUrl == null)
                            ? const Icon(Icons.person, size: 80)
                            : null,
                      );
                    }),
                  ),
                  if (isEditMode)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          _showProfilePhotoMenu(context);
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Telephone'),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: const Color(0xFFECECEC),
                      filled: true,
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    controller: controllers!['telephone'],
                    enabled: false,
                  ),
                  const SizedBox(height: 10),
                  const Text('Name'),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor:
                          isEditMode ? Colors.white : const Color(0xFFECECEC),
                      filled: true,
                    ),
                    style: TextStyle(
                      color: isEditMode ? Colors.black : Colors.grey[700],
                    ),
                    controller: controllers!['name'],
                    enabled: isEditMode,
                  ),
                  const SizedBox(height: 10),
                  const Text('Vehicle Photo'),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (isEditMode) {
                            _showvehicleImageMenu(context);
                          }
                        },
                        child: Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _selectedVehicleImage != null
                                ? Image.file(
                                    _selectedVehicleImage!,
                                    fit: BoxFit.contain,
                                  )
                                : Image.network(
                                    riderController
                                        .riderData.value.vehicleImage,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.directions_car,
                                        size: 100,
                                        color: Colors.grey,
                                      );
                                    },
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        ),
                      ),
                      if (isEditMode)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black),
                            onPressed: () {
                              _showvehicleImageMenu(context);
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Vehicle Registration'),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor:
                          isEditMode ? Colors.white : const Color(0xFFECECEC),
                      filled: true,
                    ),
                    style: TextStyle(
                      color: isEditMode ? Colors.black : Colors.grey[700],
                    ),
                    controller: controllers!['vehicleRegistration'],
                    enabled: isEditMode,
                  ),
                  // Add more fields as necessary
                ],
              ),
              const SizedBox(height: 20),
              if (isEditMode)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isEditMode = false;
                              _selectedProfileImage = null;
                              _selectedVehicleImage = null;
                              _initializeControllers();
                            });
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: updateProfile,
                          icon: const Icon(Icons.save),
                          label: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isEditMode = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    Get.dialog(const Center(child: CircularProgressIndicator()));
    
    bool success = true;
    String errorMessage = '';

    if (_selectedProfileImage != null) {
      success = await riderController.uploadSelectedImage(_selectedProfileImage!);
      if (!success) errorMessage += 'Failed to upload profile image. ';
    }
    
    if (_selectedVehicleImage != null) {
      success = await riderController.uploadSelectedImage(_selectedVehicleImage!, isProfileImage: false);
      if (!success) errorMessage += 'Failed to upload vehicle image. ';
    }

    // Update other fields using AuthService
    RiderData updatedRiderData = riderController.riderData.value.copyWith(
      name: controllers!['name']?.text,
      vehicleRegistration: controllers!['vehicleRegistration']?.text,
    );

    AuthResponse response = await _authService.updateRiderProfile(updatedRiderData);

    if (response.success) {
      // Update local state
      riderController.updateRiderData(updatedRiderData);
    } else {
      success = false;
      errorMessage += response.message;
    }

    Get.back(); // Close loading dialog

    if (success) {
      Get.snackbar('Success', 'Profile updated successfully');
      setState(() {
        isEditMode = false;
        _selectedProfileImage = null;
        _selectedVehicleImage = null;
      });
    } else {
      Get.snackbar('Error', errorMessage.trim());
    }
  }

  void _showvehicleImageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                File? selected = await Utils().takePhoto();
                if (selected != null) {
                  setState(() {
                    _selectedVehicleImage = selected;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick Image'),
              onTap: () async {
                Navigator.pop(context);
                File? selected = await Utils().pickImage();
                if (selected != null) {
                  setState(() {
                    _selectedVehicleImage = selected;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showProfilePhotoMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                File? selected = await Utils().takePhoto();
                if (selected != null) {
                  setState(() {
                    _selectedProfileImage = selected;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick Image'),
              onTap: () async {
                Navigator.pop(context);
                File? selected = await Utils().pickImage();
                if (selected != null) {
                  setState(() {
                    _selectedProfileImage = selected;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }
}
