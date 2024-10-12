class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}
