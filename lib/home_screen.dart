import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatelessWidget {
  // Home screen with mode selection
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter OSM Map Modes'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.replay),
            title: Text('View Realtime'),
            onTap: () {
              Navigator.pushNamed(context, '/viewRealtime');
            },
          ),
          ListTile(
            leading: Icon(Icons.route),
            title: Text('View Route'),
            onTap: () {
              Navigator.pushNamed(context, '/viewRoute');
            },
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Select Position'),
            onTap: () async {
              final selectedPosition = await Navigator.pushNamed(
                context,
                '/selectPos',
              );
              if (selectedPosition != null && selectedPosition is LatLng) {
                // Handle the selected position
                print(
                    'Selected position: ${selectedPosition.latitude}, ${selectedPosition.longitude}');
                // You can perform further actions with the selected position here
              }
            },
          ),
        ],
      ),
    );
  }
}
