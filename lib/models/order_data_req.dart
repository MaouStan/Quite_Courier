import 'package:latlong2/latlong.dart';
import 'package:quite_courier/interfaces/order_state.dart';



class OrderDataReq {
  String riderName;
  String riderTelephone;
  String senderName;
  String senderTelephone;
  String receiverName;
  String receiverTelephone;
  String riderVehicleRegistration;
  String nameOrder;
  String orderPhoto;
  String riderOrderPhoto1;
  String riderOrderPhoto2;
  String description;
  LatLng senderLocation;
  LatLng receiverLocation;
  String senderAddress;
  String receiverAddress;
  OrderState state;
  DateTime createdAt;

  OrderDataReq({
    required this.riderVehicleRegistration,
    required this.riderName,
    required this.riderTelephone,
    required this.senderName,
    required this.senderTelephone,
    required this.receiverName,
    required this.receiverTelephone,
    required this.nameOrder,
    required this.orderPhoto,
    required this.riderOrderPhoto1,
    required this.riderOrderPhoto2,
    required this.description,
    required this.senderLocation,
    required this.receiverLocation,
    required this.senderAddress,
    required this.receiverAddress,
    required this.state,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'OrderData(riderName: $riderName, riderTelephone: $riderTelephone, senderName: $senderName, senderTelephone: $senderTelephone, receiverName: $receiverName, receiverTelephone: $receiverTelephone, nameOrder: $nameOrder, orderPhoto: $orderPhoto, riderOrderPhoto1: $riderOrderPhoto1, riderOrderPhoto2: $riderOrderPhoto2, description: $description, senderLocation: $senderLocation, receiverLocation: $receiverLocation, senderAddress: $senderAddress, receiverAddress: $receiverAddress, state: $state, createdAt: $createdAt)';
  }

  Map<String, dynamic> toJson() => {
        'riderName': riderName,
        'riderTelephone': riderTelephone,
        'senderName': senderName,
        'senderTelephone': senderTelephone,
        'receiverName': receiverName,
        'receiverTelephone': receiverTelephone,
        'riderVehicleRegistration': riderVehicleRegistration,
        'nameOrder': nameOrder,
        'orderPhoto': orderPhoto,
        'riderOrderPhoto1': riderOrderPhoto1,
        'riderOrderPhoto2': riderOrderPhoto2,
        'description': description,
        'senderLocation': {
          'latitude': senderLocation.latitude,
          'longitude': senderLocation.longitude,
        },
        'receiverLocation': {
          'latitude': receiverLocation.latitude,
          'longitude': receiverLocation.longitude,
        },
        'senderAddress': senderAddress,
        'receiverAddress': receiverAddress,
        'state': state.name,
        'createdAt': createdAt.toIso8601String(),
      };
}
