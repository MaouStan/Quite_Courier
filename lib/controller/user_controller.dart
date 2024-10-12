import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/models/user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; // {{ edit_7 }} Add Firestore import

class UserController extends GetxController {
  final userData = UserData(
    profileImageUrl: '',
    telephone: '',
    name: '',
    location: const LatLng(0, 0),
    addressDescription: '',
  ).obs;
}
