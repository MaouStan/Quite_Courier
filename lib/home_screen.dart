import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/pages/map_page.dart';

class HomeScreen extends StatelessWidget {
  // final LatLng targetPosition = const LatLng(16.250743, 103.24796);
  // final List<LatLng> riderPositions = [
  //   const LatLng(16.250743, 103.24796),
  //   const LatLng(16.250743, 103.25796),
  //   const LatLng(16.250743, 103.26796),
  //   const LatLng(16.260743, 103.27796),
  //   const LatLng(16.280743, 103.27796)
  // ];

  final String riderTelephone = '123';
  final List<String> riderTelephones = [];

  HomeScreen({super.key}); // Example target position

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter OSM Map Modes'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Select Position'),
            onTap: () async {
              final selectedPosition = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapPage(mode: MapMode.select),
                ),
              );
              if (selectedPosition != null && selectedPosition is LatLng) {
                log('Selected position: ${selectedPosition.latitude}, ${selectedPosition.longitude}');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.route),
            title: const Text('View Route'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MapPage(mode: MapMode.route, riderTelephone: riderTelephone),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_bike),
            title: const Text('View Tracks'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MapPage(mode: MapMode.tracks, riderTelephones: riderTelephones),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
