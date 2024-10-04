import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String location;

  CustomAppBar({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, size: 40,),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Current location',
            style: TextStyle(color: Colors.grey, fontSize: Get.textTheme.bodyLarge!.fontSize),
          ),
          Text(
            location,
            style: TextStyle(color: Colors.blue, fontSize: Get.textTheme.bodyLarge!.fontSize),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,size: 40,),
          onPressed: () {
            // จัดการการกดปุ่มแจ้งเตือน
          },
        ),
      ],
    ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}