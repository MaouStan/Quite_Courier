import 'package:get/get.dart';

class UserProfileController extends GetxController {
  final RxString telephone = ''.obs;
  final RxString name = ''.obs;
  final RxString gpsMap = ''.obs;
  final RxString addressDescription = ''.obs;

  // สำหรับรูปโปรไฟล์ (ถ้าต้องการเพิ่ม)
  final RxString profileImageUrl = ''.obs;

  void updateProfile({
    String? newTelephone,
    String? newName,
    String? newGpsMap,
    String? newAddressDescription,
    String? newProfileImageUrl,
  }) {
    if (newTelephone != null) telephone.value = newTelephone;
    if (newName != null) name.value = newName;
    if (newGpsMap != null) gpsMap.value = newGpsMap;
    if (newAddressDescription != null) addressDescription.value = newAddressDescription;
    if (newProfileImageUrl != null) profileImageUrl.value = newProfileImageUrl;
  }

  Future<void> saveProfile() async {
    // TODO: Implement API call to save profile data
    // Example:
    // try {
    //   await apiService.updateUserProfile({
    //     'telephone': telephone.value,
    //     'name': name.value,
    //     'gpsMap': gpsMap.value,
    //     'addressDescription': addressDescription.value,
    //   });
    //   Get.snackbar('Success', 'Profile updated successfully');
    // } catch (e) {
    //   Get.snackbar('Error', 'Failed to update profile');
    // }
  }

  Future<void> loadProfile() async {
    // TODO: Implement API call to load profile data
    // Example:
    // try {
    //   final userData = await apiService.getUserProfile();
    //   updateProfile(
    //     newTelephone: userData['telephone'],
    //     newName: userData['name'],
    //     newGpsMap: userData['gpsMap'],
    //     newAddressDescription: userData['addressDescription'],
    //   );
    // } catch (e) {
    //   Get.snackbar('Error', 'Failed to load profile');
    // }
  }
}