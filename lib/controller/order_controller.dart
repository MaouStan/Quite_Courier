import 'dart:developer';

import 'package:get/get.dart';

// Add enum for order status
enum OrderStatus { pending, received, inProgress, sent, delivered }

class OrderController extends GetxController {
  // Observable variables for order statistics
  var sentOrders = 0.obs;
  var inProgressOrders = 0.obs;
  var receivedOrders = 0.obs;
  var incomingOrders = 0.obs;

  // Add current status to your existing controller
  var currentStatus = OrderStatus.pending.obs;

  // Sample order data
  var sampleOrders = <Map<String, dynamic>>[].obs;

  @override
void onInit() {
  super.onInit();
  loadSampleData();
  log('onInit called, sampleOrders: ${sampleOrders.length}');
}


  void loadSampleData() {
    sampleOrders.assignAll([
      {
        'id': '1',
        'name': 'Package 1',
        'recipient': 'John Doe',
        'sentDate': DateTime.now().subtract(const Duration(days: 2)),
        'status': OrderStatus.inProgress,
      },
      {
        'id': '2',
        'name': 'Package 2',
        'recipient': 'Jane Smith',
        'sentDate': DateTime.now().subtract(const Duration(days: 1)),
        'status': OrderStatus.received,
      },
      {
        'id': '3',
        'name': 'Package 3',
        'recipient': 'Bob Johnson',
        'sentDate': DateTime.now(),
        'status': OrderStatus.pending,
      },
    ]);
    log('Sample data loaded: ${sampleOrders.length} orders');
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    int index = sampleOrders.indexWhere((order) => order['id'] == orderId);
    if (index != -1) {
      sampleOrders[index]['status'] = newStatus;
      log('Order $orderId status updated to ${newStatus.toString()}');
    }
  }

  void calculateOrderStats() {
    sentOrders.value = sampleOrders
        .where((order) => order['status'] == OrderStatus.sent)
        .length;
    inProgressOrders.value = sampleOrders
        .where((order) => order['status'] == OrderStatus.inProgress)
        .length;
    receivedOrders.value = sampleOrders
        .where((order) => order['status'] == OrderStatus.received)
        .length;
    incomingOrders.value = sampleOrders
        .where((order) => order['status'] == OrderStatus.delivered)
        .length;
  }
}
