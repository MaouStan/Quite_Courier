import 'package:get/get.dart';
import 'package:quite_courier/models/user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; // {{ edit_7 }} Add Firestore import

class UserProfileController2 extends GetxController {
  final userData = UserData(
    image: '123',
    telephone: '123',
    name: '123',
    gpsMap: '123',
    addressDescription: '123',
  ).obs;

  // ignore: unused_field
  File? _temporaryImage; // {{ edit_8 }} Temporary storage for selected image

  // Method to take a photo using the camera
  Future<File?> takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Method to pick an image from the gallery
  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // {{ edit_2 }} Upload the selected image upon confirmation
  Future<void> uploadSelectedImage(File imageFile) async {
    try {
      final telephone = userData.value.telephone;
      final fileExtension = imageFile.path.split('.').last;
      final fileName = '$telephone.$fileExtension';
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_images/$fileName');

      // Upload the file to Firebase Storage
      await storageRef.putFile(imageFile);

      // Get the download URL
      final downloadUrl = await storageRef.getDownloadURL();

      // Update Firestore with the new image URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(telephone)
          .update({'image': downloadUrl});

      // Update local state
      userData.update((val) {
        val?.image = downloadUrl;
      });
    } catch (e) {
      // Handle errors appropriately in production
      print('Error uploading image: $e');
    }
  }

  // {{ edit_3 }} Reset temporary image selection
  void resetImageSelection() {
    _temporaryImage = null;
  }

  // ... existing methods ...
}
