import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/order_controller.dart';
import 'package:quite_courier/pages/sender_order_detail.dart';
import 'package:quite_courier/pages/user_send_order.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/drawer.dart';
import 'package:quite_courier/widget/listview.dart';

class SenderListViewPage extends StatefulWidget {
  const SenderListViewPage({super.key});

  @override
  State<SenderListViewPage> createState() => _SenderListViewPageState();
}

class _SenderListViewPageState extends State<SenderListViewPage> {
  late OrderController orderController;

  @override
  void initState() {
    super.initState();
    orderController = Get.find<OrderController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Obx(() => Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFF0EAE2),
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                                'จัดส่งแล้ว', orderController.sentOrders.value),
                            _buildStatItem('กำลังส่ง',
                                orderController.inProgressOrders.value),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('สิ่งที่คุณส่ง :'),
                  ],
                ),
                const SizedBox(height: 8),
                OrderListView(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {
            Get.to(() => UserSendOrder());
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
