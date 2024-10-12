import 'package:latlong2/latlong.dart';

class RiderData {
  String? profileImageUrl;
  String vehicleImage;
  String telephone;
  String name;
  LatLng location;
  String vehicleRegistration;

  RiderData({
    required this.profileImageUrl,
    required this.telephone,
    required this.name,
    required this.vehicleImage,
    required this.vehicleRegistration,
    required this.location,
  });

  factory RiderData.fromJson(Map<String, dynamic> json) {
    return RiderData(
      profileImageUrl: json['profileImageUrl'],
      telephone: json['telephone'],
      name: json['name'],
      vehicleImage: json['vehicleImage'],
      vehicleRegistration: json['vehicleRegistration'],
      location: LatLng(json['location']['latitude'], json['location']['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileImageUrl': profileImageUrl,
      'telephone': telephone,
      'name': name,
      'vehicleImage': vehicleImage,
      'vehicleRegistration': vehicleRegistration,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
    };
  }

  @override
  String toString() {
    return 'RiderData(vehicleImage: $vehicleImage, telephone: $telephone, name: $name, vehicleRegistration: $vehicleRegistration, location: $location)';
  }
}
