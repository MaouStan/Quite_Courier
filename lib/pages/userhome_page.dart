import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/order_controller.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/drawer.dart';

class UserhomePage extends StatefulWidget {
  const UserhomePage({super.key});

  @override
  State<UserhomePage> createState() => _UserhomePageState();
}

class _UserhomePageState extends State<UserhomePage> {
  // Initialize the controller
  final OrderController orderController = Get.put(OrderController());

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
                      onPressed: () {},
                      child: Text('มากกว่านี้ >>',
                          style: TextStyle(
                              fontSize: Get.textTheme.bodyLarge!.fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)))
                ],
              ),

              // นี่
              Obx(() {
                log('Building order list. Sample orders: ${orderController.sampleOrders.length}');
                return Column(
                  children: orderController.sampleOrders.map((order) {
                    log('Order details: ${order.toString()}');
                    log('Processing order: ${order['name']}');
                    return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 252, 208, 151),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/logo.png',
                                    width: 120,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('ผู้รับ : ${order['recipient']}'),
                                      Text(
                                          'ส่งเมื่อวันที่ : ${(order['sentDate'] as DateTime).toString().split(' ')[0]}'),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildTimelineItem(
                                    0,
                                    'รอดำเนินการ',
                                    OrderStatus.values
                                        .indexOf(order['status'] as OrderStatus),
                                  ),
                                  _buildLine(
                                    0,
                                    OrderStatus.values
                                        .indexOf(order['status'] as OrderStatus),
                                  ),
                                  _buildTimelineItem(
                                    1,
                                    'รับของแล้ว',
                                    OrderStatus.values
                                        .indexOf(order['status'] as OrderStatus),
                                  ),
                                  _buildLine(
                                    1,
                                    OrderStatus.values
                                        .indexOf(order['status'] as OrderStatus),
                                  ),
                                  _buildTimelineItem(
                                    2,
                                    'กำลังจัดส่ง',
                                    OrderStatus.values
                                        .indexOf(order['status'] as OrderStatus),
                                  ),
                                  _buildLine(
                                    2,
                                    OrderStatus.values
                                        .indexOf(order['status'] as OrderStatus),
                                  ),
                                  _buildTimelineItem(
                                    3,
                                    'จัดส่งแล้ว',
                                    OrderStatus.values
                                        .indexOf(order['status'] as OrderStatus),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  'สถานะ: ${(order['status'] as OrderStatus).toString().split('.').last}'),
                            ],
                          ),
                        ),
                        );
                  }).toList(),
                );
              }),
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('สิ่งของที่คุณต้องรับ :',
                      style: TextStyle(
                          fontSize: Get.textTheme.bodyLarge!.fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  TextButton(
                      onPressed: () {},
                      child: Text('มากกว่านี้ >>',
                          style: TextStyle(
                              fontSize: Get.textTheme.bodyLarge!.fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)))
                ],
              ),
            ],
            
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

  Widget _buildTimelineItem(int index, String label, int currentIndex) {
    bool isActive = currentIndex >= index;
    bool isCurrent = currentIndex == index;

    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.green : Colors.grey[300],
        border: isCurrent ? Border.all(color: Colors.green, width: 3) : null,
      ),
    );
  }

  Widget _buildLine(int index, int currentIndex) {
    bool isActive = currentIndex > index;

    return Expanded(
      child: Container(
        height: 3,
        color: isActive ? Colors.green : Colors.grey[300],
      ),
    );
  }

  String getStatusLabel(int index) {
    switch (index) {
      case 0:
        return 'รอดำเนินการ';
      case 1:
        return 'รับของแล้ว';
      case 2:
        return 'กำลังจัดส่ง';
      case 3:
        return 'จัดส่งแล้ว';
      default:
        return '';
    }
  }
}
