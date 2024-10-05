import 'dart:developer';
import 'package:get/get.dart';

enum OrderStatus { pending, received, inProgress, sent }

class OrderController extends GetxController {
  var sentOrders = 0.obs;
  var inProgressOrders = 0.obs;
  var receivedOrders = 0.obs;
  var incomingOrders = 0.obs;

  var currentStatus = OrderStatus.pending.obs;
  var sampleOrders = <Map<String, dynamic>>[].obs;
  var incomingPackages = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSampleData();
    loadIncomingPackages();
    calculateOrderStats();
    log('onInit called, sampleOrders: ${sampleOrders.length}');
  }

  void loadSampleData() {
    sampleOrders.assignAll([
      {
        'id': '1',
        'name': 'Package 1',
        'recipient': 'John Doe',
        'sentDate': DateTime.now().subtract(const Duration(days: 2)),
        'status': OrderStatus.pending,
      },
      {
        'id': '2',
        'name': 'Package 2',
        'recipient': 'Jane Smith',
        'sentDate': DateTime.now().subtract(const Duration(days: 1)),
        'status': OrderStatus.inProgress,
      },
      {
        'id': '3',
        'name': 'Package 3',
        'recipient': 'Bob Johnson',
        'sentDate': DateTime.now(),
        'status': OrderStatus.inProgress,
      },
      {
        'id': '4',
        'name': 'Package 8',
        'recipient': 'John Snow',
        'sentDate': DateTime.now(),
        'status': OrderStatus.sent,
      },
    ]);
    log('Sample data loaded: ${sampleOrders.length} orders');
  }

  void loadIncomingPackages() {
    incomingPackages.assignAll([
      {
        'id': 'IN1',
        'name': 'พัสดุจาก กทม.',
        'sender': 'คุณสมชาย ใจดี',
        'sentDate': DateTime.now().subtract(const Duration(days: 1)),
        'status': OrderStatus.inProgress,
      },
      {
        'id': 'IN2',
        'name': 'เอกสารด่วน',
        'sender': 'บริษัท ABC จำกัด',
        'sentDate': DateTime.now().subtract(const Duration(days: 2)),
        'status': OrderStatus.received,
      },
      {
        'id': 'IN4',
        'name': 'สินค้าออนไลน์',
        'sender': 'ร้านค้าออนไลน์ XYZ',
        'sentDate': DateTime.now(),
        'status': OrderStatus.pending,
      },
      
    ]);
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    int index = sampleOrders.indexWhere((order) => order['id'] == orderId);
    if (index != -1) {
      sampleOrders[index]['status'] = newStatus;
      calculateOrderStats();
      log('Order $orderId status updated to ${newStatus.toString()}');
    }
  }

  void calculateOrderStats() {
    // คำนวณ sentOrders จาก sampleOrders
    sentOrders.value = sampleOrders
        .where((order) => order['status'] == OrderStatus.sent)
        .length;

    // คำนวณผลรวมของ inProgressOrders, receivedOrders, และ pendingOrders จาก sampleOrders
    inProgressOrders.value = sampleOrders
            .where((order) => order['status'] == OrderStatus.inProgress)
            .length +
        sampleOrders
            .where((order) => order['status'] == OrderStatus.received)
            .length +
        sampleOrders
            .where((order) => order['status'] == OrderStatus.pending)
            .length;

    // คำนวณ receivedOrders จาก incomingPackages
    receivedOrders.value = incomingPackages
        .where((package) => package['status'] == OrderStatus.sent)
        .length;

    // คำนวณผลรวมของ inProgress, received, และ pending จาก incomingPackages
    incomingOrders.value = incomingPackages
            .where((package) => package['status'] == OrderStatus.inProgress)
            .length +
        incomingPackages
            .where((package) => package['status'] == OrderStatus.received)
            .length +
        incomingPackages
            .where((package) => package['status'] == OrderStatus.pending)
            .length;
  }
}
