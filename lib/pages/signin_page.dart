import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

 // Method to validate input fields
  void _validateAndSignIn() {
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
      // Proceed with sign in logic
      Get.to(const SigninPage()); // Replace this with actual sign-in logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_double_arrow_left,
            color: Color(0xFF6F86D6),
            size: 40.0,
          ),
          onPressed: () {
            Navigator.pop(context);
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
    );
  }
}
