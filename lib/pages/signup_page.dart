import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quite_courier/pages/rider_home_page.dart';
import 'package:quite_courier/pages/signin_page.dart';
import 'dart:io';

import 'package:quite_courier/pages/user_home_page.dart';
import 'package:quite_courier/services/user_service.dart';

class SignUpPage extends StatefulWidget {
  final String role;

  const SignUpPage({super.key, required this.role});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addDescripController = TextEditingController();
  String location = '37.421998, -122.084';
  bool _obscureText = true;
  File? _profileImage;
  File? _vehicleImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _getProfileImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        log(_profileImage!.path);
      });
    }
  }

  Future<void> _getVehicleImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _vehicleImage = File(pickedFile.path);
      });
    }
  }

  final UserService _userService = UserService();

  void _register() async {
    try {
      if (!_validateInputs()) {
        return;
      }

      final String telephone = _telephoneController.text.trim();
      final String password = _passwordController.text.trim();
      final String confirmPassword = _confirmPasswordController.text.trim();
      final String name = _nameController.text.trim();
      final String description = _addDescripController.text.trim();

      if (!_validatePasswords(password, confirmPassword)) {
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _userService.registerUser(
        telephone: telephone,
        password: password,
        name: name,
        description: description,
        location: location,
        profileImage: _profileImage,
      );

      Get.back();
      Get.snackbar(
        'Success',
        'User registered successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAll(() => const SigninPage());
    } catch (e) {
      // Close loading dialog if it's showing
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show error message
      Get.snackbar(
        'Error',
        _getErrorMessage(e),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

// Validate all required inputs
  bool _validateInputs() {
    if (_telephoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all required fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Add phone number format validation if needed
    if (!_isValidPhoneNumber(_telephoneController.text.trim())) {
      Get.snackbar(
        'Error',
        'Please enter a valid phone number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

// Validate password and confirmation
  bool _validatePasswords(String password, String confirmPassword) {
    if (password != confirmPassword) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

// Helper method to validate phone number format
  bool _isValidPhoneNumber(String phone) {
    // Add your phone number validation logic here
    // Example: check if it's a valid Thai phone number
    final RegExp phoneRegex = RegExp(r'^0[0-9]{9}$');
    return phoneRegex.hasMatch(phone);
  }

// Convert error to user-friendly message
  String _getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    }
    // Add specific error handling based on your backend responses
    return 'An error occurred during registration. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up - ${widget.role}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                widget.role == 'Rider'
                    ? 'assets/images/rider.png'
                    : 'assets/images/general_user.png',
                width: MediaQuery.of(context).size.width *
                    0.5, // 50% of screen width
                fit: BoxFit.contain,
              ),
              Stack(
                children: [
                  // Text with stroke
                  Text(
                    widget.role,
                    style: TextStyle(
                      fontSize: Get.textTheme.displaySmall!.fontSize,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 5.0 // Set stroke width
                        ..color = const Color.fromARGB(
                            255, 255, 255, 255), // Stroke color
                    ),
                  ),
                  // Text with fill
                  Text(
                    widget.role,
                    style: TextStyle(
                      fontSize: Get.textTheme.displaySmall!.fontSize,
                      fontWeight: FontWeight.bold,
                      color: widget.role == 'Rider'
                          ? const Color(0xFF6154F5)
                          : const Color(0xFF04B0FF), // Fill color
                      shadows: [
                        Shadow(
                          offset: const Offset(3.0, 6.0), // Shadow position
                          blurRadius: 18.0, // How blurry the shadow is
                          color: Colors.black.withOpacity(0.5), // Shadow color
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                tabs: [
                  const Tab(text: 'Authentication'),
                  const Tab(text: 'Personal Data'),
                  Tab(text: widget.role == 'Rider' ? 'Vehicle' : 'Address'),
                ],
                labelColor: Colors.purple,
                indicatorColor: Colors.purple,
                unselectedLabelColor: const Color(0xff5f6368),
              ),
              SizedBox(
                height: 600,
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildAuthenticationTab(),
                    _buildPersonalDataTab(),
                    widget.role == 'Rider'
                        ? _buildVehicleTab()
                        : _buildAddressTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticationTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Telephone",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Get.textTheme.titleMedium!.fontSize,
            ),
          ),
          TextField(
            controller: _telephoneController,
            decoration: InputDecoration(
              hintText: '0999999999',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Password",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Get.textTheme.titleMedium!.fontSize,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              hintText: '***************',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintStyle: TextStyle(color: Colors.grey.shade400),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Confirm Password",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Get.textTheme.titleMedium!.fontSize,
            ),
          ),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              hintText: '***************',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintStyle: TextStyle(color: Colors.grey.shade400),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 55),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _tabController.animateTo(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.role == 'Rider'
                    ? const Color(0xFF8E97FD)
                    : const Color(0xFF84C8E8),
                foregroundColor: Colors.white,
                minimumSize: const Size(230, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                'Next',
                style: TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDataTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _getProfileImage,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Name",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Get.textTheme.titleMedium!.fontSize,
                ),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'MaouStan',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 105),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.role == 'Rider'
                      ? const Color(0xFF8E97FD)
                      : const Color(0xFF84C8E8),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Back',
                  style:
                      TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.role == 'Rider'
                      ? const Color(0xFF8E97FD)
                      : const Color(0xFF84C8E8),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Next',
                  style:
                      TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "GPS Map",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Get.textTheme.titleMedium!.fontSize,
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: 'Longtitude 90.0 , Latitude 999',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Image.asset(
                  'assets/images/google-maps.png',
                  width: 32,
                ),
                onPressed: () {
                  log('open map');
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Address Description",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Get.textTheme.titleMedium!.fontSize,
            ),
          ),
          TextField(
            maxLines: null,
            minLines: 3,
            controller: _addDescripController,
            decoration: InputDecoration(
              hintText: 'บ้านเลขที่ 99 จังหวัด X เสาไฟหลักสุดท้าย',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            ),
          ),
          const SizedBox(height: 105),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF84C8E8),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Back',
                  style:
                      TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  log('Sing up');
                  _register();
                  // Get.to(() => const UserhomePage(),
                  //     transition: Transition.noTransition);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF84C8E8),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Sign Up',
                  style:
                      TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Vehicle Photo",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Get.textTheme.titleMedium!.fontSize,
            ),
          ),
          GestureDetector(
            onTap: _getVehicleImage,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color.fromARGB(255, 226, 225, 225), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _vehicleImage == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car,
                            size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('Tap to add vehicle photo',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_vehicleImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Vehicle Registration",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Get.textTheme.titleMedium!.fontSize,
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: 'กข - 1111',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 65),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E97FD),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Back',
                  style:
                      TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  log('Sing up');
                  Get.to(() => RiderHomePage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E97FD),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Sign Up',
                  style:
                      TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
