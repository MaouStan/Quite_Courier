import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/order_controller.dart';
import 'package:quite_courier/controller/user_controller.dart';
import 'package:quite_courier/interfaces/order_people.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/pages/reciever_list_view_page.dart';
import 'package:quite_courier/pages/sender_list_view_page.dart';
import 'package:quite_courier/pages/user_send_order.dart';
import 'package:quite_courier/services/order_service.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/drawer.dart';
import 'package:quite_courier/widget/listview.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final OrderController orderController = Get.find<OrderController>();
  final UserController userController = Get.find<UserController>();

  Future<Map<String, List<OrderDataRes>>> fetchOrders() async {
    try {
      final sentOrders = await OrderService.getOrdersBySender(
          userController.userData.value.telephone);
      final receivedOrders = await OrderService.getOrdersByReceiver(
          userController.userData.value.telephone);

      return {
        'sentOrders': sentOrders,
        'receivedOrders': receivedOrders,
      };
    } catch (e) {
      print('Error fetching orders: $e');
      return {
        'sentOrders': [],
        'receivedOrders': [],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const MyDrawer(),
      body: FutureBuilder<Map<String, List<OrderDataRes>>>(
        future: fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final sentOrders = snapshot.data!['sentOrders']!;
          final receivedOrders = snapshot.data!['receivedOrders']!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildUserInfoCard(sentOrders, receivedOrders),
                    const SizedBox(height: 12),
                    _buildSentOrdersSection(sentOrders),
                    _buildReceivedOrdersSection(receivedOrders),
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
            log("กดปุ่ม +");
            Get.to(() => const UserSendOrder());
          },
          backgroundColor: const Color(0xFFE2E0E0),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 50),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(List<OrderDataRes> sentOrders, List<OrderDataRes> receivedOrders) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE2),
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
                    userController.userData.value.profileImageUrl),
              ),
              const SizedBox(width: 12),
              Text(
                userController.userData.value.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('จัดส่งแล้ว', sentOrders.length),
              _buildStatItem(
                  'กำลังส่ง',
                  sentOrders
                      .where((order) =>
                          order.state != OrderState.pending)
                      .length),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  'รับของแล้ว', receivedOrders.length),
              _buildStatItem(
                  'ของกำลังมาส่ง',
                  receivedOrders
                      .where((order) =>
                          order.state != OrderState.pending)
                      .length),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentOrdersSection(List<OrderDataRes> sentOrders) {
    return Column(
      children: [
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
                  Get.to(() => const SenderListViewPage());
                },
                child: Text('มากกว่านี้ >>',
                    style: TextStyle(
                        fontSize: Get.textTheme.bodyLarge!.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)))
          ],
        ),
        OrderListView(useIncomingData: false, orders: sentOrders, limit: 3),
      ],
    );
  }

  Widget _buildReceivedOrdersSection(List<OrderDataRes> receivedOrders) {
    return Column(
      children: [
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
                  Get.to(() => const RecieverListViewPage());
                },
                child: Text('มากกว่านี้ >>',
                    style: TextStyle(
                        fontSize: Get.textTheme.bodyLarge!.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)))
          ],
        ),
        OrderListView(useIncomingData: true, orders: receivedOrders, limit: 3),
      ],
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
