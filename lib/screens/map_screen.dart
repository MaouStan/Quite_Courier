import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:quite_courier/services/geolocator_services.dart';

Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
  // Construct the URL for the OSRM API
  final url =
      'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson';
  dev.log('URL: $url');

  // Make the HTTP GET request
  dev.log('Fetching route from $start to $end');
  final response = await http.get(Uri.parse(url));

  // Check if the response is successful
  if (response.statusCode == 200) {
    // Parse the JSON response
    final data = json.decode(response.body);

    // Extract the coordinates from the response
    final List<dynamic> coordinates =
        data['routes'][0]['geometry']['coordinates'];
    // Convert the coordinates to a list of LatLng objects
    return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
  } else {
    // Throw an exception if the request failed
    throw Exception('Failed to load route');
  }
}

Future<LatLng> fetchRiderPosition(String riderId) async {
  // // Simulate a network call to fetch rider's position
  // // Replace this with your actual database/API call
  // final response =
  //     await http.get(Uri.parse('https://yourapi.com/rider/$riderId/position'));

  // if (response.statusCode == 200) {
  //   final data = json.decode(response.body);
  //   return LatLng(data['latitude'], data['longitude']);
  // } else {
  //   throw Exception('Failed to load rider position');
  // }

  var random = Random();
  // in range lat 16.250743 +- 0.05
  // in range long 103.24796 +- 0.05
  return LatLng(random.nextDouble() * 0.1 + 16.250743 - 0.05,
      random.nextDouble() * 0.1 + 103.24796 - 0.05);
}

Future<Map<String, LatLng>> fetchRiderPositions(List<String> riderIds) async {
  Map<String, LatLng> positions = {};
  for (String riderId in riderIds) {
    // // Simulate a network call to fetch each rider's position
    // // Replace this with your actual database/API call
    // final response = await http
    //     .get(Uri.parse('https://yourapi.com/rider/$riderId/position'));

    // if (response.statusCode == 200) {
    //   final data = json.decode(response.body);
    //   positions[riderId] = LatLng(data['latitude'], data['longitude']);
    // } else {
    //   throw Exception('Failed to load rider position for $riderId');
    // }
    var random = Random();
    positions[riderId] = LatLng(random.nextDouble() * 0.1 + 16.250743 - 0.05,
        random.nextDouble() * 0.1 + 103.24796 - 0.05);
  }
  return positions;
}

enum MapMode { select, route, tracks }

abstract class MapModeHandler {
  Widget buildMap(BuildContext context, LatLng initialPosition,
      LatLng selectedPosition, MapController mapController);
  void stop(); // Ensure all handlers implement stop
}

class SelectModeHandler extends MapModeHandler {
  final Function(LatLng) onSelectPosition;

  SelectModeHandler(this.onSelectPosition);

  @override
  Widget buildMap(BuildContext context, LatLng initialPosition,
      LatLng selectedPosition, MapController mapController) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialPosition,
        initialZoom: 16.0,
        onTap: (_, point) {
          onSelectPosition(point); // Call the callback with the new position
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: initialPosition, // My position
              child: const Icon(
                Icons.location_history,
                color: Colors.blue,
                size: 40,
              ),
            ),
            Marker(
              width: 80.0,
              height: 80.0,
              point: selectedPosition, // Selected position
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void stop() {
    // No resources to clean up in SelectModeHandler
  }
}

class RouteModeHandler extends MapModeHandler {
  final String riderId;
  final VoidCallback onUpdate;

  RouteModeHandler(this.riderId, this.onUpdate) {
    dev.log('RouteModeHandler created for riderId: $riderId');
    _initializePositions();
    _startTimer();
  }

  Timer? _timer;
  LatLng? myPosition;
  LatLng? riderPosition;
  List<LatLng>? route;
  bool _isDisposed = false;

  @override
  Widget buildMap(BuildContext context, LatLng initialPosition,
      LatLng selectedPosition, MapController mapController) {
    if (myPosition == null || riderPosition == null || route == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: myPosition!,
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // subdomains removed as per previous edits
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: route!,
              strokeWidth: 5.0,
              color: Colors.blue,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: myPosition!,
              child: const Icon(Icons.person_pin_circle,
                  color: Colors.green, size: 40),
            ),
            Marker(
              width: 80.0,
              height: 80.0,
              point: riderPosition!,
              child: const Icon(Icons.directions_bike,
                  color: Colors.red, size: 40), // Custom rider icon
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _initializePositions() async {
    Position myPos = await GeolocatorServices.getCurrentLocation();
    myPosition = LatLng(myPos.latitude, myPos.longitude);
    riderPosition = await fetchRiderPosition(riderId);

    try {
      route = await fetchRoute(riderPosition!, myPosition!);
    } catch (e) {
      dev.log('Error fetching route: $e');
      route = null;
    }

    onUpdate();
  }

  Future<void> _startTimer() async {
    dev.log('Starting RouteModeHandler timer');
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      try {
        Position myPos = await GeolocatorServices.getCurrentLocation();
        LatLng riderPos = await fetchRiderPosition(riderId);
        myPosition = LatLng(myPos.latitude, myPos.longitude);
        riderPosition = riderPos;
        dev.log('${DateTime.now()} Updated positions');

        // Fetch and update the route after position update
        try {
          route = await fetchRoute(riderPosition!, myPosition!);
          dev.log('${DateTime.now()} Updated route');
        } catch (e) {
          dev.log('Error fetching route: $e');
          route = null;
        }

        onUpdate();
      } catch (e) {
        dev.log('Error updating position: $e');
      }
    });
  }

