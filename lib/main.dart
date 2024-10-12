import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/app.dart';
import 'package:quite_courier/controller/order_controller.dart';

import 'package:quite_courier/controller/rider_controller.dart';
import 'package:quite_courier/controller/user_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Connnect to FireStore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Controllers
  // UserProfileController2
  Get.put(UserController());
  // RiderController
  Get.put(RiderController());
  // Get.put(OrderController());

  runApp(const App());
}
