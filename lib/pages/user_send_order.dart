import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/models/user_data.dart';
import 'package:quite_courier/pages/map_page.dart';

class UserSendOrder extends StatefulWidget {
  const UserSendOrder({super.key});

  @override
  State<UserSendOrder> createState() => _UserSendOrderState();
}

class _UserSendOrderState extends State<UserSendOrder>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final List<UserData> _users = [
    UserData(
      name: 'John Doe',
      telephone: '0912345678',
      addressDescription: '123 Main St, City',
      image: 'assets/images/avatar.png',
      gpsMap: '13.7563,100.5018',
    ),
    UserData(
      name: 'Jane Smith',
      telephone: '0923456789',
      addressDescription: '456 Elm St, City',
      image: 'assets/images/avatar.png',
      gpsMap: '13.7563,100.5018',
    ),
  ];
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredUsers = _users;
    _searchController.addListener(_filterUsers);
  }

  void _filterUsers() {
    final query = _searchController.text;
    setState(() {
      _filteredUsers = _users.where((user) {
        return user.telephone.contains(query);
      }).toList();
    });
  }

  void _loadReceiverData(UserData user) {
    receiverControllers['name']!.text = user.name;
    receiverControllers['telephone']!.text = user.telephone;
    receiverControllers['addressDescription']!.text = user.addressDescription;
    receiverControllers['gpsMap']!.text = user.gpsMap;
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
    // image is not null
    // name is not empty
    // description is not empty
    dev.log('image: ${_selectedImage != null}');
    dev.log('name: ${itemControllers['name']!.text.isNotEmpty}');
    dev.log('description: ${itemControllers['description']!.text.isNotEmpty}');
    return _selectedImage != null &&
        itemControllers['name']!.text.isNotEmpty &&
        itemControllers['description']!.text.isNotEmpty;
  }

  bool _isReceiverSelected() {
    return _selectedUserIndex != null;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.blue),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text('Back', style: TextStyle(color: Colors.blue)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Item Details'),
                  Tab(text: 'Receiver'),
                  Tab(text: 'Address'),
                ],
                onTap: (index) {
                  // Prevent tab clicks
                  dev.log('index: $index');
                  dev.log('isItemDetailsComplete: ${_isItemDetailsComplete()}');
                  dev.log('isReceiverSelected: ${_isReceiverSelected()}');
                  if (index == 1 && !_isItemDetailsComplete()) {
                    _tabController.animateTo(0);
                  } else if (index == 2 && !_isReceiverSelected()) {
                    _tabController.animateTo(1);
                  }
                },
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildItemDetailsTab(),
            _buildReceiverTab(),
            _buildAddressTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: () {
                _showImagePickerMenu(context);
              },
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : const Icon(Icons.add_a_photo_outlined, size: 100),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: itemControllers['name']!,
            decoration: const InputDecoration(
              hintText: 'ยอดเปล่า',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: itemControllers['description']!,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: '......',
              border: OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_isItemDetailsComplete()) {
                  _tabController.animateTo(1);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: '09xxxxxxxx',
              labelText: 'Search Receiver',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
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
                    color:
                        _selectedUserIndex == index ? Colors.amber[100] : null,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.image),
                      ),
                      title: Text('ชื่อ: ${user.name}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'เบอร์โทร: ${user.telephone.substring(0, 3)}-${user.telephone.substring(3, 6)}-${user.telephone.substring(6)}'),
                          Text('ที่อยู่: ${user.addressDescription}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_isReceiverSelected()) {
                    _tabController.animateTo(2);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectPosition() async {
    final LatLng? selectedPosition = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapPage(mode: MapMode.select),
      ),
    );

    if (selectedPosition != null) {
      setState(() {
        receiverControllers['gpsMap']!.text =
            '${selectedPosition.latitude.toStringAsFixed(5)}, ${selectedPosition.longitude.toStringAsFixed(5)}';
      });
    }
  }

  Widget _buildAddressTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: receiverControllers['name']!,
            decoration: const InputDecoration(
              hintText: 'XXXX',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Telephone', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: receiverControllers['telephone']!,
            decoration: const InputDecoration(
              hintText: 'XXXXX',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text('GPS Map', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            enabled: true,
            controller: receiverControllers['gpsMap']!,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              disabledBorder: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.map),
                onPressed: _selectPosition,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Address Description',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: receiverControllers['addressDescription']!,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'XXXX, YYYY',
              border: OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement send functionality here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
