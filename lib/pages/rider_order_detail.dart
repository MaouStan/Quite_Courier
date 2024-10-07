import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:quite_courier/controller/order_controller.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/detail.dart';
import 'package:quite_courier/widget/drawer.dart';

class RiderOrderDetail extends StatefulWidget {
  final String orderId; // Define orderId as a required parameter.

  const RiderOrderDetail({required this.orderId, Key? key}) : super(key: key);

  @override
  State<RiderOrderDetail> createState() => _RiderOrderDetailState();
}

class _RiderOrderDetailState extends State<RiderOrderDetail> {
  final OrderController orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    final order = orderController.sampleOrders
        .firstWhere((o) => o['id'] == widget.orderId);
    int currentStep = order['status'].index; // กำหนดค่าเริ่มต้นตามที่คุณต้องการ
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: const MyDrawer(),
      body: OrderDetailContent(order: order, currentStep: currentStep, userType: UserType.rider,),
    );
  }
}
