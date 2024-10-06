import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/interfaces/user_types.dart';
import 'package:quite_courier/services/geolocator_services.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final UserType userType;

  const CustomAppBar({super.key, this.userType = UserType.user});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String location = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool permissionGranted = await GeolocatorServices.checkPermission();
    if (permissionGranted) {
      var position = await GeolocatorServices.getCurrentLocation();
      setState(() {
        location = '${position.latitude}, ${position.longitude}';
      });
    } else {
      setState(() {
        location = 'Location not available';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color:
            widget.userType == UserType.rider ? Colors.blue[100] : Colors.white,
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
          icon: const Icon(
            Icons.menu,
            size: 40,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Current location',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: Get.textTheme.bodyLarge!.fontSize),
            ),
            Text(
              location,
              style: TextStyle(
                  color: widget.userType == UserType.rider
                      ? const Color(0xFF756af6)
                      : Colors.black,
                  fontSize: Get.textTheme.bodyLarge!.fontSize),
            ),
          ],
        ),
        centerTitle: true,
        actions: widget.userType == UserType.user
            ? [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 40),
                  onPressed: () {
                    // Handle notification action
                  },
                ),
              ]
            : [],
      ),
    );
  }
}
