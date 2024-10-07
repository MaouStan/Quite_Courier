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
        'image': 'https://mpics.mgronline.com/pics/Images/563000005465501.JPEG',
        'description': 'กล่องเปล่าขนาด  25 x 25 x 25 ซม. ใส่ของวิเศษอะไรก็ได้',
        'sender': 'Mangosteen',
        'sendertelephone': '0000000000',
        'recipient': 'John Doe',
        'telephone': '095789546',
        'gpsMap': '111,111',
        'addressDescription':
            'บ้านเลขที่ XXX จังหวัด YY อำเภอ ZZ รหัสไปรษณี 444444 เสาไฟหลักสุดท้าย',
        'rider': '',
        'riderphone': '',
        'vehicleRegistration': '',
        'sentDate': DateTime.now().subtract(const Duration(days: 2)),
        'status': OrderStatus.pending,
      },
      {
        'id': '2',
        'name': 'Package 2',
        'description': 'กล่องเปล่าขนาด  25 x 25 x 25 ซม. ใส่ของวิเศษอะไรก็ได้',
        'sender': 'Mangosteen',
        'sendertelephone': '0000000000',
        'recipient': 'Jane Smith',
        'telephone': '095789546',
        'gpsMap': '999,999',
        'addressDescription':
            'บ้านเลขที่ XXX จังหวัด YY อำเภอ ZZ รหัสไปรษณี 444444 เสาไฟหลักสุดท้าย',
        'rider': 'Makie go',
        'riderphone': '0666666666',
        'vehicleRegistration': 'กข-127',
        'sentDate': DateTime.now().subtract(const Duration(days: 1)),
        'status': OrderStatus.received,
      },
      {
        'id': '3',
        'name': 'Package 3',
        'description': 'กล่องเปล่าขนาด  25 x 25 x 25 ซม. ใส่ของวิเศษอะไรก็ได้',
        'sender': 'Mangosteen',
        'sendertelephone': '0000000000',
        'recipient': 'Bob Johnson',
        'telephone': '095789546',
        'gpsMap': '888,888',
        'addressDescription':
            'บ้านเลขที่ XXX จังหวัด YY อำเภอ ZZ รหัสไปรษณี 444444 เสาไฟหลักสุดท้าย',
        'rider': 'Makie go',
        'riderphone': '0666666666',
        'vehicleRegistration': 'กข-256',
        'sentDate': DateTime.now(),
        'status': OrderStatus.inProgress,
      },
      {
        'id': '4',
        'name': 'Package 8',
        'description': 'กล่องเปล่าขนาด  25 x 25 x 25 ซม. ใส่ของวิเศษอะไรก็ได้',
        'sender': 'Mangosteen',
        'sendertelephone': '0000000000',
        'recipient': 'John Snow',
        'telephone': '095789546',
        'gpsMap': '666,666',
        'addressDescription':
            'บ้านเลขที่ XXX จังหวัด YY อำเภอ ZZ รหัสไปรษณี 444444 เสาไฟหลักสุดท้าย',
        'rider': 'Makie go',
        'riderphone': '0666666666',
        'vehicleRegistration': 'กข-3556',
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
        'description': 'พัสดุหรือป่าวนะ?',
        'sender': 'คุณสมชาย ใจดี',
        'telephone': '010235468',
        'rider': 'Bubble Bee',
        'riderphone': '0123456889',
        'vehicleRegistration': 'งอง-555',
        'sentDate': DateTime.now().subtract(const Duration(days: 1)),
        'status': OrderStatus.inProgress,
      },
      {
        'id': 'IN2',
        'name': 'เอกสารด่วน',
        'description': 'กล่องเปล่าขนาด  25 x 25 x 25 ซม. ใส่ของวิเศษอะไรก็ได้',
        'sender': 'บริษัท ABC จำกัด',
        'telephone': '010235468',
        'rider': 'Bubble Bee',
        'riderphone': '0123456889',
        'vehicleRegistration': 'งอง-555',
        'sentDate': DateTime.now().subtract(const Duration(days: 2)),
        'status': OrderStatus.received,
      },
      {
        'id': 'IN4',
        'name': 'สินค้าออนไลน์',
        'description': 'เสื้อผ้าสินค่าออนไลน์นำเข้า',
        'sender': 'ร้านค้าออนไลน์ XYZ',
        'telephone': '010235468',
        'rider': 'Bubble Bee',
        'riderphone': '0123456889',
        'vehicleRegistration': 'งอง-555',
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
