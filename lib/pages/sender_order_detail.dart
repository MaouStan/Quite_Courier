
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/order_controller.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/detail.dart';
import 'package:quite_courier/widget/drawer.dart';

class SenderOrderDetail extends StatefulWidget {
  final String orderId; // Define orderId as a required parameter.

  const SenderOrderDetail({required this.orderId, super.key});

  @override
  State<SenderOrderDetail> createState() => _SenderOrderDetailState();
}

class _SenderOrderDetailState extends State<SenderOrderDetail> {
  final OrderController orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    final order = orderController.sampleOrders
        .firstWhere((o) => o['id'] == widget.orderId);
    int currentStep = order['status'].index; // กำหนดค่าเริ่มต้นตามที่คุณต้องการ

     return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const MyDrawer(),
      body: OrderDetailContent(order: order, currentStep: currentStep, userType: UserType.user,),
    );
  }
}
