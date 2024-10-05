import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/app.dart';
import 'package:quite_courier/controller/order_controller.dart';
import 'package:quite_courier/controller/rider_profile_controller.dart';
import 'package:quite_courier/controller/user_profile_controller2.dart';
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
  Get.put(UserProfileController2());
  // RiderProfileController
  Get.put(RiderProfileController());

  Get.put(OrderController());

  runApp(const App());
}
