import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/order_controller.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/services/order_service.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/detail.dart';
import 'package:quite_courier/widget/drawer.dart';

class RiderOrderDetail extends StatefulWidget {
  final String orderId; // Define orderId as a required parameter.

  const RiderOrderDetail({required this.orderId, super.key});

  @override
  State<RiderOrderDetail> createState() => _RiderOrderDetailState();
}

class _RiderOrderDetailState extends State<RiderOrderDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(userType: UserType.rider),
        drawer: const MyDrawer(userType: UserType.rider),
        body: StreamBuilder<OrderDataRes>(
          stream: OrderService.streamOrderDetails(widget.orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Order not found'));
            }

            final order = snapshot.data!;
            return OrderDetailContent(order: order, userType: UserType.rider);
          },
        ));
  }
}
