import 'dart:developer' as dev;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class FirebaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseService() {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Future<String?> getImageUrl(String path) async {
    try {
      String downloadURL = await _storage.ref(path).getDownloadURL();
      return downloadURL;
    } catch (e) {
      dev.log("Error getting image URL: $e");
      return null;
    }
  }

  Future<String?> uploadImage(File file, String path) async {
    try {
      TaskSnapshot snapshot = await _storage.ref(path).putFile(file);
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      dev.log("Error uploading image: $e");
      return null;
    }
  }

  Future<String?> uploadRiderImage(File file, String telephone, bool isProfileImage) async {
    try {
      final fileExtension = file.path.split('.').last;
      final fileName = '$telephone-${isProfileImage ? 'profile' : 'vehicle'}.$fileExtension';
      final path = 'rider_images/$fileName';

      TaskSnapshot snapshot = await _storage.ref(path).putFile(file);
      String downloadURL = await snapshot.ref.getDownloadURL();

      // Update Firestore
      await _firestore.collection('riders').doc(telephone).update({
        isProfileImage ? 'image' : 'vehicleImage': downloadURL
      });

      return downloadURL;
    } catch (e) {
      dev.log("Error uploading rider image: $e");
      return null;
    }
  }
}
