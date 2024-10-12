import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/services/firebase_service.dart';

class OrderService {
  static Future<List<OrderDataRes>> fetchOrderWithOrderState(
      OrderState orderState) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot orderDoc = await firestore
          .collection('orders')
          .where('state', isEqualTo: orderState.toString())
          .get();

      return orderDoc.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return OrderDataRes.fromJson(data, doc.id);
      }).toList();
    } catch (e) {
      log('Error fetching orders: $e');
      return [];
    }
  }

  static Future<List<OrderDataRes>> fetchOrderWithRiderAndState(
      String riderTelephone, OrderState orderState) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot orderDoc = await firestore
          .collection('orders')
          .where('riderTelephone', isEqualTo: riderTelephone)
          .where('state', isEqualTo: orderState.toString())
          .get();

      return orderDoc.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return OrderDataRes.fromJson(data, doc.id);
      }).toList();
    } catch (e) {
      log('Error fetching orders: $e');
      return [];
    }
  }

  static Future<OrderDataRes?> fetchOrderWithId(String docId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot orderDoc =
          await firestore.collection('orders').doc(docId).get();

      OrderDataRes order =
          OrderDataRes.fromJson(orderDoc.data() as Map<String, dynamic>, docId);

      // fetch profile image getImageUrl with riderTelephone, senderTelephone, receiverTelephone
      order.riderProfileImage = await FirebaseService()
          .getImageUrl('/profile_images/${order.riderTelephone}');
      order.senderProfileImage = await FirebaseService()
          .getImageUrl('/profile_images/${order.senderTelephone}');
      order.receiverProfileImage = await FirebaseService()
          .getImageUrl('/profile_images/${order.receiverTelephone}');

      return order;
    } catch (e) {
      log('Error fetching orders: $e');
      return null;
    }
  }

  static Future<List<OrderDataRes>> getOrdersBySender(
      String senderTelephone) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot orderDoc = await firestore
          .collection('orders')
          .where('senderTelephone', isEqualTo: senderTelephone)
          .get();

      log('Sender orderDoc: ${orderDoc.docs.length}');

      var orders = orderDoc.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return OrderDataRes.fromJson(data, doc.id);
      }).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e) {
      log('Error fetching orders: $e');
      return [];
    }
  }

  static Future<List<OrderDataRes>> getOrdersByReceiver(
      String receiverTelephone) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot orderDoc = await firestore
          .collection('orders')
          .where('receiverTelephone', isEqualTo: receiverTelephone)
          .get();

      var orders = orderDoc.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        log('data: $data');
        return OrderDataRes.fromJson(data, doc.id);
      }).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e) {
      log('Error fetching orders: $e');
      return [];
    }
  }
}
