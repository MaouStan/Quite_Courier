import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:quite_courier/pages/role_page.dart';
import 'package:quite_courier/pages/signin_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _horizontalController;
  late AnimationController _verticalController;
  late AnimationController _titleController;
  late Animation<double> _horizontalAnimation;
  late Animation<double> _verticalAnimation;
  late Animation<double> _titleAnimation;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();

    // Initialize horizontal animation
    _horizontalController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _horizontalAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _horizontalController, curve: Curves.easeInOut),
    );

    // Initialize vertical animation
    _verticalController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _verticalAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _verticalController, curve: Curves.easeInOut),
    );

    // Initialize title animation
    _titleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _titleAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );

    // Start animations
    _titleController.forward();
    _horizontalController.forward().then((_) {
      _verticalController.forward();
      Timer(const Duration(milliseconds: 500), () {
        setState(() {
          _showContent = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(builder: (context, constraints) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: constraints.maxWidth,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 100, 8, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // First group: Title
                      FadeTransition(
                        opacity: _titleAnimation,
                        child: Text(
                          'QuiteCourier',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: Get.textTheme.displayMedium!.fontSize,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff202442)),
                        ),
                      ),
                      // Second group: Buttons and details
                      if (_showContent)
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Text.rich(
                                TextSpan(
                                  text:
                                      'Your Reliable Partner for Fast and Secure Deliveries',
                                  style: Get.textTheme.titleLarge
                                      ?.copyWith(color: Colors.grey),
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {
                                Get.to(() => const SigninPage());
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
                                    fontSize:
                                        Get.textTheme.titleLarge!.fontSize,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                Get.to(() => const RolePage());
                              },
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const RadialGradient(
                                    colors: [
                                      Color.fromARGB(255, 252, 230, 171),
                                      Color(0xFFE4BF5F)
                                    ],
                                    radius: 2.0,
                                    center: Alignment.center,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: SizedBox(
                                  width: 230,
                                  height: 60,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                          fontSize: Get
                                              .textTheme.titleLarge!.fontSize,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF422020)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              // Positioned image in the center
              AnimatedBuilder(
                animation: Listenable.merge(
                    [_horizontalAnimation, _verticalAnimation]),
                builder: (context, child) {
                  double horizontalOffset =
                      constraints.maxWidth * (_horizontalAnimation.value - 0.5);
                  double verticalOffset = constraints.maxHeight * 0.25;
                  return Positioned(
                    left: horizontalOffset,
                    top: verticalOffset,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: constraints.maxWidth, // Adjust width
                      fit: BoxFit.fitWidth,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
