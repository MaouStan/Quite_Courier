import 'package:latlong2/latlong.dart';
import 'package:quite_courier/models/order_data.dart';

class OrderService {
  static Future<List<OrderData>> fetchAllOrders() async {
    try {
      // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      //     .collection('orders')
      //     .get();

      // return querySnapshot.docs.map((doc) {
      //   return Order(
      //     senderId: doc['senderId'],
      //     receiverId: doc['receiverId'],
      //     nameOrder: doc['nameOrder'],
      //     orderPhoto: doc['orderPhoto'],
      //     riderOrderPhoto1: doc['riderOrderPhoto1'],
      //     riderOrderPhoto2: doc['riderOrderPhoto2'],
      //     description: doc['description'],
      //     gpsPosition: LatLng(doc['latitude'], doc['longitude']),
      //   );
      // }).toList();

      // fake example
      return [
        OrderData(
          senderId: '1',
          receiverId: '2',
          nameOrder: 'Order 1',
          orderPhoto: 'order1.jpg',
          riderOrderPhoto1: 'rider1.jpg',
          riderOrderPhoto2: 'rider2.jpg',
          description: 'Description 1',
          senderLocation: const LatLng(16.450743, 103.43796),
          receiverLocation: const LatLng(16.350743, 103.33796),
          senderAddress: 'Address 1',
          receiverAddress: 'Address 2',
          state: OrderState.pending,
        ),
        OrderData(
          senderId: '3',
          receiverId: '4',
          nameOrder: 'Order 2',
          orderPhoto: 'order2.jpg',
          riderOrderPhoto1: 'rider3.jpg',
          riderOrderPhoto2: 'rider4.jpg',
          description: 'Description 2',
          senderLocation: const LatLng(16.150743, 103.13796),
          receiverLocation: const LatLng(16.550743, 103.53796),
          senderAddress: 'Address 3',
          receiverAddress: 'Address 4',
          state: OrderState.pending,
        ),
      ];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }
}
