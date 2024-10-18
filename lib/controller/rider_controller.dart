import 'dart:developer';

import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/models/rider_data.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:quite_courier/services/auth_service.dart';
import 'package:quite_courier/services/geolocator_services.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quite_courier/services/firebase_service.dart';

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

  RxInt orderCount = 0.obs;
  StreamSubscription<QuerySnapshot>? _orderCountSubscription;

  var currentState = RiderOrderState.waitGetOrder.obs;
  Rx<OrderDataRes?> currentOrder = Rx<OrderDataRes?>(null);

  // ignore: unused_field
  File? _tempProfileImage; // Temporary storage for profile image
  // ignore: unused_field
  File? _tempVehicleImage; // Temporary storage for vehicle image

  Timer? _locationUpdateTimer;
  final AuthService _authService = AuthService();

  RxBool isWithinRange = false.obs;

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void onInit() {
    super.onInit();
    _startLocationUpdates();
    _startOrderCountStream();
    log('RiderController initialized');
  }

  @override
  void onClose() {
    stopLocationUpdates();
    _stopOrderCountStream();
    super.onClose();
    log('RiderController closed');
  }

  void _startLocationUpdates() {
    LatLng? lastPosition;
    _locationUpdateTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (riderData.value.telephone.isNotEmpty) {
        LatLng position = await GeolocatorServices.getCurrentLocation();
        log('position: ${position.toString()}');

        if (lastPosition == null ||
            Geolocator.distanceBetween(
                    lastPosition!.latitude,
                    lastPosition!.longitude,
                    position.latitude,
                    position.longitude) >
                10) {
          // Only update if moved more than 10 meters
          bool updated = await _authService.updateRiderLocation(
              riderData.value.telephone, position);
          if (updated) {
            riderData.update((val) {
              val?.location = position;
            });
            log('Rider location updated: ${position.latitude}, ${position.longitude}');
            lastPosition = position;
            // Check if within range of the target location
            _checkIfWithinRange(position);
          } else {
            log('Failed to update rider location');
          }
        }
      }
    });
  }

  void _checkIfWithinRange(LatLng currentPosition) {
    if (currentOrder.value != null) {
      LatLng targetLocation = currentOrder.value!.state == OrderState.accepted
          ? currentOrder.value!.senderLocation
          : currentOrder.value!.receiverLocation;

      double distance = GeolocatorServices.calculateDistance(
          currentPosition, targetLocation);
      isWithinRange.value = distance <= 20;
      log('isWithinRange: ${isWithinRange.value}');
    }
  }

  void stopLocationUpdates() {
    if (_locationUpdateTimer != null) {
      _locationUpdateTimer?.cancel();
      _locationUpdateTimer = null;
    }
  }

  Future<bool> uploadSelectedImage(File imageFile, {bool isProfileImage = true}) async {
    try {
      final telephone = riderData.value.telephone;
      final downloadUrl = await _firebaseService.uploadRiderImage(imageFile, telephone, isProfileImage);

      if (downloadUrl != null) {
        // Update local state
        riderData.update((val) {
          if (isProfileImage) {
            val?.profileImageUrl = downloadUrl;
          } else {
            val?.vehicleImage = downloadUrl;
          }
        });
        log('Image uploaded: $downloadUrl');
        return true;
      } else {
        log('Failed to upload image');
        return false;
      }
    } catch (e) {
      log('Error uploading image: $e');
      return false;
    }
  }

  void _startOrderCountStream() {
    if (riderData.value.telephone.isNotEmpty) {
      _orderCountSubscription = FirebaseFirestore.instance
          .collection('orders')
          .where('riderTelephone', isEqualTo: riderData.value.telephone)
          .where('state', isEqualTo: OrderState.completed.toString())
          .snapshots()
          .listen((snapshot) {
        orderCount.value = snapshot.docs.length;
      });
    }
  }

  void _stopOrderCountStream() {
    if (_orderCountSubscription != null) {
      _orderCountSubscription?.cancel();
      _orderCountSubscription = null;
    }
  }

  // Call this method when rider data is updated
  void updateRiderData(RiderData newData) {
    riderData.value = newData;
    _stopOrderCountStream(); // Stop the existing stream
    _startOrderCountStream(); // Start a new stream with the updated telephone
    log(riderData.value.toString());
  }
}
