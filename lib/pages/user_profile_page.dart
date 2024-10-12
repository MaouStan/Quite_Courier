import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/user_controller.dart';
import 'dart:io'; // Add this import to handle File

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserController userProfileController2 = Get.find<UserController>();
  Map<String, TextEditingController>? controllers;
  bool isEditMode = false; // Track edit mode
  File? _selectedImage; // Temporary variable to hold selected image

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    controllers = {
      'telephone': TextEditingController(
          text: userProfileController2.userData.value.telephone),
      'name': TextEditingController(
          text: userProfileController2.userData.value.name),
      'gpsMap': TextEditingController(
          text: userProfileController2.userData.value.location.toString()),
      'addressDescription': TextEditingController(
          text: userProfileController2.userData.value.addressDescription),
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
                    child: Obx(() {
                      final imageUrl =
                          userProfileController2.userData.value.profileImageUrl;
                      return CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!) as ImageProvider
                            : (imageUrl != null && imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null),
                        child: (_selectedImage == null &&
                                (imageUrl == null || imageUrl.isEmpty))
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
                  const Text('GPS Map'),
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
                    controller: controllers!['gpsMap'],
                    enabled: isEditMode,
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
                              userProfileController2.resetImageSelection();
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

  void updateProfile() async {
    if (_selectedImage != null) {
      await userProfileController2.uploadSelectedImage(_selectedImage!);
    }
    setState(() {
      isEditMode = false;
      _selectedImage = null;
    });
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
                File? selected = await userProfileController2.takePhoto();
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
                File? selected = await userProfileController2.pickImage();
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
