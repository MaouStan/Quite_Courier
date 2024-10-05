import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/order_controller.dart';
import 'package:quite_courier/pages/reciever_list_view_page.dart';
import 'package:quite_courier/pages/sender_list_view_page.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/drawer.dart';
import 'package:quite_courier/widget/listview.dart';

class UserhomePage extends StatefulWidget {
  const UserhomePage({super.key});

  @override
  State<UserhomePage> createState() => _UserhomePageState();
}

class _UserhomePageState extends State<UserhomePage> {
  final OrderController orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(location: '9999, 9999'),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EAE2),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage('assets/images/profile.png'),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'name',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                                'จัดส่งแล้ว', orderController.sentOrders.value),
                            _buildStatItem('กำลังส่ง',
                                orderController.inProgressOrders.value),
                          ],
                        )),
                    const SizedBox(height: 8),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('รับของแล้ว',
                                orderController.receivedOrders.value),
                            _buildStatItem('ของกำลังมาส่ง',
                                orderController.incomingOrders.value),
                          ],
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('สิ่งของที่คุณส่ง :',
                      style: TextStyle(
                          fontSize: Get.textTheme.bodyLarge!.fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  TextButton(
                      onPressed: () {
                        Get.to(() => SenderListViewPage());
                      },
                      child: Text('มากกว่านี้ >>',
                          style: TextStyle(
                              fontSize: Get.textTheme.bodyLarge!.fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)))
                ],
              ),
              // Row "สิ่งของที่ส่ง"
              OrderListView(limit: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('สิ่งของที่คุณต้องรับ :',
                      style: TextStyle(
                          fontSize: Get.textTheme.bodyLarge!.fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  TextButton(
                      onPressed: () {
                        Get.to(() => RecieverListViewPage());
                      },
                      child: Text('มากกว่านี้ >>',
                          style: TextStyle(
                              fontSize: Get.textTheme.bodyLarge!.fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)))
                ],
              ),
              // Row "สิ่งของที่คุณต้องรับ"
              OrderListView(useIncomingData: true, limit: 3)
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {
            log("กดปุ่ม +");
          },
          child: const Icon(Icons.add, size: 50),
          backgroundColor: const Color(0xFFE2E0E0),
          shape: const CircleBorder(),
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
              fontSize: Get.textTheme.bodyMedium!.fontSize,
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
