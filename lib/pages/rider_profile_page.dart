
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/rider_profile_controller.dart';
import 'dart:io'; // To handle File

class RiderProfilePage extends StatefulWidget {
  const RiderProfilePage({super.key});

  @override
  _RiderProfilePageState createState() => _RiderProfilePageState();
}

class _RiderProfilePageState extends State<RiderProfilePage> {
  final RiderProfileController riderProfileController =
      Get.find<RiderProfileController>();
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
          text: riderProfileController.riderData.value.telephone),
      'name': TextEditingController(
          text: riderProfileController.riderData.value.name),
      'vehicleRegistration': TextEditingController(
          text: riderProfileController.riderData.value.vehicleRegistration),
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
                          riderProfileController.riderData.value.image;
                      return CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _selectedProfileImage != null
                            ? FileImage(_selectedProfileImage!) as ImageProvider
                            : (imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null),
                        child:
                            (_selectedProfileImage == null && imageUrl.isEmpty)
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
                            _showVehiclePhotoMenu(context);
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
                                    riderProfileController
                                        .riderData.value.vehiclePhoto,
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
                              _showVehiclePhotoMenu(context);
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
                              riderProfileController.resetImageSelection();
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

  void updateProfile() async {
    if (_selectedProfileImage != null) {
      await riderProfileController.uploadSelectedImage(_selectedProfileImage!);
    }
    if (_selectedVehicleImage != null) {
      await riderProfileController.uploadSelectedImage(_selectedVehicleImage!,
          isProfileImage: false);
    }
    setState(() {
      isEditMode = false;
      _selectedProfileImage = null;
      _selectedVehicleImage = null;
    });
  }

  void _showVehiclePhotoMenu(BuildContext context) {
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
                File? selected = await riderProfileController.takePhoto();
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
                File? selected = await riderProfileController.pickImage();
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
                File? selected = await riderProfileController.takePhoto();
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
                File? selected = await riderProfileController.pickImage();
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
