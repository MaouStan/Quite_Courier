import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/rider_controller.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/models/order_data.dart';
import 'package:quite_courier/services/order_service.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/drawer.dart';
import 'package:quite_courier/pages/map_page.dart';
import 'package:latlong2/latlong.dart';

class RiderHomePage extends StatefulWidget {
  const RiderHomePage({super.key});

  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  final RiderController stateController = Get.find<RiderController>();
  List<OrderData> orders = [];
  Future<void>? futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = loadOrders();
  }

  Future<void> loadOrders() async {
    orders = await OrderService.fetchAllOrders();
    setState(() {});
    log('Orders: $orders');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(userType: UserType.rider),
      drawer: MyDrawer(userType: UserType.rider),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<void>(
                future: futureOrders,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading orders'));
                  } else {
                    return Obx(() {
                      if (stateController.currentState.value ==
                          RiderOrderState.sendingOrder) {
                        return _buildSendingOrderSection();
                      } else {
                        return _buildAvailableOrdersSection();
                      }
                    });
                  }
                },
              ),
            ),
          ],
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
          const Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/profile.png'),
              ),
              SizedBox(width: 12),
              Text('name',
                  style: TextStyle(
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
              Expanded(child: Container()),
              const Text(
                '100',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFb0c7fb)),
              ),
              Expanded(child: Container()),
              const Text(
                'กำลังจัดส่ง',
                style: TextStyle(fontSize: 18, color: Color(0xFFb0c7fb)),
              ),
              Expanded(child: Container()),
              const Text(
                '1',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFb0c7fb)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('งานที่สามารถรับได้',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(orders[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSendingOrderSection() {
    log('Sending order: ${stateController.currentOrder.value.toString()}');
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('งานที่กำลังทำ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildOrderCard(stateController.currentOrder.value),
          const SizedBox(height: 16),
          const Text('สถานะการจัดส่ง',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildDeliveryStatus(),
          const SizedBox(height: 16),
          const Text('สถานที่รับของ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildMapSection(),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderData order) {
    return Card(
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
                const Text(
                  'กล่องเปล่า',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf7c948),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        // Handle additional action
                      },
                      child: const Text('เพิ่มเติม'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf76c6c),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        // Handle cancel action
                      },
                      child: const Text('ยกเลิก'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.photo_library, size: 50, color: Colors.white),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ผู้รับ: ${order.receiverId}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'ต้นทาง: ${order.senderLocation.latitude},${order.senderLocation.longitude} ${order.senderAddress}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'ปลายทาง: ${order.receiverLocation.latitude},${order.receiverLocation.longitude} ${order.receiverAddress}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryStatus() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          top: -40,
          left: 30,
          right: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildConnectingLine(
                isActive: stateController.currentOrder.value.state.index >=
                    OrderState.accepted.index,
              ),
              _buildConnectingLine(
                isActive: stateController.currentOrder.value.state.index >=
                    OrderState.onDelivery.index,
              ),
              _buildConnectingLine(
                isActive: stateController.currentOrder.value.state.index >=
                    OrderState.completed.index,
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusItem(
              icon: Icons.directions_bike,
              label: 'รอ Rider\nรับงาน',
              isActive: stateController.currentOrder.value.state.index >=
                  OrderState.pending.index,
            ),
            _buildStatusItem(
              icon: Icons.event,
              label: 'ไรเดอร์รับงานแล้วกำลังมาเอาของ',
              isActive: stateController.currentOrder.value.state.index >=
                  OrderState.accepted.index,
            ),
            _buildStatusItem(
              icon: Icons.local_shipping,
              label: 'กำลังจัดส่ง',
              isActive: stateController.currentOrder.value.state.index >=
                  OrderState.onDelivery.index,
            ),
            _buildStatusItem(
              icon: Icons.check_circle,
              label: 'ส่งแล้ว',
              isActive: stateController.currentOrder.value.state.index >=
                  OrderState.completed.index,
            ),
          ],
        ),
      ],
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

  Widget _buildStatusItem(
      {required IconData icon, required String label, required bool isActive}) {
    return SizedBox(
      width: 90,
      height: 109,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isActive ? Colors.purple : Colors.grey[300],
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 4),
            ],
          ),
          const SizedBox(height: 8), // Add spacing between icon and text
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
      ),
    );
  }

  Widget _buildMapSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(
              mode: MapMode.route,
              riderId: stateController.currentOrder.value.riderId,
              orderPosition: LatLng(
                stateController.currentOrder.value.receiverLocation.latitude,
                stateController.currentOrder.value.receiverLocation.longitude,
              ),
              focusOnRider: true,
            ),
          ),
        );
      },
      child: Container(
        height: 200,
        color: Colors.grey[300],
        child: const Center(
          child: Text('Map Placeholder'),
        ),
      ),
    );
  }
}
