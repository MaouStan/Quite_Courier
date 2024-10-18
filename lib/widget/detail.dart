import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/controller/user_controller.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/pages/map_page.dart';
import 'package:quite_courier/widget/loadDots.dart';
import 'package:quite_courier/widget/status.dart';

class OrderDetailContent extends StatelessWidget {
  final UserType userType;
  final OrderDataRes order;

  const OrderDetailContent({
    required this.userType,
    required this.order,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .doc(order.documentId)
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
        final updatedOrder =
            OrderDataRes.fromJson(orderData, snapshot.data!.id);
        final currentStep = _getStepFromOrderState(updatedOrder.state);

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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      updatedOrder.nameOrder,
                      style: TextStyle(
                        fontSize: Get.textTheme.titleLarge!.fontSize,
                        color: const Color(0xFF202442),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDeliveryImage(updatedOrder),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'รายละเอียด:',
                          style: TextStyle(
                            fontSize: Get.textTheme.titleMedium!.fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.description,
                          style: TextStyle(
                            fontSize: Get.textTheme.bodyMedium!.fontSize,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 30,
                        ),
                        Text(
                          'ที่อยู่ : ',
                          style: TextStyle(
                            fontSize: Get.textTheme.titleMedium!.fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade600,
                          ),
                        ),
                        Expanded(
                          // ใช้ Expanded เพื่อให้ข้อความสามารถยืดหยุ่นได้
                          child: Text(
                            order.senderAddress,
                            softWrap: true, // อนุญาตให้ข้อความขึ้นบรรทัดใหม่
                            overflow: TextOverflow
                                .visible, // กำหนดให้ข้อความที่ยาวเกินไม่ถูกตัด
                          ),
                        ),
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
    if (order.riderName.isEmpty) {
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
            backgroundImage: NetworkImage(order.riderProfileImage ?? ""),
            onBackgroundImageError: (exception, stackTrace) {
              // Use a placeholder icon when the image fails to load
              return;
            },
            child: order.riderProfileImage == null ||
                    order.riderProfileImage!.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  )
                : null,
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

  Widget _buildDeliveryImage(OrderDataRes updatedOrder) {
    if (updatedOrder.state == OrderState.onDelivery ||
        updatedOrder.state == OrderState.completed) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (updatedOrder.riderOrderPhoto1.isNotEmpty)
              _buildImageContainer(updatedOrder.riderOrderPhoto1),
            const SizedBox(width: 10),
            if (updatedOrder.riderOrderPhoto2.isNotEmpty)
              _buildImageContainer(updatedOrder.riderOrderPhoto2),
          ],
        ),
      );
    } else {
      return Center(
        child: _buildImageContainer(updatedOrder.orderPhoto),
      );
    }
  }

  Widget _buildImageContainer(String imageUrl) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFA77C0E), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 120,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 120,
              height: 80,
              color: Colors.grey[300],
              child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
            );
          },
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
            onBackgroundImageError: (exception, stackTrace) {
              // Use a placeholder icon when the image fails to load
              return;
            },
            child: order.receiverProfileImage == null ||
                    order.receiverProfileImage!.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  )
                : null,
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
            onBackgroundImageError: (exception, stackTrace) {
              // Use a placeholder icon when the image fails to load
              return;
            },
            child: order.senderProfileImage == null ||
                    order.senderProfileImage!.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  )
                : null,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 30),
          Text(
            'ที่อยู่ : ',
            style: TextStyle(
              fontSize: Get.textTheme.titleMedium!.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade600,
            ),
          ),
          Expanded(
            child: Text(
              order.receiverAddress,
              style: TextStyle(fontSize: Get.textTheme.bodyMedium!.fontSize),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton(OrderDataRes order) {
    if (order.state == OrderState.pending ||
        order.state == OrderState.completed) {
      return Container();
    }
    LatLng orderPosition;
    if (order.state == OrderState.accepted) {
      orderPosition = order.senderLocation;
    } else if (order.state == OrderState.onDelivery) {
      orderPosition = order.receiverLocation;
    } else {
      orderPosition = order.receiverLocation;
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 45,
        width: 150,
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => MapPage(
                  mode: MapMode.route,
                  riderTelephone: order.riderTelephone,
                  orderPosition: orderPosition,
                ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 2),
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
                  fontSize: Get.textTheme.titleMedium!.fontSize,
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
