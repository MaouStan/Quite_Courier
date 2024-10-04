class RiderData {
  late final String image;
  late final String vehiclePhoto;
  final String telephone;
  final String name;
  final String vehicleRegistration;

  RiderData({
    required this.image,
    required this.telephone,
    required this.name,
    required this.vehiclePhoto,
    required this.vehicleRegistration,
  });

  // You can add methods like fromJson, toJson, etc., if needed
}
