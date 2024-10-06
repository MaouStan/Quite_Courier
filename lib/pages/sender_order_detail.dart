import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:quite_courier/controller/order_controller.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/drawer.dart';
import 'package:quite_courier/widget/status.dart';

class SenderOrderDetail extends StatefulWidget {
  final String orderId; // Define orderId as a required parameter.

  const SenderOrderDetail({required this.orderId, Key? key}) : super(key: key);

  @override
  State<SenderOrderDetail> createState() => _SenderOrderDetailState();
}

class _SenderOrderDetailState extends State<SenderOrderDetail> {
  final OrderController orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    final order = orderController.sampleOrders
        .firstWhere((o) => o['id'] == widget.orderId);
    String gpsMap = order['gpsMap']; // e.g., "9999,9999"
    int currentStep = order['status'].index; // กำหนดค่าเริ่มต้นตามที่คุณต้องการ

    return Scaffold(
      appBar: CustomAppBar(
        location: gpsMap,
      ),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'สถานะการจัดส่ง ',
                  style: TextStyle(
                      fontSize: Get.textTheme.titleLarge!.fontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF202442)),
                ),
                const SizedBox(height: 8),
                DeliveryStatusTracker(
                  currentStep: currentStep,
                ),
                Text(
                  'รายละเอียด Rider',
                  style: TextStyle(
                    fontSize: Get.textTheme.titleLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                // เงื่อนไขแสดง 2 Container หรือ 1 Container
                if (currentStep == 2 || currentStep == 3)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Container แรก
                        Container(
                          width: 180,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFA77C0E),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'https://mpics.mgronline.com/pics/Images/563000005465501.JPEG',
                            ),
                          ),
                        ),
                        const SizedBox(width: 20), // ระยะห่างระหว่าง Container
                        // Container ที่สอง
                        Container(
                          width: 180,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFA77C0E),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'https://cdn.pixabay.com/photo/2022/05/10/10/35/box-7186750_640.png',
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: Container(
                      width: 180,
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFA77C0E),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          'https://cdn.pixabay.com/photo/2022/05/10/10/35/box-7186750_640.png',
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            NetworkImage('https://your-image-url.com'),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ชื่อ : ${order['rider']}',
                            style: TextStyle(
                              fontSize: Get.textTheme.bodyLarge!.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'เบอร์โทร : ${order['riderphone']}',
                            style: TextStyle(
                              fontSize: Get.textTheme.bodyLarge!.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ทะเบียนรถ: ${order['vehicleRegistration']}',
                            style: TextStyle(
                              fontSize: Get.textTheme.bodyLarge!.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                const SizedBox(
                  height: 12,
                ),
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
                const SizedBox(
                  height: 8,
                ),
                Center(
                  child: Container(
                    width: 300,
                    height: 190,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFA77C0E),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://cdn.pixabay.com/photo/2022/05/10/10/35/box-7186750_640.png',
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(order['description'],
                    style: TextStyle(
                      fontSize: Get.textTheme.bodyMedium!.fontSize,
                    )),
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  'รายละเอียดผู้รับ',
                  style: TextStyle(
                    fontSize: Get.textTheme.titleLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 12.0,
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            NetworkImage('https://your-image-url.com'),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name : ${order['recipient']}',
                            style: TextStyle(
                              fontSize: Get.textTheme.bodyLarge!.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'เบอร์โทร : ${order['telephone']}',
                            style: TextStyle(
                              fontSize: Get.textTheme.bodyLarge!.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Center(
                    child: Text(
                      order['addressDescription'],
                        style: TextStyle(
                          fontSize: Get.textTheme.bodyLarge!.fontSize,
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: SizedBox(
                    height: 65,
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        log('เปิดแมพ');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // สีพื้นหลังสีเขียว
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              30), // ปรับความโค้งของขอบปุ่ม
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15), // ระยะห่างด้านในปุ่ม
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // จัดให้อยู่ตรงกลาง
                        children: [
                          const Icon(
                            Icons.map_outlined,
                            color: Colors.white,
                            size: 30,
                          ), // ไอคอน
                          const SizedBox(
                              width: 6), // ระยะห่างระหว่างไอคอนและข้อความ
                          Text(
                            'ดูตำแหน่ง',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Get.textTheme.headlineSmall!
                                  .fontSize, // ข้อความและสี
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
