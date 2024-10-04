import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quite_courier/controller/user_profile_controller.dart';


class EditProfilePage extends StatelessWidget {
  final UserProfileController controller = Get.put(UserProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Telephone'),
              onChanged: (value) => controller.updateProfile(newTelephone: value),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) => controller.updateProfile(newName: value),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'GPS Map'),
              onChanged: (value) => controller.updateProfile(newGpsMap: value),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Address Description'),
              onChanged: (value) => controller.updateProfile(newAddressDescription: value),
            ),
            ElevatedButton(
              onPressed: () => controller.saveProfile(),
              child: Text('Edit Profile'),
              style: ElevatedButton.styleFrom(),
            ),
          ],
        ),
      ),
    );
  }
}