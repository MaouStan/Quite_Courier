import 'package:latlong2/latlong.dart';
import 'package:quite_courier/interfaces/order_state.dart';

class OrderDataRes {
  String documentId; // Added Firestore document ID
  String riderName;
  String riderTelephone;
  String riderVehicleRegistration;
  String? riderProfileImage;
  String senderName;
  String senderTelephone;
  String? senderProfileImage;
  String receiverName;
  String receiverTelephone;
  String? receiverProfileImage;
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

  OrderDataRes({
    required this.documentId, // Added to constructor
    required this.riderName,
    required this.riderTelephone,
    required this.riderVehicleRegistration,
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
    this.riderProfileImage,
    this.senderProfileImage,
    this.receiverProfileImage,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'OrderData(documentId: $documentId, riderName: $riderName, riderTelephone: $riderTelephone, riderVehicleRegistration: $riderVehicleRegistration, senderName: $senderName, senderTelephone: $senderTelephone, receiverName: $receiverName, receiverTelephone: $receiverTelephone, nameOrder: $nameOrder, orderPhoto: $orderPhoto, riderOrderPhoto1: $riderOrderPhoto1, riderOrderPhoto2: $riderOrderPhoto2, description: $description, senderLocation: $senderLocation, receiverLocation: $receiverLocation, senderAddress: $senderAddress, receiverAddress: $receiverAddress, state: $state, createdAt: $createdAt)';
  }

  Map<String, dynamic> toJson() => {
        'documentId': documentId, // Added to toJson
        'riderName': riderName,
        'riderTelephone': riderTelephone,
        'riderVehicleRegistration': riderVehicleRegistration,
        'senderName': senderName,
        'senderTelephone': senderTelephone,
        'receiverName': receiverName,
        'receiverTelephone': receiverTelephone,
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

  static OrderDataRes fromJson(Map<String, dynamic> json, String docId) =>
      OrderDataRes(
        documentId: docId,
        riderName: json['riderName'],
        riderTelephone: json['riderTelephone'],
        senderName: json['senderName'],
        senderTelephone: json['senderTelephone'],
        riderVehicleRegistration: json['riderVehicleRegistration'],
        receiverName: json['receiverName'],
        receiverTelephone: json['receiverTelephone'],
        nameOrder: json['nameOrder'],
        orderPhoto: json['orderPhoto'],
        riderOrderPhoto1: json['riderOrderPhoto1'],
        riderOrderPhoto2: json['riderOrderPhoto2'],
        description: json['description'],
        senderAddress: json['senderAddress'],
        receiverAddress: json['receiverAddress'],
        state: OrderState.fromJson(json['state']),
        senderLocation: LatLng(
          json['senderLocation']?['latitude'] ?? 0.0,
          json['senderLocation']?['longitude'] ?? 0.0,
        ),
        receiverLocation: LatLng(
          json['receiverLocation']?['latitude'] ?? 0.0,
          json['receiverLocation']?['longitude'] ?? 0.0,
        ),
        createdAt: DateTime.parse(json['createdAt']),
      );
}
