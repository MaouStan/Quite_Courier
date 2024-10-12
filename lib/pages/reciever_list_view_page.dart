import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/user_controller.dart';
import 'package:quite_courier/interfaces/order_people.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/services/order_service.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/drawer.dart';
import 'package:quite_courier/widget/listview.dart';

class RecieverListViewPage extends StatefulWidget {
  const RecieverListViewPage({super.key});

  @override
  State<RecieverListViewPage> createState() => _RecieverListViewPageState();
}

class _RecieverListViewPageState extends State<RecieverListViewPage> {
  final UserController userController = Get.find<UserController>();

  Future<List<OrderDataRes>> fetchReceivedOrders() async {
    try {
      final orders = await OrderService.getOrdersByReceiver(
          userController.userData.value.telephone);
      return orders;
    } catch (e) {
      print('Error fetching received orders: $e');
      return []; // Return an empty list in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const MyDrawer(),
      body: FutureBuilder<List<OrderDataRes>>(
        future: fetchReceivedOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final receivedOrders = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
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
                              _buildStatItem('รับของแล้ว', receivedOrders.length),
                              _buildStatItem(
                                  'ของกำลังมาส่ง',
                                  receivedOrders
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
                          Text('สิ่งที่คุณต้องรับ :'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OrderListView(useIncomingData: true, orders: receivedOrders),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
