import 'package:latlong2/latlong.dart';

class UserData {
  late final String profileImageUrl;
  late final String telephone;
  late final String name;
  late final LatLng location;
  late final String addressDescription;

  UserData({
    required this.profileImageUrl,
    required this.telephone,
    required this.name,
    required this.location,
    required this.addressDescription,
  });

  @override
  String toString() {
    return 'UserData(profileImageUrl: $profileImageUrl, telephone: $telephone, name: $name, location: $location, addressDescription: $addressDescription)';
  }
}
