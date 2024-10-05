import 'package:latlong2/latlong.dart';

enum OrderState {
  pending,
  accepted,
  onDelivery,
  completed,
  canceled,
}

class OrderData {
  final String riderId;
  final String senderId;
  final String receiverId;
  final String nameOrder;
  final String orderPhoto;
  final String riderOrderPhoto1;
  final String riderOrderPhoto2;
  final String description;
  final LatLng gpsPosition;
  final LatLng senderLocation;
  final LatLng receiverLocation;
  final String senderAddress;
  final String receiverAddress;
  final OrderState state;

  OrderData({
    this.riderId = '',
    this.senderId = '',
    this.receiverId = '',
    this.nameOrder = '',
    this.orderPhoto = '',
    this.riderOrderPhoto1 = '',
    this.riderOrderPhoto2 = '',
    this.description = '',
    this.gpsPosition = const LatLng(0, 0),
    this.senderLocation = const LatLng(0, 0),
    this.receiverLocation = const LatLng(0, 0),
    this.senderAddress = '',
    this.receiverAddress = '',
    this.state = OrderState.pending,
  });

  @override
  String toString() {
    return 'OrderData(senderId: $senderId, receiverId: $receiverId, nameOrder: $nameOrder, orderPhoto: $orderPhoto, riderOrderPhoto1: $riderOrderPhoto1, riderOrderPhoto2: $riderOrderPhoto2, description: $description, gpsPosition: $gpsPosition, senderLocation: $senderLocation, receiverLocation: $receiverLocation, senderAddress: $senderAddress, receiverAddress: $receiverAddress, state: $state)';
  }
}
