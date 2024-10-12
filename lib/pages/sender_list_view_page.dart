import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/user_controller.dart';
import 'package:quite_courier/interfaces/order_people.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/pages/map_page.dart';
import 'package:quite_courier/pages/user_send_order.dart';
import 'package:quite_courier/services/order_service.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/drawer.dart';
import 'package:quite_courier/widget/listview.dart';

class SenderListViewPage extends StatefulWidget {
  const SenderListViewPage({super.key});

  @override
  State<SenderListViewPage> createState() => _SenderListViewPageState();
}

class _SenderListViewPageState extends State<SenderListViewPage> {
  final UserController userController = Get.find<UserController>();

  Future<List<OrderDataRes>> fetchSentOrders() async {
    try {
      final orders = await OrderService.getOrdersBySender(
          userController.userData.value.telephone);

      return orders;
    } catch (e) {
      log('Error fetching sent orders: $e');
      return []; // Return an empty list in case of error
    }
  }

  @override
  void initState() {
    super.initState();
    // fetchSentOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const MyDrawer(),
      body: FutureBuilder<List<OrderDataRes>>(
        future: fetchSentOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final sentOrders = snapshot.data!;
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0EAE2),
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('จัดส่งแล้ว', sentOrders.length),
                            _buildStatItem(
                                'กำลังส่ง',
                                sentOrders
                                    .where((order) =>
                                        order.state != OrderState.completed)
                                    .length),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('สิ่งที่คุณส่ง :'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                        onPressed: () {
                          Get.to(() => MapPage(
                                mode: MapMode.tracks,
                                riderTelephones: sentOrders
                                    .where((order) => order.riderTelephone != null && (order.state == OrderState.accepted || order.state == OrderState.onDelivery))
                                    .map((order) => order.riderTelephone!)
                                    .toSet().toList(),
                              ));
                        },
                        child: const Text('Track All')),
                    const SizedBox(height: 8),
                    OrderListView(useIncomingData: false, orders: sentOrders),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {
            Get.to(() => const UserSendOrder());
          },
          backgroundColor: const Color(0xFFE2E0E0),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 50),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: Get.textTheme.titleMedium!.fontSize,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 20),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
