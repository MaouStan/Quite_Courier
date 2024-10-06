import 'package:latlong2/latlong.dart';

enum OrderState {
  pending,
  accepted,
  onDelivery,
  completed,
  canceled,
}

class OrderData {
  String riderId;
  String senderId;
  String receiverId;
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

  OrderData({
    this.riderId = '',
    this.senderId = '',
    this.receiverId = '',
    this.nameOrder = '',
    this.orderPhoto = '',
    this.riderOrderPhoto1 = '',
    this.riderOrderPhoto2 = '',
    this.description = '',
    this.senderLocation = const LatLng(0, 0),
    this.receiverLocation = const LatLng(0, 0),
    this.senderAddress = '',
    this.receiverAddress = '',
    this.state = OrderState.pending,
  });

  @override
  String toString() {
    return 'OrderData(senderId: $senderId, receiverId: $receiverId, nameOrder: $nameOrder, orderPhoto: $orderPhoto, riderOrderPhoto1: $riderOrderPhoto1, riderOrderPhoto2: $riderOrderPhoto2, description: $description, senderLocation: $senderLocation, receiverLocation: $receiverLocation, senderAddress: $senderAddress, receiverAddress: $receiverAddress, state: $state)';
  }
}
