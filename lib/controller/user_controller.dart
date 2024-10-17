import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/models/user_data.dart';
// {{ edit_7 }} Add Firestore import

class UserController extends GetxController {
  final userData = UserData(
    profileImageUrl: '',
    telephone: '',
    name: '',
    location: const LatLng(0, 0),
    addressDescription: '',
  ).obs;
}
