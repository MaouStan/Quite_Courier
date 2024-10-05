import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/pages/signup_page.dart';

class RolePage extends StatefulWidget {
  const RolePage({super.key});

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  // นำทางไปยังหน้า SignUpPage
                  Get.to(
                    () => const SignUpPage(role: 'Rider'),
                    transition: Transition.noTransition
                  );
                },
                child: _buildUserTypeContainer(
                  title: 'Rider',
                  imagePath:
                      'assets/images/rider.png', // Replace with your image path
                  color: const Color(0xFF6D6AF4).withOpacity(0.69),
                  fontcolor: const Color(0xFF6154F5),
                ),
              ),

              const SizedBox(height: 30), // Space between the containers
              GestureDetector(
                onTap: () {
                  // นำทางไปยังหน้า SignUpPage
                  Get.to(
                    () => const SignUpPage(role: 'General User'),
                    transition: Transition.noTransition
                  );
                },
                child: _buildUserTypeContainer(
                    title: 'General User',
                    imagePath:
                        'assets/images/general_user.png', // Replace with your image path
                    color: const Color(0xFFCAEDFD),
                    fontcolor: const Color(0xFF04B0FF)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeContainer(
      {required String title,
      required String imagePath,
      required color,
      required fontcolor}) {
    return Container(
      width: 330, // Set container width
      height: 300, // Set container height
      decoration: BoxDecoration(
        color: color, // Background color
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 4), // Shadow position
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath, // Load image
            height: 200, // Set image height
          ),
          Stack(
            children: [
              // Text with stroke
              Text(
                title,
                style: TextStyle(
                  fontSize: Get.textTheme.displaySmall!.fontSize,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 3.0 // Set stroke width
                    ..color = Colors.white, // Stroke color
                ),
              ),
              // Text with fill
              Text(
                title,
                style: TextStyle(
                  fontSize: Get.textTheme.displaySmall!.fontSize,
                  fontWeight: FontWeight.bold,
                  color: fontcolor, // Fill color
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
