import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/rider_controller.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/pages/rider_order_detail.dart';
import 'package:quite_courier/services/geolocator_services.dart';
import 'package:quite_courier/services/order_service.dart';
import 'package:quite_courier/services/utils.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/drawer.dart';
import 'package:quite_courier/pages/map_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/services/auth_service.dart';

class RiderHomePage extends StatefulWidget {
  const RiderHomePage({super.key});

  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  final RiderController stateController = Get.find<RiderController>();
  RxList<OrderDataRes> pendingOrders = <OrderDataRes>[].obs;
  final AuthService _authService = AuthService();
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      _orderSubscription;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _pendingOrdersSubscription;
  // Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _orderSubscription.cancel();
    _pendingOrdersSubscription.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    var myOrder = await OrderService.fetchOrderWithRiderAndState(
        stateController.riderData.value.telephone, OrderState.accepted);
    stateController.currentOrder.value =
        myOrder.isNotEmpty ? myOrder.first : null;
    stateController.currentState.value = RiderOrderState.sendingOrder;

    if (stateController.currentOrder.value != null) {
      _setupOrderListener(stateController.currentOrder.value!.documentId);
    }

    _setupPendingOrdersListener();

    // // Start periodic polling
    // _timer = Timer.periodic(Duration(seconds: 3), (timer) {
    //   if (stateController.currentOrder.value != null) {
    //     _fetchPendingOrders();
    //   }
    // });
  }

  void _setupOrderListener(String orderId) {
    _orderSubscription = FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final updatedOrder =
            OrderDataRes.fromJson(snapshot.data()!, snapshot.id);
        stateController.currentOrder.value = updatedOrder;
        setState(() {});
      }
    });
  }

  void _setupPendingOrdersListener() {
    _pendingOrdersSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('state', isEqualTo: OrderState.pending.name)
        .snapshots()
        .listen((snapshot) {
      pendingOrders.value = snapshot.docs
          .map((doc) => OrderDataRes.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> _fetchPendingOrders() async {
    try {
      final orders =
          await OrderService.fetchOrderWithOrderState(OrderState.pending);
      pendingOrders.value = orders;
      log('Pending Orders: $pendingOrders');
    } catch (e) {
      log('Error fetching pending orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const CustomAppBar(userType: UserType.rider),
        drawer: const MyDrawer(userType: UserType.rider),
        body: RefreshIndicator(
          onRefresh: _fetchPendingOrders,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() => stateController.currentOrder.value == null
                      ? _buildPendingOrdersSection()
                      : _buildSendingOrderSection()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff6154f5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                    stateController.riderData.value.profileImageUrl ?? ''),
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle the error by setting a placeholder icon
                  return;
                },
              ),
              const SizedBox(width: 12),
              Text(stateController.riderData.value.name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFb0c7fb))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'จัดส่งแล้ว',
                style: TextStyle(fontSize: 18, color: Color(0xFFb0c7fb)),
              ),
              Obx(() => Text(
                    stateController.orderCount.toString(),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFb0c7fb)),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('งานที่สามารถรับได้',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Expanded(
          child: Obx(() => ListView.builder(
                itemCount: pendingOrders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(pendingOrders[index]);
                },
              )),
        ),
      ],
    );
  }

  Widget _buildOrderCard(OrderDataRes order) {
    return GestureDetector(
      onTap: () {
        log(order.documentId.toString());
        Get.to(() => RiderOrderDetail(orderId: order.documentId));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF4b45c2), width: 2),
        ),
        color: const Color(0xFF9195f4),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.nameOrder,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: order.state == OrderState.pending
                          ? const Color(0xFF4CAF50)
                          : Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => order.state == OrderState.pending
                        ? _acceptOrder(order)
                        : _cancelOrder(order),
                    child: Text(
                        order.state == OrderState.pending ? 'รับงาน' : 'ยกเลิก',
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      order.orderPhoto,
                      width: 120,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Return a placeholder or fallback image when the network image fails to load
                        return Container(
                          width: 120,
                          height: 80,
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ผู้รับ: ${order.receiverName}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'ต้นทาง: ${order.senderAddress}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'ปลายทาง: ${order.receiverAddress}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _acceptOrder(OrderDataRes order) {
    Get.defaultDialog(
      title: "ยืนยันการรับงาน",
      middleText: "คุณต้องการรับงานนี้ใช่หรือไม่?",
      textConfirm: "ยืนยัน",
      textCancel: "ยกเลิก",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        order.state = OrderState.accepted;
        order.riderName = stateController.riderData.value.name;
        order.riderTelephone = stateController.riderData.value.telephone;
        order.riderVehicleRegistration =
            stateController.riderData.value.vehicleRegistration;

        bool success = await OrderService.updateOrder(order);
        if (success) {
          stateController.currentOrder.value = order;
          stateController.currentState.value = RiderOrderState.sendingOrder;
          stateController
              .startLocationUpdates(); // Start location updates when accepting an order
          Get.back(); // Close dialog
          setState(() {});
        } else {
          Get.snackbar('Error', 'Failed to accept order. Please try again.');
        }
      },
    );
  }

  void _cancelOrder(OrderDataRes order) {
    Get.defaultDialog(
      title: "ยืนยันการยกเลิกงาน",
      middleText: "คุณต้องการยกเลิกงานนี้ใช่หรือไม่?",
      textConfirm: "ยืนยัน",
      textCancel: "ยกเลิก",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        order.state = OrderState.pending;
        order.riderName = '';
        order.riderTelephone = '';
        order.riderVehicleRegistration = '';
        bool success = await OrderService.updateOrder(order);
        if (success) {
          stateController.currentOrder.value = null;
          stateController.currentState.value = RiderOrderState.waitGetOrder;
          stateController
              .stopLocationUpdates(); // Stop location updates when canceling an order
          Get.back(); // Close dialog
          setState(() {});
        }
      },
    );
  }

  Future<void> _updateOrderState(OrderState newState) async {
    if (stateController.currentOrder.value == null) return;
    Get.dialog(const Center(child: CircularProgressIndicator()));
    File? image1, image2;
    if (newState == OrderState.onDelivery) {
      image1 = await Utils().takePhoto();
    } else if (newState == OrderState.completed) {
      image2 = await Utils().takePhoto();
      stateController
          .stopLocationUpdates(); // Stop location updates when delivery is completed
    }

    if (image1 == null && image2 == null) {
      Get.back();
      return;
    }

    bool success = await OrderService.updateOrder(
        stateController.currentOrder.value!,
        image1: image1,
        image2: image2,
        newState: newState);

    if (success) {
      stateController.currentOrder.value!.state = newState;
      if (newState == OrderState.completed) {
        stateController.currentOrder.value = null;
        stateController.currentState.value = RiderOrderState.waitGetOrder;
        _fetchPendingOrders();
      }
      setState(() {});
    } else {
      Get.snackbar('Error', 'Failed to update order state. Please try again.');
    }
    Get.back();
  }

  Widget _buildSendingOrderSection() {
    log('Sending order: ${stateController.currentOrder.value!.toString()}');
    return FutureBuilder<LatLng>(
      future: GeolocatorServices.getCurrentLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final currentLocation =
            LatLng(snapshot.data!.latitude, snapshot.data!.longitude);
        final targetLocation =
            stateController.currentOrder.value!.state == OrderState.accepted
                ? stateController.currentOrder.value!.senderLocation
                : stateController.currentOrder.value!.receiverLocation;

        final distance = GeolocatorServices.calculateDistance(
            currentLocation, targetLocation);
        final isWithinRange = distance <= 20;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('งานที่กำลังทำ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildOrderCard(stateController.currentOrder.value!),
              const SizedBox(height: 16),
              const Text('สถานะการจัดส่ง',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDeliveryStatus(),
              const SizedBox(height: 16),
              Text(
                stateController.currentOrder.value!.state == OrderState.accepted
                    ? 'สถานที่รับของ' // Show this text if the order is accepted
                    : 'สถานที่ส่งของ', // Show this text if the order is on delivery
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildMapSection(),
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (stateController.currentOrder.value!.state ==
                        OrderState.accepted)
                      ElevatedButton(
                        onPressed: isWithinRange
                            ? () async {
                                // แสดง AlertDialog เพื่อแจ้งเตือนให้ถ่ายรูป
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('เริ่มการจัดส่ง'),
                                      content: const Text(
                                          'โปรดถ่ารูปสินค้าก่อนเริ่มการจัดส่ง'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('ตกลง'),
                                          onPressed: () async {
                                            await _updateOrderState(
                                                OrderState.onDelivery);
                                            // Get.to(() => RiderOrderDetail(
                                            //     orderId: stateController
                                            //         .currentOrder
                                            //         .value!
                                            //         .documentId));
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Start Delivery'),
                      ),
                    if (stateController.currentOrder.value!.state ==
                        OrderState.onDelivery)
                      ElevatedButton(
                        onPressed: isWithinRange
                            ? () {
                                // แสดง dialog แจ้งเตือน
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('แจ้งเตือน'),
                                      content: const Text(
                                          'โปรดถ่ายรูปยืนยันการส่งสินค้า'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // ปิด dialog เมื่อกดปุ่มยกเลิก
                                          },
                                          child: const Text('ยกเลิก'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // ปิด dialog แล้วไปทำการอัปเดตสถานะคำสั่งซื้อ
                                            _updateOrderState(OrderState
                                                .completed); // เปลี่ยนสถานะคำสั่งซื้อ
                                          },
                                          child: const Text('ยืนยัน'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // สีพื้นหลังของปุ่ม
                          foregroundColor: Colors.white, // สีของข้อความบนปุ่ม
                        ),
                        child: const Text('Complete Order'),
                      )
                  ],
                ),
              ),
              if (!isWithinRange)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'You must be within 20 meters of the ${stateController.currentOrder.value!.state == OrderState.accepted ? "pickup" : "delivery"} location to proceed.',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeliveryStatus() {
    return SizedBox(
      height: 120, // Adjust this height as needed
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 40, // Adjust this value to position the lines correctly
            left: 50,
            right: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildConnectingLine(
                  isActive: stateController.currentOrder.value!.state.index >=
                      OrderState.accepted.index,
                ),
                _buildConnectingLine(
                  isActive: stateController.currentOrder.value!.state.index >=
                      OrderState.onDelivery.index,
                ),
                _buildConnectingLine(
                  isActive: stateController.currentOrder.value!.state.index >=
                      OrderState.completed.index,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusItem(
                icon: Icons.directions_bike,
                label: 'รอ Rider\nรับงาน',
                isActive: stateController.currentOrder.value!.state.index >=
                    OrderState.pending.index,
              ),
              _buildStatusItem(
                icon: Icons.event,
                label: 'ไรเดอร์รับงานแล้ว\nกำลังมาเอาของ',
                isActive: stateController.currentOrder.value!.state.index >=
                    OrderState.accepted.index,
              ),
              _buildStatusItem(
                icon: Icons.local_shipping,
                label: 'กำลังจัดส่ง',
                isActive: stateController.currentOrder.value!.state.index >=
                    OrderState.onDelivery.index,
              ),
              _buildStatusItem(
                icon: Icons.check_circle,
                label: 'ส่งแล้ว',
                isActive: stateController.currentOrder.value!.state.index >=
                    OrderState.completed.index,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingLine({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? Colors.purple : Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 5),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isActive ? Colors.purple : Colors.grey[300],
          child: Icon(icon, size: 24, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    LatLng orderPosition;
    if (stateController.currentOrder.value!.state == OrderState.accepted) {
      orderPosition = stateController.currentOrder.value!.senderLocation;
    } else if (stateController.currentOrder.value!.state ==
        OrderState.onDelivery) {
      orderPosition = stateController.currentOrder.value!.receiverLocation;
    } else {
      orderPosition = stateController.currentOrder.value!.receiverLocation;
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => MapPage(
              mode: MapMode.route,
              riderTelephone:
                  stateController.currentOrder.value!.riderTelephone,
              orderPosition: orderPosition,
              focusOnRider: true,
            ));
      },
      child: SizedBox(
        height: 200,
        child: MapPage(
          mode: MapMode.route,
          riderTelephone: stateController.currentOrder.value!.riderTelephone,
          orderPosition: orderPosition,
          focusOnRider: true,
          update: true, // Set this to true for real-time updates
        ),
      ),
    );
  }
}
