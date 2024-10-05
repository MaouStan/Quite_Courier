import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/order_controller.dart';

class OrderListView extends StatelessWidget {
  final bool useIncomingData;
  final int? limit;

  OrderListView({super.key, this.useIncomingData = false, this.limit});

  @override
  Widget build(BuildContext context) {
    return GetX<OrderController>(
      builder: (controller) {
        final orders = _getOrders(controller);
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderItem(order, controller);
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getOrders(OrderController controller) {
    List<Map<String, dynamic>> selectedOrders =
        useIncomingData ? controller.incomingPackages : controller.sampleOrders;

    selectedOrders.sort((a, b) =>
        (b['sentDate'] as DateTime).compareTo(a['sentDate'] as DateTime));

    if (limit != null && limit! > 0 && limit! < selectedOrders.length) {
      return selectedOrders.take(limit!).toList();
    }
    return selectedOrders;
  }

  Widget _buildOrderItem(
      Map<String, dynamic> order, OrderController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color:
            useIncomingData ? const Color(0xFF8CCBE8) : const Color(0xFFEAE3D1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order['name'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(useIncomingData
                        ? 'ผู้ส่ง : ${order['sender']}'
                        : 'ผู้รับ : ${order['recipient']}'),
                    Text(
                        'ส่งเมื่อวันที่ : ${(order['sentDate'] as DateTime).toString().split(' ')[0]}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTimeline(order['status'] as OrderStatus),
            const SizedBox(height: 8),
            Text(
                'สถานะ: ${_timelineLabels[OrderStatus.values.indexOf(order['status'] as OrderStatus)]}'),
          ],
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

  Widget _buildTimeline(OrderStatus status) {
    final currentIndex = OrderStatus.values.indexOf(status);

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
