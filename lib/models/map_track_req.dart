import 'package:latlong2/latlong.dart';

class MapTrackReqOrder {
  String riderTelephone;
  LatLng orderPosition;
  LatLng? riderPosition;

  MapTrackReqOrder({
    required this.riderTelephone,
    required this.orderPosition,
    this.riderPosition,
  });
}
