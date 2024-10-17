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

  @override
  void onInit() {
    super.onInit();
    startLocationUpdates();
    _startOrderCountStream();
  }

  @override
  void onClose() {
    stopLocationUpdates();
    _stopOrderCountStream();
    super.onClose();
  }

  void startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
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
    _orderCountSubscription?.cancel();
    _orderCountSubscription = null;
  }

  // Call this method when rider data is updated
  void updateRiderData(RiderData newData) {
    riderData.value = newData;
    _stopOrderCountStream(); // Stop the existing stream
    _startOrderCountStream(); // Start a new stream with the updated telephone
  }
}
