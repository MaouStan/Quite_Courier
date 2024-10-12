import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/models/order_data.dart';
import 'package:quite_courier/models/rider_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; // {{ edit_1 }} Add Firestore import

enum RiderOrderState {
  waitGetOrder,
  sendingOrder
} // {{ edit_1 }} Add enum for order state

class RiderController extends GetxController {
  final riderData = RiderData(
    profileImageUrl: '',
    telephone: '',
    name: '',
    vehicleImage: '',
    vehicleRegistration: '',
    location: const LatLng(0, 0),
  ).obs;

  var currentState = RiderOrderState.waitGetOrder.obs;
  var currentOrder = OrderData().obs;

  // ignore: unused_field
  File? _tempProfileImage; // Temporary storage for profile image
  // ignore: unused_field
  File? _tempVehicleImage; // Temporary storage for vehicle image

  // {{ edit_3 }} Choose image without uploading
  Future<File?> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
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

  // {{ edit_5 }} Reset temporary image selection
  void resetImageSelection() {
    _tempProfileImage = null;
    _tempVehicleImage = null;
  }

  // {{ edit_6 }} Initialize rider data from Firestore or other source
  @override
  void onInit() {
    super.onInit();
    fetchRiderData();
  }

  Future<void> fetchRiderData() async {
    return;
    // ignore: dead_code
    try {
      // Replace with your Firestore collection and document structure
      String telephone = 'user_telephone'; // Replace with actual telephone
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('riders')
          .doc(telephone)
          .get();

      if (doc.exists) {
        riderData.value = RiderData(
          profileImageUrl: doc['profileImageUrl'] ?? '',
          location: LatLng(doc['location']['latitude'],
              doc['location']['longitude']),
          telephone: doc['telephone'] ?? '',
          name: doc['name'] ?? '',
          vehicleImage: doc['vehicleImage'] ?? '',
          vehicleRegistration: doc['vehicleRegistration'] ?? '',
        );
      }
    } catch (e) {
      print('Error fetching rider data: $e');
    }
  }

  // {{ edit_7 }} Methods to switch order states
  void switchToSendingOrder() {
    currentState.value = RiderOrderState.sendingOrder;
  }

  void switchToWaitGetOrder() {
    currentState.value = RiderOrderState.waitGetOrder;
  }

  // ... Add other necessary methods, such as updating rider information
}
