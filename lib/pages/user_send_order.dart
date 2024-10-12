import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/models/order_data_req.dart';
import 'package:quite_courier/models/user_data.dart';
import 'package:quite_courier/pages/map_page.dart';
import 'package:quite_courier/pages/user_home_page.dart';
import 'package:quite_courier/services/order_service.dart';
import 'package:quite_courier/models/order_data_res.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:quite_courier/services/auth_service.dart';
import 'package:quite_courier/controller/user_controller.dart';

class UserSendOrder extends StatefulWidget {
  const UserSendOrder({super.key});

  @override
  State<UserSendOrder> createState() => _UserSendOrderState();
}

class _UserSendOrderState extends State<UserSendOrder>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  late TabController _tabController;
  final _selectedColor = Colors.purple;
  final _unselectedColor = const Color(0xff5f6368);
  final _tabs = const [
    Tab(text: 'Item Details'),
    Tab(text: 'Receiver'),
    Tab(text: 'Address'),
  ];
  final TextEditingController _searchController = TextEditingController();
  final List<UserData> _users = [];
  List<UserData> _filteredUsers = [];
  int? _selectedUserIndex;
  // Item Controllers
  var itemControllers = {
    'name': TextEditingController(),
    'description': TextEditingController(),
  };

  // Receiver Controllers
  var receiverControllers = {
    'name': TextEditingController(),
    'telephone': TextEditingController(),
    'addressDescription': TextEditingController(),
    'gpsMap': TextEditingController(), // Add this line to initialize gpsMap
  };

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_filterUsers);
    _fetchOtherUsers();
  }

  Future<void> _fetchOtherUsers() async {
    setState(() {
      _isLoading = true;
    });

    final UserController userController = Get.find<UserController>();
    final AuthService authService = AuthService();

    try {
      final otherUsers = await authService
          .fetchOtherUsers(userController.userData.value.telephone);
      setState(() {
        _users.addAll(otherUsers);
        _filteredUsers = otherUsers;
        _isLoading = false;
      });
    } catch (e) {
      log('Error fetching other users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return user.telephone.contains(query) ||
            user.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _loadReceiverData(UserData user) {
    receiverControllers['name']!.text = user.name;
    receiverControllers['telephone']!.text = user.telephone;
    receiverControllers['addressDescription']!.text = user.addressDescription;
    receiverControllers['gpsMap']!.text =
        '${user.location.latitude}, ${user.location.longitude}';
  }

  Future<void> _showImagePickerMenu(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                File? selected = await _takePhoto();
                if (selected != null) {
                  setState(() {
                    _selectedImage = selected;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick Image'),
              onTap: () async {
                Navigator.pop(context);
                File? selected = await _pickImage();
                if (selected != null) {
                  setState(() {
                    _selectedImage = selected;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<File?> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  bool _isItemDetailsComplete() {
    return _selectedImage != null &&
        itemControllers['name']!.text.isNotEmpty &&
        itemControllers['description']!.text.isNotEmpty;
  }

  bool _isReceiverSelected() {
    return _selectedUserIndex != null;
  }

  bool _isAddressComplete() {
    return receiverControllers['name']!.text.isNotEmpty &&
        receiverControllers['telephone']!.text.isNotEmpty &&
        receiverControllers['gpsMap']!.text.isNotEmpty &&
        receiverControllers['addressDescription']!.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.keyboard_double_arrow_left,
              color: Color(0xFF6F86D6),
              size: 40.0,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Back',
            style: TextStyle(
              color: Color(0xFF6F86D6),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                tabs: _tabs,
                labelColor: _selectedColor,
                indicatorColor: _selectedColor,
                unselectedLabelColor: _unselectedColor,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildItemDetailsTab(),
                  _buildReceiverTab(),
                  _buildAddressTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: ListView(
        children: [
          GestureDetector(
            onTap: () {
              _showImagePickerMenu(context);
            },
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFA77C0E), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : const Icon(Icons.add_a_photo_outlined, size: 100),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Name",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Get.textTheme.titleMedium!.fontSize,
            ),
          ),
          TextField(
            controller: itemControllers['name']!,
            decoration: InputDecoration(
              hintText: 'กล่องใส่ข้าว',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Description",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Get.textTheme.titleMedium!.fontSize,
            ),
          ),
          TextField(
            controller: itemControllers['description']!,
            maxLines: 5,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(20.0),
            ),
          ),
          const SizedBox(height: 100),
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFF7EAB5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () => _tabController.animateTo(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(230, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    fontSize: Get.textTheme.titleLarge!.fontSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Receiver',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: Get.textTheme.titleMedium!.fontSize,
            ),
          ),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '09x-xxx-xxxx',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search_outlined),
                onPressed: () {
                  _filterUsers();
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedUserIndex = index;
                            _loadReceiverData(user);
                          });
                        },
                        child: Card(
                          color: _selectedUserIndex == index
                              ? Colors.amber[100]
                              : null,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  NetworkImage(user.profileImageUrl),
                            ),
                            title: Text('ชื่อ : ${user.name}',
                                style: TextStyle(
                                    fontSize: Get.textTheme.bodyLarge!.fontSize,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'เบอร์โทร : ${user.telephone.substring(0, 3)}-${user.telephone.substring(3, 6)}-${user.telephone.substring(6)}',
                                    style: TextStyle(
                                        fontSize:
                                            Get.textTheme.bodyLarge!.fontSize,
                                        fontWeight: FontWeight.bold)),
                                Text('ที่อยู่ :  ${user.addressDescription}',
                                    style: TextStyle(
                                        fontSize:
                                            Get.textTheme.bodyLarge!.fontSize,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // const SizedBox(height: 20),
          const Spacer(), // เพิ่ม Spacer เพื่อให้ปุ่มอยู่ด้านล่าง
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFF7EAB5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _tabController.animateTo(0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(100, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                          fontSize: Get.textTheme.titleLarge!.fontSize,
                          color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFF7EAB5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _tabController.animateTo(2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(200, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                          fontSize: Get.textTheme.titleLarge!.fontSize,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _selectPosition() async {
    log('selectPosition');
    final LatLng? selectedPosition = await Get.to(() => MapPage(
          mode: MapMode.select,
          selectedPosition: receiverControllers['gpsMap']!.text.isEmpty
              ? const LatLng(0, 0)
              : LatLng(
                  double.parse(
                      receiverControllers['gpsMap']!.text.split(',')[0]),
                  double.parse(
                      receiverControllers['gpsMap']!.text.split(',')[1]),
                ),
        ));

    if (selectedPosition != null) {
      setState(() {
        receiverControllers['gpsMap']!.text =
            '${selectedPosition.latitude.toStringAsFixed(5)}, ${selectedPosition.longitude.toStringAsFixed(5)}';
      });
    }
  }

  Widget _buildAddressTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Name",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Get.textTheme.titleMedium!.fontSize,
              ),
            ),
            TextField(
              controller: receiverControllers['name']!,
              decoration: InputDecoration(
                hintText: 'MaouStan',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Telephone",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Get.textTheme.titleMedium!.fontSize,
              ),
            ),
            TextField(
              controller: receiverControllers['telephone']!,
              decoration: InputDecoration(
                hintText: '0999999999',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "GPS Map",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Get.textTheme.titleMedium!.fontSize,
              ),
            ),
            Stack(
              children: [
                TextField(
                  enabled: false,
                  style: const TextStyle(color: Colors.black),
                  controller: receiverControllers['gpsMap']!,
                  decoration: InputDecoration(
                    hintText: 'Longtitude 90.0 , Latitude 999',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // suffixIcon: IconButton(
                    //   icon: Image.asset(
                    //     'assets/images/google-maps.png',
                    //     width: 32,
                    //   ),
                    //   onPressed: () {
                    //     _selectPosition;
                    //   },
                    //   ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 2,
                  child: IconButton(
                    icon: Image.asset(
                      'assets/images/google-maps.png',
                      width: 32,
                      height: 32,
                    ),
                    onPressed: _selectPosition,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Address Description",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Get.textTheme.titleMedium!.fontSize,
              ),
            ),
            TextField(
              controller: receiverControllers['addressDescription']!,
              maxLines: null,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'บ้านเลขที่ 99 จังหวัด X เสาไฟหลักสุดท้าย',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 10.0),
              ),
            ),
            const SizedBox(height: 155),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFF7EAB5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _tabController.animateTo(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(100, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                          fontSize: Get.textTheme.titleLarge!.fontSize,
                          color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFF7EAB5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(200, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Send',
                      style: TextStyle(
                          fontSize: Get.textTheme.titleLarge!.fontSize,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50), // เพิ่มพื้นที่ว่างเพิ่มเติม
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    if (!_isItemDetailsComplete() || !_isAddressComplete()) {
      Get.snackbar('Error', 'Please fill in all required fields');
      return;
    }

    Get.defaultDialog(
      title: "Confirm",
      middleText: "Are you sure you want to send?",
      onConfirm: () {
        Get.back(); // Close dialog
        _sendOrder();
      },
      onCancel: () {
        Get.back(); // Close dialog
      },
      confirmTextColor: Colors.white,
      textConfirm: "Yes",
      textCancel: "No",
      buttonColor: Colors.green,
    );
  }

  void _sendOrder() async {
    Get.closeAllSnackbars();
    Get.dialog(const Center(child: CircularProgressIndicator()));

    try {
      final userController = Get.find<UserController>();
      final latLng = receiverControllers['gpsMap']!.text.split(',');
      final latitude = double.parse(latLng[0].trim());
      final longitude = double.parse(latLng[1].trim());

      final newOrder = OrderDataReq(
        riderName: '', // This will be set when a rider accepts the order
        riderTelephone: '', // This will be set when a rider accepts the order
        riderVehicleRegistration:
            '', // This will be set when a rider accepts the order
        senderName: userController
            .userData.value.name, // Replace with actual sender name
        senderTelephone: userController
            .userData.value.telephone, // Replace with actual sender phone
        receiverName: receiverControllers['name']!.text,
        receiverTelephone: receiverControllers['telephone']!.text,
        nameOrder: itemControllers['name']!.text,
        orderPhoto: '', // This needs to be uploaded and URL stored
        riderOrderPhoto1: '',
        riderOrderPhoto2: '',
        description: itemControllers['description']!.text,
        senderLocation: userController.userData.value.location,
        receiverLocation: LatLng(latitude, longitude),
        senderAddress: userController.userData.value.addressDescription,
        receiverAddress: receiverControllers['addressDescription']!.text,
        state: OrderState.pending,
        createdAt: DateTime.now(),
      );

      bool success = await OrderService.createOrder(newOrder, _selectedImage!);
      if (success) {
        Get.snackbar('Success', 'Order sent successfully');
        // back to home page
        Get.offAll(() => const UserHomePage());
      } else {
        Get.snackbar('Error', 'Failed to send order. Please try again.');
      }
    } catch (e) {
      log('Error sending order: $e');
      Get.snackbar('Error', 'Failed to send order. Please try again.');
    }
  }
}
