import 'package:latlong2/latlong.dart';

class UserData {
  late String profileImageUrl;
  late String telephone;
  late String name;
  late LatLng location;
  late String addressDescription;

  UserData({
    required this.profileImageUrl,
    required this.telephone,
    required this.name,
    required this.location,
    required this.addressDescription,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      profileImageUrl: json['profileImageUrl'],
      telephone: json['telephone'],
      name: json['name'],
      location: LatLng(json['location']['latitude'], json['location']['longitude']),
      addressDescription: json['addressDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileImageUrl': profileImageUrl,
      'telephone': telephone,
      'name': name,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'addressDescription': addressDescription,
    };
  }

  @override
  String toString() {
    return 'UserData(profileImageUrl: $profileImageUrl, telephone: $telephone, name: $name, location: $location, addressDescription: $addressDescription)';
  }
}
