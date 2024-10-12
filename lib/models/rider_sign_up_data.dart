import 'package:latlong2/latlong.dart';

class RiderSignUpData {
  String? profileImageUrl;
  String telephone;
  String name;
  LatLng location;
  String password;
  String? vehicleImage;
  String vehicleRegistration;

  RiderSignUpData({
    this.profileImageUrl,
    required this.telephone,
    required this.name,
    required this.location,
    required this.password,
    this.vehicleImage,
    required this.vehicleRegistration,
  });
}
