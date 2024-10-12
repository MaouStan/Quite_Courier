import 'package:latlong2/latlong.dart';

class UserSignUpData {
  late final String? profileImageUrl;
  late final String? telephone;
  late final String? name;
  late final LatLng? location;
  late final String? password;
  late final String? addressDescription;

  UserSignUpData({
    this.profileImageUrl,
    this.telephone,
    this.name,
    this.location,
    this.password,
    this.addressDescription,
  });

  
}
