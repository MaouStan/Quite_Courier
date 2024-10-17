import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/controller/user_controller.dart';
import 'package:quite_courier/models/auth_res.dart';
import 'package:quite_courier/models/user_data.dart';
import 'dart:io';

import 'package:quite_courier/pages/map_page.dart';
import 'package:quite_courier/services/auth_service.dart';
import 'package:quite_courier/services/utils.dart'; // Add this import to handle File

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserController userController = Get.find<UserController>();
  Map<String, TextEditingController>? controllers;
  bool isEditMode = false; // Track edit mode
  File? _selectedImage; // Temporary variable to hold selected image
  LatLng? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    controllers = {
      'telephone':
          TextEditingController(text: userController.userData.value.telephone),
      'name': TextEditingController(text: userController.userData.value.name),
      'gpsMap': TextEditingController(
          text:
              '${userController.userData.value.location.latitude}, ${userController.userData.value.location.longitude}'),
      'addressDescription': TextEditingController(
          text: userController.userData.value.addressDescription),
    };

    log('UserData: ${userController.userData.value.toString()}');
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
        title: const Text('User Profile'),
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
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!) as ImageProvider
                          : (userController
                                  .userData.value.profileImageUrl.isNotEmpty
                              ? NetworkImage(
                                  userController.userData.value.profileImageUrl)
                              : null),
                      child: (_selectedImage == null &&
                              (userController
                                  .userData.value.profileImageUrl.isEmpty))
                          ? const Icon(Icons.person, size: 80)
                          : null,
                    ),
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
                  const Text('GPS Map'),
                  Stack(
                    children: [
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fillColor: isEditMode
                              ? Colors.white
                              : const Color(0xFFECECEC),
                          filled: true,
                        ),
                        style: TextStyle(
                          color: isEditMode ? Colors.black : Colors.grey[700],
                        ),
                        controller: controllers!['gpsMap'],
                      ),
                      Positioned(
                        right: 0,
                        bottom: 5,
                        child: IconButton(
                          icon: Image.asset(
                            'assets/images/google-maps.png',
                            width: 32,
                          ),
                          onPressed: () async {
                            // if mode edit
                            if (!isEditMode) return;
                            LatLng? oldPostiion = _selectedPosition;
                            _selectedPosition = await Get.to(() => MapPage(
                                  mode: MapMode.select,
                                  selectedPosition: oldPostiion,
                                ));
                            log('selectedPosition: $_selectedPosition');
                            if (_selectedPosition != null) {
                              controllers!['gpsMap']!.text =
                                  '${_selectedPosition!.latitude}, ${_selectedPosition!.longitude}';
                            } else {
                              controllers!['gpsMap']!.text =
                                  '${oldPostiion!.latitude}, ${oldPostiion.longitude}';
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Address Description'),
                  TextField(
                    maxLines: 3,
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
                    controller: controllers!['addressDescription'],
                    enabled: isEditMode,
                  ),
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
                              _selectedImage = null;
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
                          onPressed: updateProfileUser,
                          icon: const Icon(Icons.save),
                          label: const Text('Update Profile'),
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

  void updateProfileUser() async {
    // loading
    Get.dialog(const Center(child: CircularProgressIndicator()));

    try {
      log('selectedImage: $_selectedImage');
      UserData profileUpdateReq = userController.userData.value;
      profileUpdateReq.name = controllers!['name']!.text;

      profileUpdateReq.addressDescription =
          controllers!['addressDescription']!.text;
      profileUpdateReq.location = LatLng(
        double.parse(controllers!['gpsMap']!.text.split(',')[0]),
        double.parse(controllers!['gpsMap']!.text.split(',')[1]),
      );

      AuthService authService = AuthService();
      AuthResponse response = await authService.updateProfileUser(
        profileUpdateReq,
        _selectedImage,
      );

      Get.back();
      Get.closeAllSnackbars();
      if (response.success) {
        Get.snackbar('Success', response.message);
      } else {
        Get.snackbar('Error', response.message);
      }
      setState(() {
        isEditMode = false;
        _selectedImage = null;
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
      Get.back();
    }
  }

  void _showProfilePhotoMenu(BuildContext context) {
    Utils utils = Utils();

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
                File? selected = await utils.takePhoto();
                if (selected != null) {
                  setState(() {
                    _selectedImage = selected;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick Image'),
              onTap: () async {
                Navigator.pop(context);
                File? selected = await utils.pickImage();
                if (selected != null) {
                  setState(() {
                    _selectedImage = selected;
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
