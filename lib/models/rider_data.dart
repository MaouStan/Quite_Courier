import 'package:latlong2/latlong.dart';

class RiderData {
  final String? profileImageUrl;
  late final String vehicleImage;
  final String telephone;
  final String name;
  final LatLng location;
  final String vehicleRegistration;

  RiderData({
    required this.profileImageUrl,
    required this.telephone,
    required this.name,
    required this.vehicleImage,
    required this.vehicleRegistration,
    required this.location,
  });

  @override
  String toString() {
    return 'RiderData(vehicleImage: $vehicleImage, telephone: $telephone, name: $name, vehicleRegistration: $vehicleRegistration, location: $location)';
  }
}
