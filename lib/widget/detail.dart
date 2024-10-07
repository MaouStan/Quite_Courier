import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/widget/status.dart';

class OrderDetailContent extends StatelessWidget {
  final UserType userType;

  final Map<String, dynamic> order;
  final int currentStep;

  const OrderDetailContent({
    required this.order,
    required this.currentStep,
    required this.userType,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.black,
                ),
              ),
              if (order['recipient'] != null) ...[
                const SizedBox(height: 8),
                _buildRiderContainers(),
                const SizedBox(height: 20),
              ],
              const Divider(
                  color: Colors.black, thickness: 1, indent: 16, endIndent: 16),
              _buildRiderDetails(),
              const Divider(
                  color: Colors.black, thickness: 1, indent: 16, endIndent: 16),
              const SizedBox(height: 12),
              Text(
                'รายละเอียดส่งของ',
                style: TextStyle(
                  fontSize: Get.textTheme.titleLarge!.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                order['name'],
                style: TextStyle(
                  fontSize: Get.textTheme.titleLarge!.fontSize,
                  color: const Color(0xFF202442),
                ),
              ),
              const SizedBox(height: 8),
              _buildDeliveryImage(),
              const SizedBox(height: 12),
              Text(order['description'],
                  style:
                      TextStyle(fontSize: Get.textTheme.bodyMedium!.fontSize)),
              const SizedBox(height: 20.0),
              Text(
                order['recipient'] != null
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
                  color: Colors.black, thickness: 1, indent: 16, endIndent: 16),
              _buildRecipientDetails(),
              const Divider(
                  color: Colors.black, thickness: 1, indent: 16, endIndent: 16),
              _buildAddressDescription(),
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
                _buildSenderDetails(),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
              ],
              const SizedBox(
                height: 12.0,
              ),
              _buildMapButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiderContainers() {
    return (currentStep == 2 || currentStep == 3)
        ? Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContainer(
                    'https://mpics.mgronline.com/pics/Images/563000005465501.JPEG'),
                const SizedBox(width: 20),
                _buildContainer(
                    'https://cdn.pixabay.com/photo/2022/05/10/10/35/box-7186750_640.png'),
              ],
            ),
          )
        : Center(
            child: _buildContainer(
                'https://cdn.pixabay.com/photo/2022/05/10/10/35/box-7186750_640.png'));
  }

  Widget _buildContainer(String imageUrl) {
    return Container(
      width: 180,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFA77C0E), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(imageUrl),
      ),
    );
  }

  Widget _buildRiderDetails() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage('https://your-image-url.com'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ชื่อ : ${order['rider']}', style: _detailsTextStyle()),
              const SizedBox(height: 4),
              Text('เบอร์โทร : ${order['riderphone']}',
                  style: _detailsTextStyle()),
              Text('ทะเบียนรถ: ${order['vehicleRegistration']}',
                  style: _detailsTextStyle()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryImage() {
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
          child: Image.network(
              'https://cdn.pixabay.com/photo/2022/05/10/10/35/box-7186750_640.png'),
        ),
      ),
    );
  }

  Widget _buildRecipientDetails() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage('https://your-image-url.com'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name : ${order['recipient'] ?? order['sender'] ?? 'ไม่พบข้อมูล'}',
                style: _detailsTextStyle(),
              ),
              const SizedBox(height: 4),
              Text('เบอร์โทร : ${order['telephone']}',
                  style: _detailsTextStyle()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSenderDetails() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage('https://your-image-url.com'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name : ${order['sender'] ?? 'ไม่พบข้อมูล'}',
                style: _detailsTextStyle(),
              ),
              const SizedBox(height: 4),
              Text('เบอร์โทร : ${order['sendertelephone']}',
                  style: _detailsTextStyle()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Center(
        child: Text(
          order['addressDescription'] ?? 'ไม่พบข้อมูล',
          style: TextStyle(fontSize: Get.textTheme.bodyLarge!.fontSize),
        ),
      ),
    );
  }

  Widget _buildMapButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 65,
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            log('เปิดแมพ');
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
}
