import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:quite_courier/controller/order_controller.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/drawer.dart';
import 'package:quite_courier/widget/listview.dart';

class RecieverListViewPage extends StatefulWidget {
  const RecieverListViewPage({super.key});

  @override
  State<RecieverListViewPage> createState() => _RecieverListViewPageState();
}

class _RecieverListViewPageState extends State<RecieverListViewPage> {
  late OrderController orderController;

  @override
  void initState() {
    super.initState();
    orderController = Get.find<OrderController>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(location: '9999, 9999'),
      drawer: const MyDrawer(),
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
                                'จัดส่งแล้ว', orderController.receivedOrders.value),
                            _buildStatItem('กำลังส่ง',
                                orderController.incomingOrders.value),
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
                SizedBox(height: 8),
                OrderListView(useIncomingData: true,),
              ],
            ),
          ),
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
