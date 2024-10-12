import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/models/rider_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:quite_courier/services/auth_service.dart';
import 'package:quite_courier/services/geolocator_services.dart';

enum RiderOrderState { waitGetOrder, sendingOrder }

class RiderController extends GetxController {
  var riderData = RiderData(
    profileImageUrl: '',
    telephone: '',
    name: '',
    vehicleImage: '',
    vehicleRegistration: '',
    location: const LatLng(0, 0),
  ).obs;

  int orderCount = 0;

  var currentState = RiderOrderState.waitGetOrder.obs;
  Rx<OrderDataRes?> currentOrder = Rx<OrderDataRes?>(null);

  // ignore: unused_field
  File? _tempProfileImage; // Temporary storage for profile image
  // ignore: unused_field
  File? _tempVehicleImage; // Temporary storage for vehicle image

  Timer? _locationUpdateTimer;
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    startLocationUpdates();
  }

  @override
  void onClose() {
    stopLocationUpdates();
    super.onClose();
  }

  void startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      if (riderData.value.telephone.isNotEmpty) {
        LatLng position = await GeolocatorServices.getCurrentLocation();

        bool updated = await _authService.updateRiderLocation(
            riderData.value.telephone, position);

        if (updated) {
          riderData.update((val) {
            val?.location = position;
          });
        }
      }
    });
  }

  void stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  // {{ edit_4 }} Upload the selected image upon confirmation
  Future<void> uploadSelectedImage(File imageFile,
      {bool isProfileImage = true}) async {
    return;
    // ignore: dead_code
    try {
      final telephone = riderData.value.telephone;
      final fileExtension = imageFile.path.split('.').last;
      final fileName =
          '$telephone-${isProfileImage ? 'profile' : 'vehicle'}.$fileExtension';
      final storageRef =
          FirebaseStorage.instance.ref().child('rider_images/$fileName');

      // Upload the file to Firebase Storage
      await storageRef.putFile(imageFile);

      // Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();

      // Update Firestore with the new image URL
      await FirebaseFirestore.instance
          .collection('riders')
          .doc(telephone)
          .update({isProfileImage ? 'image' : 'vehicleImage': downloadUrl});

      // Update local state
      riderData.update((val) {
        if (isProfileImage) {
          val?.vehicleImage = downloadUrl;
        } else {
          val?.vehicleImage = downloadUrl;
        }
      });
    } catch (e) {
      // Handle errors appropriately in production
      print('Error uploading image: $e');
    }
  }
}
