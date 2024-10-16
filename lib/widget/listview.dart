import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/rider_controller.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/pages/reciver_order_detail.dart';
import 'package:quite_courier/pages/sender_order_detail.dart';
import 'package:quite_courier/services/order_service.dart';

class OrderListView extends StatelessWidget {
  final bool useIncomingData;
  UserType userType;
  final int? limit;
  final List<OrderDataRes>? orders;

  OrderListView({super.key, this.useIncomingData = false, this.limit, this.orders, required this.userType});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderDataRes>>(
      future: orders != null ? Future.value(orders!) : _fetchOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No orders available'));
        }

        final displayedOrders = limit != null ? snapshot.data!.take(limit!).toList() : snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedOrders.length,
          itemBuilder: (context, index) {
            final order = displayedOrders[index];
            return _buildOrderItem(order);
          },
        );
      },
    );
  }

  Future<List<OrderDataRes>> _fetchOrders() async {
    var riderController = Get.find<RiderController>();
    return await OrderService.fetchOrderWithRiderAndState(
        riderController.riderData.value.telephone, OrderState.completed);
  }

  Widget _buildOrderItem(OrderDataRes order) {
    return InkWell(
      onTap: useIncomingData
          ? () {
              Get.to(() => ReciverOrderDetail(orderId: order.documentId));
            }
          : () {
              log(order.documentId.toString());
              Get.to(() => SenderOrderDetail(orderId: order.documentId));
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: useIncomingData
              ? const Color(0xFF8CCBE8)
              : const Color(0xFFEAE3D1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.nameOrder,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Image.network(
                    order.orderPhoto,
                    width: 120,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(useIncomingData
                          ? '  ผู้ส่ง : ${order.senderName}'
                          : '  ผู้รับ : ${order.receiverName}'),
                      Text(
                          '  ส่งเมื่อวันที่ : ${order.createdAt.toString().split(' ')[0]}'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTimeline(order.state),
              const SizedBox(height: 8),
              Text(
                  'สถานะ: ${_timelineLabels[OrderState.values.indexOf(order.state)]}'),
            ],
          ),
        ),
      ),
    );
  }

  // Timeline labels
  final List<String> _timelineLabels = [
    'รอดำเนินการ',
    'รับของแล้ว',
    'กำลังจัดส่ง',
    'จัดส่งแล้ว'
  ];

  Widget _buildTimeline(OrderState state) {
    final currentIndex = OrderState.values.indexOf(state);

    return Row(
      children: List.generate(_timelineLabels.length * 2 - 1, (index) {
        if (index.isEven) {
          return _buildTimelineItem(
            index ~/ 2,
            _timelineLabels[index ~/ 2],
            currentIndex,
          );
        }
        return _buildLine(index ~/ 2, currentIndex);
      }),
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
        color: isActive
            ? const Color.fromARGB(255, 0, 0, 0)
            : const Color.fromARGB(255, 255, 255, 255),
        border: isCurrent ? Border.all(color: Colors.green, width: 3) : null,
      ),
    );
  }

  Widget _buildLine(int index, int currentIndex) {
    bool isActive = currentIndex > index;

    return Expanded(
      child: Container(
        height: 3,
        color:
            isActive ? Colors.green : const Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }
}
