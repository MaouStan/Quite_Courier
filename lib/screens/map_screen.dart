import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class SelectPositionScreen extends StatefulWidget {
  @override
  _SelectPositionScreenState createState() => _SelectPositionScreenState();
}

class _SelectPositionScreenState extends State<SelectPositionScreen> {
  late LatLng _selectedPosition;
  late LatLng _initialPosition;
  bool _isLoading = true; // Indicates if the location is being fetched
  String? _error; // Stores any error messages
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Method to determine the current position of the device
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }

      // Check for location permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permissions are denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error =
              'Location permissions are permanently denied, we cannot request permissions.';
          _isLoading = false;
        });
        return;
      }

      // When permissions are granted, get the position
      Position position = await Geolocator.getCurrentPosition();

      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
        _initialPosition = LatLng(position.latitude, position.longitude);
        log('My position: $_selectedPosition');
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'An error occurred while fetching location: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while fetching location
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Select Position'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show an error message if location fetching failed
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Select Position'),
        ),
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Display the map once the location is fetched successfully
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Position'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Return the selected position to the previous screen
              Navigator.pop(context, _selectedPosition);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialRotation: 0,
              initialCenter: _selectedPosition, // Updated from initialCenter
              initialZoom: 16.0, // Updated from initialZoom

              onTap: (tapPosition, point) {
                setState(() {
                  log('Tap position: $point');
                  _selectedPosition = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: [
                  // My position
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _initialPosition,
                    child: const Icon(
                      Icons.location_history,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                  // Selected position
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: _selectedPosition,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Positioned widget to display the selected position at the bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Selected Position:\nLatitude: ${_selectedPosition.latitude.toStringAsFixed(5)},\nLongitude: ${_selectedPosition.longitude.toStringAsFixed(5)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Icon Button Right Button to change selected position to initial position
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.my_location, size: 40),
              onPressed: () {
                setState(() {
                  // reset map
                  mapController.move(_initialPosition, 16.0);
                  mapController.rotate(0);
                  _selectedPosition = _initialPosition;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