  @override
  void stop() {
    dev.log('Stopping RouteModeHandler timer');
    _isDisposed = true;
    _timer?.cancel();
  }
}

class TracksModeHandler extends MapModeHandler {
  final List<String> riderIds;
  final VoidCallback onUpdate;

  TracksModeHandler(this.riderIds, this.onUpdate) {
    dev.log('TracksModeHandler created for riderIds: $riderIds');
    _initializePositions();
    _startTimer();
  }

  Timer? _timer;
  LatLng? myPosition;
  Map<String, LatLng> riderPositions = {};
  bool _isMapReady = false;
  bool _isLoading = true;
  bool _isDisposed = false;

  @override
  Widget buildMap(BuildContext context, LatLng initialPosition,
      LatLng selectedPosition, MapController mapController) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: myPosition ?? LatLng(0, 0),
        initialZoom: 13.0,
        onMapReady: () {
          _isMapReady = true;
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // subdomains removed as per previous edits
        ),
        MarkerLayer(
          markers: [
            if (myPosition != null)
              Marker(
                width: 80.0,
                height: 80.0,
                point: myPosition!,
                child: const Icon(Icons.person_pin_circle,
                    color: Colors.green, size: 40),
              ),
            ...riderIds.map((riderId) {
              int index = riderIds.indexOf(riderId);
              LatLng riderPosition = riderPositions[riderId] ?? LatLng(0, 0);
              Color riderColor =
                  Colors.primaries[index % Colors.primaries.length];
              return Marker(
                width: 80.0,
                height: 80.0,
                point: riderPosition,
                child: Icon(Icons.directions_bike, color: riderColor, size: 30),
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  void _initializePositions() async {
    dev.log('Initializing TracksModeHandler positions');
    try {
      Position myPos = await GeolocatorServices.getCurrentLocation();
      myPosition = LatLng(myPos.latitude, myPos.longitude);
      _isLoading = false; // Initial load complete
      onUpdate();
      dev.log('Initialized positions');
    } catch (e) {
      // Handle errors in fetching position
      _isLoading = false;
      dev.log('Error fetching initial position: $e');
      onUpdate();
    }
  }

  void _startTimer() {
    dev.log('Starting TracksModeHandler timer');
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isDisposed || !_isMapReady) return;
      try {
        Position myPos = await GeolocatorServices.getCurrentLocation();
        Map<String, LatLng> riderPos = await fetchRiderPositions(riderIds);
        myPosition = LatLng(myPos.latitude, myPos.longitude);
        riderPositions = riderPos;
        onUpdate();
        dev.log('${DateTime.now()} Updated positions');
      } catch (e) {
        dev.log('Error updating position: $e');
      }
    });
  }

  @override
  void stop() {
    dev.log('Stopping TracksModeHandler timer');
    _isDisposed = true;
    _timer?.cancel();
  }
}

class MapScreen extends StatefulWidget {
  final MapMode mode;
  final String? riderId;
  final List<String>? riderIds;

  const MapScreen(
      {super.key, this.mode = MapMode.select, this.riderId, this.riderIds});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng _selectedPosition = const LatLng(0.0, 0.0);
  LatLng? _initialPosition;
  bool _isLoading = true;
  String? _error;
  MapController mapController = MapController();
  late MapModeHandler modeHandler;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    modeHandler = _getModeHandler(widget.mode);
  }

  @override
  void dispose() {
    if (modeHandler is RouteModeHandler) {
      (modeHandler as RouteModeHandler).stop();
    }
    if (modeHandler is TracksModeHandler) {
      (modeHandler as TracksModeHandler).stop();
    }
    super.dispose();
    dev.log('MapScreen disposed');
  }

  void _determinePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      if (!_isDisposed) {
        setState(() {
          _initialPosition = LatLng(position.latitude, position.longitude);
          _selectedPosition =
              _initialPosition!; // Ensure _selectedPosition is set
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _error = 'An error occurred while fetching location: $e';
          _isLoading = false;
          _selectedPosition =
              const LatLng(0.0, 0.0); // Fallback to default if error
        });
      }
    }
  }

  bool _isDisposed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Additional initialization if needed
  }

  MapModeHandler _getModeHandler(MapMode mode) {
    switch (mode) {
      case MapMode.route:
        if (widget.riderId == null) {
          throw Exception('riderId must be provided for RouteMode');
        }
        return RouteModeHandler(widget.riderId!, () {
          if (mounted) {
            setState(() {});
          }
        });
      case MapMode.tracks:
        if (widget.riderIds == null) {
          throw Exception('riderIds must be provided for TracksMode');
        }
        return TracksModeHandler(widget.riderIds!, () {
          if (mounted) {
            setState(() {});
          }
        });
      case MapMode.select:
      default:
        return SelectModeHandler((LatLng newPosition) {
          setState(() {
            _selectedPosition = newPosition;
          });
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Map Screen'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Map Screen'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
        actions: widget.mode == MapMode.select
            ? [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    Navigator.pop(context,
                        _selectedPosition); // Return the selected position
                  },
                ),
              ]
            : null,
      ),
      body: Stack(
        children: [
          modeHandler.buildMap(context, _initialPosition ?? const LatLng(0, 0),
              _selectedPosition, mapController),
          if (widget.mode == MapMode.select)
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
          if (widget.mode == MapMode.select)
            Positioned(
              bottom: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.my_location, size: 40),
                onPressed: () {
                  setState(() {
                    mapController.move(_initialPosition!, 16.0);
                    mapController.rotate(0);
                    _selectedPosition = _initialPosition!;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
