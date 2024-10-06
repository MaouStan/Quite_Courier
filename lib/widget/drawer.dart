import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/pages/reciever_list_view_page.dart';
import 'package:quite_courier/pages/signin_page.dart';
import 'package:quite_courier/pages/user_home_page.dart';
import 'package:quite_courier/pages/user_send_order.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
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
                      style:
                          TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {log('view profile');},
                      child: Text('view profile',
                      style: TextStyle(color: Colors.grey, fontSize: Get.textTheme.bodyLarge!.fontSize)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            child: Divider(
              height: 1,
              thickness: 1.5,
              color: Color(0xFF908E1C),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            width: 280,
            child: Divider(
              height: 1,
              thickness: 2,
              color: Color(0xFF908E1C),
            ),
          ),
          const SizedBox(
            height: 10,
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
              Get.to(() => UserhomePage());
             
            },
          ),
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            width: 280,
            child: Divider(
              height: 1,
              thickness: 2,
              color: Color(0xFF908E1C),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            width: 280,
            child: Divider(
              height: 1,
              thickness: 2,
              color: Color(0xFF908E1C),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ListTile(
            title: Text("Receive",
                style: TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize)),
            leading: const Icon(Icons.file_upload_outlined, size: 40),
            onTap: () {
              Get.to(() => RecieverListViewPage());
            },
          ),
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            width: 280,
            child: Divider(
              height: 1,
              thickness: 2,
              color: Color(0xFF908E1C),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            width: 280,
            child: Divider(
              height: 1,
              thickness: 2,
              color: Color(0xFF908E1C),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ListTile(
            title: Text("Send",
                style: TextStyle(fontSize: Get.textTheme.titleLarge!.fontSize)),
            leading: const Icon(Icons.send_outlined, size: 40),
            onTap: () {
              Get.to(()=> UserSendOrder());
            },
          ),
          const SizedBox(
            height: 10,
          ),
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
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: Text("Logout",
                      style: TextStyle(
                          fontSize: Get.textTheme.titleLarge!.fontSize)),
                  leading: const Icon(Icons.logout, size: 40),
                  onTap: () {
                    Get.to(() => const SigninPage());
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
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
          ),
        ],
      ),
    );
  }
}
