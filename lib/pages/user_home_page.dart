import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quite_courier/controller/user_controller.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/models/map_track_req.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/pages/map_page.dart';
import 'package:quite_courier/pages/reciever_list_view_page.dart';
import 'package:quite_courier/pages/sender_list_view_page.dart';
import 'package:quite_courier/pages/user_send_order.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/drawer.dart';
import 'package:quite_courier/widget/listview.dart';

class OrdersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserController userController = Get.find<UserController>();

  final sentOrders = <OrderDataRes>[].obs;
  final receivedOrders = <OrderDataRes>[].obs;

  late StreamSubscription<QuerySnapshot> _sentOrdersSubscription;
  late StreamSubscription<QuerySnapshot> _receivedOrdersSubscription;

  @override
  void onInit() {
    super.onInit();
    _initStreams();
  }

  void _initStreams() {
    final userPhone = userController.userData.value.telephone;

    // Subscribe to sent orders
    _sentOrdersSubscription = _firestore
        .collection('orders')
        .where('senderTelephone', isEqualTo: userPhone)
        .snapshots()
        .listen((snapshot) {
      sentOrders.value = snapshot.docs
          .map((doc) => OrderDataRes.fromJson(doc.data(), doc.id))
          .toList();
    });

    // Subscribe to received orders
    _receivedOrdersSubscription = _firestore
        .collection('orders')
        .where('receiverTelephone', isEqualTo: userPhone)
        .snapshots()
        .listen((snapshot) {
      receivedOrders.value = snapshot.docs
          .map((doc) => OrderDataRes.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  void onClose() {
    _sentOrdersSubscription.cancel();
    _receivedOrdersSubscription.cancel();
    super.onClose();
  }
}

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final UserController userController = Get.find<UserController>();
  final OrdersController ordersController = Get.put(OrdersController());
  final int orderLimit = 3;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const CustomAppBar(),
        drawer: const MyDrawer(),
        body: Obx(() {
          final activeOrders = ordersController.sentOrders
              .where((order) => order.state != OrderState.completed)
              .toList();
          final activeReceivedOrders = ordersController.receivedOrders
              .where((order) => order.state != OrderState.completed)
              .toList();

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildUserInfoCard(activeOrders, activeReceivedOrders),
                  const SizedBox(height: 12),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      List<MapTrackReqOrder> orders = [...activeOrders, ...activeReceivedOrders]
                          .where((order) =>
                              (order.state == OrderState.accepted ||
                              order.state == OrderState.onDelivery))
                          .map((order) => MapTrackReqOrder(
                                riderTelephone: order.riderTelephone,
                                orderPosition: order.state == OrderState.accepted
                                    ? order.receiverLocation
                                    : order.senderLocation,
                              ))
                          .toList();

                      Get.to(() => MapPage(
                            mode: MapMode.tracks,
                            orders: orders,
                          ));
                    },
                    child: const Text('Track All'),
                  ),
                  _buildSentOrdersSection(activeOrders),
                  _buildReceivedOrdersSection(activeReceivedOrders),
                ],
              ),
            ),
          );
        }),
        floatingActionButton: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: () {
              log("กดปุ่ม +");
              Get.to(() => const UserSendOrder());
            },
            backgroundColor: const Color(0xFFE2E0E0),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 50),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(
      List<OrderDataRes> sentOrders, List<OrderDataRes> receivedOrders) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    NetworkImage(userController.userData.value.profileImageUrl),
              ),
              const SizedBox(width: 12),
              Text(
                userController.userData.value.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  'จัดส่งแล้ว',
                  ordersController.sentOrders
                      .where((order) => order.state == OrderState.completed)
                      .length),
              _buildStatItem('กำลังส่ง', sentOrders.length),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  'รับของแล้ว',
                  ordersController.receivedOrders
                      .where((order) => order.state == OrderState.completed)
                      .length),
              _buildStatItem('ของกำลังมาส่ง', receivedOrders.length),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentOrdersSection(List<OrderDataRes> sentOrders) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('สิ่งของที่คุณส่ง :',
                style: TextStyle(
                    fontSize: Get.textTheme.bodyLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            TextButton(
                onPressed: () {
                  Get.to(() => const SenderListViewPage());
                },
                child: Text('มากกว่านี้ >>',
                    style: TextStyle(
                        fontSize: Get.textTheme.bodyLarge!.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)))
          ],
        ),
        OrderListView(
          useIncomingData: false,
          orders: sentOrders,
          limit: orderLimit,
          userType: UserType.user,
        ),
      ],
    );
  }

  Widget _buildReceivedOrdersSection(List<OrderDataRes> receivedOrders) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('สิ่งของที่คุณต้องรับ :',
                style: TextStyle(
                    fontSize: Get.textTheme.bodyLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            TextButton(
                onPressed: () {
                  Get.to(() => const RecieverListViewPage());
                },
                child: Text('มากกว่านี้ >>',
                    style: TextStyle(
                        fontSize: Get.textTheme.bodyLarge!.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)))
          ],
        ),
        OrderListView(
          useIncomingData: true,
          orders: receivedOrders,
          limit: orderLimit,
          userType: UserType.user,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: Get.textTheme.bodyMedium!.fontSize,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 20),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
