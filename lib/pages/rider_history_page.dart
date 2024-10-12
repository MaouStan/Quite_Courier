import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/rider_controller.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/services/order_service.dart';
import 'package:quite_courier/widget/appbar.dart';
import 'package:quite_courier/widget/drawer.dart';
import 'package:quite_courier/widget/listview.dart';

class RiderHistoryPage extends StatefulWidget {
  const RiderHistoryPage({super.key});

  @override
  State<RiderHistoryPage> createState() => _RiderHistoryState();
}

class _RiderHistoryState extends State<RiderHistoryPage> {
  final RiderController stateController = Get.find<RiderController>();
  List<OrderDataRes> orders = [];
  Future<void>? futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = loadOrders();
  }

  Future<void> loadOrders() async {
    orders = await OrderService.fetchOrderWithRiderAndState(
        stateController.riderData.value.telephone, OrderState.completed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(userType: UserType.rider),
      drawer: const MyDrawer(userType: UserType.rider),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: const Color(0xFFF0EAE2),
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'ส่งของแล้ว\t\t\t${orders.length}',
                        style: TextStyle(
                            fontSize: Get.textTheme.titleMedium!.fontSize,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 12.0,
              ),
              OrderListView(useIncomingData: false),
            ],
          ),
        ),
      ),
    );
  }
}
