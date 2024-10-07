import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/pages/reciever_list_view_page.dart';
import 'package:quite_courier/pages/rider_history_page.dart';
import 'package:quite_courier/pages/signin_page.dart';
import 'package:quite_courier/pages/user_home_page.dart';
import 'package:quite_courier/pages/user_send_order.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/pages/rider_home_page.dart';
import 'package:quite_courier/pages/rider_profile_page.dart';

class MyDrawer extends StatelessWidget {
  final UserType userType;

  const MyDrawer({super.key, this.userType = UserType.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: userType == UserType.rider
          ? Column(children: _buildRiderWidgets(context))
          : Column(children: _buildUserWidgets(context)),
    );
  }

  List<Widget> _buildRiderWidgets(BuildContext context) {
    return [
      Container(
        padding: const EdgeInsets.only(top: 60.0, left: 20.0, bottom: 15),
        color: const Color(0xFF9195f4).withOpacity(0.25),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/images/profile.png'),
              child: Stack(
                alignment: Alignment.bottomRight,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Text(
                  'Name',
                  style: TextStyle(
                      fontSize: Get.textTheme.titleLarge!.fontSize,
                      fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    log('view profile');
                    Get.to(() => const RiderProfilePage(),
                        transition: Transition.fade);
                  },
                  child: Text('view profile',
                      style: TextStyle(
                          color: Colors.purple,
                          fontSize: Get.textTheme.bodyLarge!.fontSize)),
                ),
              ],
            ),
          ],
        ),
      ),
      ListTile(
        title: Text(
          "Home",
          style: TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize),
        ),
        leading: const Icon(
          Icons.home_outlined,
          size: 40,
        ),
        onTap: () {
          if (Get.currentRoute == '/rider_home_page') {
            return;
          }
          Get.to(() => const RiderHomePage(), transition: Transition.fade);
        },
      ),
      const SizedBox(height: 10),
      const SizedBox(
        width: 280,
        child: Divider(
          height: 1,
          thickness: 2,
          color: Color(0xFF9195f4),
        ),
      ),
      ListTile(
        title: Text("History",
            style: TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize)),
        leading: const Icon(Icons.history_outlined, size: 40),
        onTap: () {
          // if (Get.currentRoute == '/rider_history_page') {
          //   return;
          // }
          Get.to(() => const RiderHistoryPage(), transition: Transition.fade);
        },
      ),
      const SizedBox(height: 10),
      const SizedBox(
        width: 280,
        child: Divider(
          height: 1,
          thickness: 2,
          color: Color(0xFF9195f4),
        ),
      ),
      Expanded(child: Container()),
      Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          children: [
            const SizedBox(
              width: 280,
              child: Divider(
                height: 1,
                thickness: 2,
                color: Color(0xFF9195f4),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text("Logout",
                  style:
                      TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize)),
              leading: const Icon(Icons.logout, size: 40),
              onTap: () {
                Get.defaultDialog(
                  title: 'Logout',
                  middleText: 'Are you sure you want to logout?',
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            const SizedBox(
              width: 280,
              child: Divider(
                height: 1,
                thickness: 2,
                color: Color(0xFF9195f4),
              ),
            ),
          ],
        ),
      )
    ];
  }

  List<Widget> _buildUserWidgets(BuildContext context) {
    return [
      Container(
        padding: const EdgeInsets.only(top: 60.0, left: 20.0, bottom: 15),
        color: const Color(0xFFA99462).withOpacity(0.25),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/images/profile.png'),
              child: Stack(
                alignment: Alignment.bottomRight,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Text(
                  'Name',
                  style: TextStyle(
                      fontSize: Get.textTheme.titleLarge!.fontSize,
                      fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    log('view profile');
                    Get.to(() => const RiderProfilePage(),
                        transition: Transition.fade);
                  },
                  child: Text('view profile',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: Get.textTheme.bodyLarge!.fontSize)),
                ),
              ],
            ),
          ],
        ),
      ),
      ListTile(
        title: Text(
          "Dashboard",
          style: TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize),
        ),
        leading: const Icon(
          Icons.dashboard_outlined,
          size: 40,
        ),
        onTap: () {
          log('Dashboard');
        },
      ),
      const SizedBox(height: 10),
      const SizedBox(
        width: 280,
        child: Divider(
          height: 1,
          thickness: 2,
          color: Color(0xFF908E1C),
        ),
      ),
      ListTile(
        title: Text("Orders",
            style: TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize)),
        leading: const Icon(Icons.list_alt_outlined, size: 40),
        onTap: () {
          log('Orders');
        },
      ),
      const SizedBox(height: 10),
      const SizedBox(
        width: 280,
        child: Divider(
          height: 1,
          thickness: 2,
          color: Color(0xFF908E1C),
        ),
      ),
      Expanded(child: Container()),
      Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          children: [
            const SizedBox(
              width: 280,
              child: Divider(
                height: 1,
                thickness: 2,
                color: Color(0xFF908E1C),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text("Logout",
                  style:
                      TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize)),
              leading: const Icon(Icons.logout, size: 40),
              onTap: () {
                Get.defaultDialog(
                  title: 'Logout',
                  middleText: 'Are you sure you want to logout?',
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            const SizedBox(
              width: 280,
              child: Divider(
                height: 1,
                thickness: 2,
                color: Color(0xFF908E1C),
              ),
            ),
          ],
        ),
      )
    ];
  }
}
