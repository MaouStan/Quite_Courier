import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quite_courier/controller/user_controller.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/widget/loadDots.dart';
import 'package:quite_courier/widget/status.dart';

class OrderDetailContent extends StatelessWidget {
  final UserType userType;
  final String orderId;

  const OrderDetailContent({
    required this.orderId,
    required this.userType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Order not found'));
        }

        final orderData = snapshot.data!.data() as Map<String, dynamic>;
        final order = OrderDataRes.fromJson(orderData, snapshot.data!.id);
        final currentStep = _getStepFromOrderState(order.state);

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'สถานะการจัดส่ง ',
                    style: TextStyle(
                      fontSize: Get.textTheme.titleLarge!.fontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF202442),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DeliveryStatusTracker(currentStep: currentStep),
                  Text(
                    'รายละเอียด Rider',
                    style: TextStyle(
                      fontSize: Get.textTheme.titleLarge!.fontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF202442),
                    ),
                  ),
                  const Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16),
                  _buildRiderDetails(order),
                  const Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16),
                  const SizedBox(height: 12),
                  Text(
                    'รายละเอียดส่งของ',
                    style: TextStyle(
                      fontSize: Get.textTheme.titleLarge!.fontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF202442),
                    ),
                  ),
                  Text(
                    order.nameOrder,
                    style: TextStyle(
                      fontSize: Get.textTheme.titleLarge!.fontSize,
                      color: const Color(0xFF202442),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDeliveryImage(order),
                  const SizedBox(height: 12),
                  Text(order.description,
                      style: TextStyle(
                          fontSize: Get.textTheme.bodyMedium!.fontSize)),
                  const SizedBox(height: 20.0),
                  Text(
                    order.receiverTelephone !=
                            userController.userData.value.telephone
                        ? 'รายละเอียดผู้รับ'
                        : 'รายละเอียดผู้จัดส่ง',
                    style: TextStyle(
                      fontSize: Get.textTheme.titleLarge!.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16),
                  _buildRecipientDetails(order),
                  const Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16),
                  _buildAddressDescription(order),
                  if (userType == UserType.rider) ...[
                    Text(
                      'รายละเอียดผู้ส่ง',
                      style: TextStyle(
                        fontSize: Get.textTheme.titleLarge!.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _buildSenderDetails(order),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        Text('ที่อยู่ : '),
                      ],
                    )
                  ],
                  const SizedBox(
                    height: 12.0,
                  ),
                  _buildMapButton(order),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRiderDetails(OrderDataRes order) {
    if (order.riderName == null || order.riderName!.isEmpty) {
      return Container(
        decoration: const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.all(12.0),
        child: const Center(
          child: LoadingDots(),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(order.riderProfileImage ?? ''),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ชื่อ : ${order.riderName}', style: _detailsTextStyle()),
                const SizedBox(height: 4),
                Text('เบอร์โทร : ${order.riderTelephone ?? "ไม่มีข้อมูล"}',
                    style: _detailsTextStyle()),
                Text(
                    'ทะเบียนรถ: ${order.riderVehicleRegistration ?? "ไม่มีข้อมูล"}',
                    style: _detailsTextStyle()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryImage(OrderDataRes order) {
    return Center(
      child: Container(
        width: 300,
        height: 190,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFA77C0E), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(order.orderPhoto, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildRecipientDetails(OrderDataRes order) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(order.receiverProfileImage ?? ''),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name : ${order.receiverName}', style: _detailsTextStyle()),
              const SizedBox(height: 4),
              Text('เบอร์โทร : ${order.receiverTelephone}',
                  style: _detailsTextStyle()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSenderDetails(OrderDataRes order) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(order.senderProfileImage ?? ''),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name : ${order.senderName}', style: _detailsTextStyle()),
              const SizedBox(height: 4),
              Text('เบอร์โทร : ${order.senderTelephone}',
                  style: _detailsTextStyle()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDescription(OrderDataRes order) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 30,
            ),
            Text('ที่อยู่ : ', style: TextStyle(fontSize: Get.textTheme.titleMedium!.fontSize, fontWeight: FontWeight.bold, color: Colors.purple.shade600),),
            Text(order.receiverAddress, style: const TextStyle(fontStyle: FontStyle.italic),)
          ],
        ));
  }

  Widget _buildMapButton(OrderDataRes order) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 65,
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            log('map');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, color: Colors.white, size: 30),
              const SizedBox(width: 6),
              Text(
                'ดูตำแหน่ง',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Get.textTheme.headlineSmall!.fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _detailsTextStyle() {
    return TextStyle(
      fontSize: Get.textTheme.bodyLarge!.fontSize,
      fontWeight: FontWeight.bold,
    );
  }

  int _getStepFromOrderState(OrderState state) {
    switch (state) {
      case OrderState.pending:
        return 0;
      case OrderState.accepted:
        return 1;
      case OrderState.onDelivery:
        return 2;
      case OrderState.completed:
        return 3;
      case OrderState.canceled:
        return 4;
      default:
        return 0;
    }
  }
}
