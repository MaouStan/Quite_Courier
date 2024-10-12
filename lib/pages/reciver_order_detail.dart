import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/services/order_service.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/detail.dart';
import 'package:quite_courier/widget/drawer.dart';

class ReciverOrderDetail extends StatefulWidget {
  final String orderId;

  const ReciverOrderDetail({required this.orderId, super.key});

  @override
  State<ReciverOrderDetail> createState() => _ReciverOrderDetailState();
}

class _ReciverOrderDetailState extends State<ReciverOrderDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const MyDrawer(),
      body: FutureBuilder<OrderDataRes?>(
        future: OrderService.fetchOrderWithId(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Order not found'));
          }

          final order = snapshot.data!;
          int currentStep = order.state.index;

          return OrderDetailContent(
            order: order,
            currentStep: currentStep,
            userType: UserType.user,
          );
        },
      ),
    );
  }
}
