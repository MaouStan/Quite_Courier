import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:quite_courier/models/order_data_req.dart';
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

  static Future<List<OrderDataRes>> fetchOrderWithRiderAndState(
      String riderTelephone, OrderState orderState) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot orderDoc = await firestore
          .collection('orders')
          .where('riderTelephone', isEqualTo: riderTelephone)
          .where('state', isEqualTo: orderState.toString())
          .get();

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

  static Future<OrderDataRes?> fetchOrderWithId(String docId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot orderDoc =
          await firestore.collection('orders').doc(docId).get();

      OrderDataRes order =
          OrderDataRes.fromJson(orderDoc.data() as Map<String, dynamic>, docId);

      // fetch profile image getImageUrl with riderTelephone, senderTelephone, receiverTelephone
      order.riderProfileImage = await FirebaseService()
              .getImageUrl('/profile_images/${order.riderTelephone}')
              .catchError((error) => null) ??
          '';
      order.senderProfileImage = await FirebaseService()
              .getImageUrl('/profile_images/${order.senderTelephone}')
              .catchError((error) => null) ??
          '';
      order.receiverProfileImage = await FirebaseService()
              .getImageUrl('/profile_images/${order.receiverTelephone}')
              .catchError((error) => null) ??
          '';

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

  static Future<bool> createOrder(OrderDataReq order, File imageFile) async {
    try {
      // Add order to Firestore first to get the document ID
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('orders')
          .add(order.toJson());
      String docId = docRef.id;

      // Upload image and get URL
      String? imageUrl = await FirebaseService()
          .uploadImage(imageFile, 'order_images/$docId/1');
      if (imageUrl != null) {
        order.orderPhoto = imageUrl;
      } else {
        Get.snackbar('Error', 'Failed to upload image');
        return false;
      }

      // Update the order with the new document ID and image URL
      await docRef.update({
        'documentId': docId,
        'orderPhoto': imageUrl,
      });

      // Initialize empty strings for rider images
      order.riderOrderPhoto1 = '';
      order.riderOrderPhoto2 = '';
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create order');
      return false;
    }
  }

  // Add a new method to update rider images
  static Future<void> updateRiderImages(
      String orderId, File? image1, File? image2) async {
    try {
      String? imageUrl1;
      String? imageUrl2;

      if (image1 != null) {
        imageUrl1 = await FirebaseService()
            .uploadImage(image1, 'order_images/$orderId/2');
      }
      if (image2 != null) {
        imageUrl2 = await FirebaseService()
            .uploadImage(image2, 'order_images/$orderId/3');
      }

      Map<String, dynamic> updateData = {};
      if (imageUrl1 != null) updateData['riderOrderPhoto1'] = imageUrl1;
      if (imageUrl2 != null) updateData['riderOrderPhoto2'] = imageUrl2;

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update(updateData);
    } catch (e) {
      log('Error updating rider images: $e');
      rethrow;
    }
  }

  static Future<bool> updateOrder(OrderDataRes order,
      {File? image1, File? image2, OrderState? newState}) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      Map<String, dynamic> updateData = order.toJson();

      // เพิ่มการอัพเดต state ถ้ามีการระบุ newState
      if (newState != null) {
        updateData['state'] = newState.name; // แปลง enum เป็น string
      }

      if (image1 != null || image2 != null) {
        String? imageUrl1, imageUrl2;
        if (image1 != null) {
          imageUrl1 = await FirebaseService()
              .uploadImage(image1, 'order_images/${order.documentId}/2');
          if (imageUrl1 != null) updateData['riderOrderPhoto1'] = imageUrl1;
        }
        if (image2 != null) {
          imageUrl2 = await FirebaseService()
              .uploadImage(image2, 'order_images/${order.documentId}/3');
          if (imageUrl2 != null) updateData['riderOrderPhoto2'] = imageUrl2;
        }
      }

      await firestore
          .collection('orders')
          .doc(order.documentId)
          .update(updateData);

      // อัพเดต state ใน local object ด้วย
      if (newState != null) {
        order.state = newState;
        log('Sussesses');
      }
      return true;
    } catch (e) {
      log('Error updating order state: $e');
      return false;
    }
  }
static Stream<OrderDataRes> streamOrderDetails(String orderId) {
  try {
    return FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .asyncMap((orderSnapshot) async {
      // เพิ่ม log เพื่อดีบัก
      log("Fetching order details for ID: $orderId");
      
      if (!orderSnapshot.exists) {
        log("Order not found: $orderId");
        throw Exception('Order not found');
      }

      Map<String, dynamic> orderData = orderSnapshot.data() as Map<String, dynamic>;

      // ตรวจสอบค่าว่างของเบอร์โทรศัพท์
      String riderTelephone = orderData['riderTelephone'] ?? '';
      String senderTelephone = orderData['senderTelephone'] ?? '';
      String receiverTelephone = orderData['receiverTelephone'] ?? '';

      log("Fetching profile images for - Rider: $riderTelephone, Sender: $senderTelephone, Receiver: $receiverTelephone");

      // ใช้ Future.wait เพื่อดึงข้อมูลรูปพร้อมกัน
      final List<String> profileImages = await Future.wait([
        _fetchUserProfileImage('riders', riderTelephone),
        _fetchUserProfileImage('users', senderTelephone),
        _fetchUserProfileImage('users', receiverTelephone),
      ]);

      // สร้าง OrderDataRes object
      final orderDataRes = OrderDataRes.fromJson(orderData, orderId);
      orderDataRes.riderProfileImage = profileImages[0];
      orderDataRes.senderProfileImage = profileImages[1];
      orderDataRes.receiverProfileImage = profileImages[2];

      log("Successfully created OrderDataRes object");
      return orderDataRes;
    }).handleError((error) {
      log("Error in streamOrderDetails: $error");
      throw error;
    });
  } catch (e) {
    log("Unexpected error in streamOrderDetails: $e");
    rethrow;
  }
}

static Future<String> _fetchUserProfileImage(String collection, String telephone) async {
  try {
    if (telephone.isEmpty) {
      log("Empty telephone number for collection: $collection");
      return '';
    }

    final snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .doc(telephone)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      log("No profile found for $telephone in $collection");
      return '';
    }

    final profileImageUrl = (snapshot.data() as Map<String, dynamic>)['profileImageUrl'] ?? '';
    log("Retrieved profile image for $telephone: $profileImageUrl");
    return profileImageUrl;
    
  } catch (e) {
    log("Error fetching profile image for $telephone in $collection: $e");
    return ''; // คืนค่าว่างในกรณีที่เกิดข้อผิดพลาด
  }
}
}
