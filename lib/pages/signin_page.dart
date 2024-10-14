import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/controller/rider_controller.dart';
import 'package:quite_courier/controller/user_controller.dart';
import 'package:quite_courier/models/rider_data.dart';
import 'package:quite_courier/models/user_data.dart';
import 'package:quite_courier/pages/loading_page.dart';
import 'package:quite_courier/pages/rider_home_page.dart';
import 'package:quite_courier/pages/user_home_page.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  bool _obscureText = true; // To toggle password visibility

  // Controllers for TextFields
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Method to validate input fields and sign in with Firebase
  Future<void> _validateAndSignIn() async {
    String telephone = _telephoneController.text.trim(); // Trim whitespace
    String password = _passwordController.text;

    // Regular expression for validating telephone number (digits only)
    RegExp telephoneRegExp = RegExp(r'^[0-9]+$');

    // Check if any field is empty
    if (telephone.isEmpty || password.isEmpty) {
      String errorMessage = '';
      if (telephone.isEmpty) errorMessage += 'Please enter your Telephone.\n';
      if (password.isEmpty) errorMessage += 'Please enter your Password.\n';

      // Show alert with error message
      Get.snackbar(
        'Incomplete Information',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else if (!telephoneRegExp.hasMatch(telephone)) {
      // Check if telephone is valid
      Get.snackbar(
        'Invalid Telephone',
        'Please enter a valid telephone number without spaces or letters.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      // Proceed with sign in logic using Firebase
      try {
        var isUser = true;
        // Query Firestore for the user with the matching phone number
        var userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('telephone', isEqualTo: telephone)
            .get();

        if (userQuery.docs.isEmpty) {
          isUser = false;
          userQuery = await FirebaseFirestore.instance
              .collection('riders')
              .where('telephone', isEqualTo: telephone)
              .get();
        }

        if (userQuery.docs.isNotEmpty) {
          var userDoc = userQuery.docs.first;
          var userData = userDoc.data();

          // Check if password matches
          if (userData['password'] == password) {
            log('succesfully');
            log(telephone);

            if (isUser) {
              // Update User Controller to store user data
              Get.find<UserController>().userData.value = UserData(
                profileImageUrl: userData['profileImageUrl'],
                telephone: userData['telephone'],
                name: userData['name'],
                location: LatLng(userData['location']['latitude'],
                    userData['location']['longitude']),
                addressDescription: userData['addressDescription'],
              );
              Get.to(
                () => const UserHomePage(), // Replace this with the target page
                transition: Transition.noTransition,
              );
              log(Get.find<UserController>().userData.value.toString());
            } else {
              Get.find<RiderController>().riderData.value = RiderData(
                profileImageUrl: userData['profileImageUrl'],
                name: userData['name'],
                telephone: userData['telephone'],
                vehicleImage: userData['vehicleImage'],
                vehicleRegistration: userData['vehicleRegistration'],
                location: LatLng(userData['location']['latitude'],
                    userData['location']['longitude']),
              );
              Get.to(
                () =>
                    const RiderHomePage(), // Replace this with the target page
              );
              log(Get.find<RiderController>().riderData.value.toString());
            }
          } else {
            // Password incorrect
            Get.snackbar(
              'Incorrect Password',
              'The password you entered is incorrect.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
          }
        } else {
          // User not found
          Get.snackbar(
            'User Not Found',
            'No user found with this telephone number.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } catch (e) {
        // Handle errors
        Get.snackbar(
          'Error',
          'An error occurred while signing in. Please try again. $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.keyboard_double_arrow_left,
              color: Color(0xFF6F86D6),
              size: 40.0,
            ),
            onPressed: () {
              Get.offAll(() => const LoadingPage());
            },
          ),
          title: const Text('Back',
              style: TextStyle(
                color: Color(0xFF6F86D6),
                fontWeight: FontWeight.bold,
              )),
          backgroundColor: Colors.white, // Optional: AppBar background color
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'QuiteCourier',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Get.textTheme.displayMedium!.fontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff202442)),
                ),
                Image.asset('assets/images/logo.png'),
                Text(
                  'Sign in',
                  style: TextStyle(
                      fontSize: Get.textTheme.displaySmall!.fontSize,
                      color: const Color(0xFF665DF4)),
                ),
                const SizedBox(height: 10),
      
                // Telephone field
                Padding(
                  padding: const EdgeInsets.all(12.0),
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
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
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
      
                      // Password field
                      Text(
                        "Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Get.textTheme.titleMedium!.fontSize,
                        ),
                      ),
      
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
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText =
                                    !_obscureText; // Toggle password visibility
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
      
                // Sign In button
                ElevatedButton(
                  onPressed: () {
                    // Navigate to another page using Get
                    _validateAndSignIn();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E97FD),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(230, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: Get.textTheme.titleLarge!.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
