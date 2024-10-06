import 'dart:developer' as dev;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quite_courier/services/geolocator_services.dart';
import 'package:quite_courier/services/map_service.dart'; // {{ edit_1: Import MapService }}
import 'package:quite_courier/services/user_service.dart'; // {{ edit_2: Import UserService }}

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
  final bool focusOnRider;
  final LatLng orderPosition; // Add order position

  RouteModeHandler(this.riderId, this.onUpdate, this.orderPosition,
      {this.focusOnRider = false}) {
    dev.log('RouteModeHandler created for riderId: $riderId');
    // _initializePositions();
    _startTimer();
    allowUpdate = true;
  }

  Timer? _timer;
  LatLng? myPosition;
  LatLng? riderPosition;
  List<LatLng>? route;
  bool _isDisposed = false;
  bool allowUpdate = false;

  static final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.amber,
    Colors.teal,
    Colors.indigo,
    Colors.lime,
  ];

  Color get routeColor {
    int hash = riderId.hashCode;
    int index = hash % _colorOptions.length;
    return _colorOptions[index].withOpacity(0.7);
  }

  @override
  Widget buildMap(BuildContext context, LatLng initialPosition,
      LatLng selectedPosition, MapController mapController) {
    if (route == null) {
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
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: route!,
              strokeWidth: 5.0,
              color: Colors.green,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: myPosition!,
              child: focusOnRider
                  ? const Icon(Icons.directions_bike,
                      color: Colors.green, size: 40)
                  : const Icon(Icons.person_pin_circle,
                      color: Colors.green, size: 40),
            ),
            Marker(
              width: 80.0,
              height: 80.0,
              point: focusOnRider ? orderPosition : riderPosition!,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  focusOnRider
                      ? const Icon(Icons.person_pin_circle,
                          color: Colors.red, size: 40)
                      : const Icon(Icons.directions_bike,
                          color: Colors.red, size: 40),
                  Text(
                    riderId,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _initializePositions() async {
    // try {
    //   allowUpdate = false;
    //   Position myPos = await GeolocatorServices.getCurrentLocation();
    //   myPosition = LatLng(myPos.latitude, myPos.longitude);
    //   dev.log('${DateTime.now()} Updated positions');

    //   try {
    //     if (!focusOnRider) {
    //       LatLng riderPos = await UserService.fetchRiderPosition(riderId);
    //       riderPosition = riderPos;
    //       route = await MapService.fetchRoute(
    //           myPosition!, riderPosition!); // Update route to order position
    //     } else {
    //       route = await MapService.fetchRoute(
    //           myPosition!, orderPosition); // Update route to order position
    //     }
    //   } catch (e) {
    //     dev.log('Error fetching route: $e');
    //     route = null;
    //   }
    // } catch (e) {
    //   dev.log('Error initializing positions: $e');
    // }
    // await Future.delayed(const Duration(seconds: 3));
    // allowUpdate = true;
    // onUpdate();
  }

  void _startTimer() {
    dev.log('Starting RouteModeHandler timer');
    _timer = Timer.periodic(const Duration(seconds: 0), (timer) async {
      if (!allowUpdate) return;

      if (_isDisposed) {
        timer.cancel();
        return;
      }
      try {
        allowUpdate = false;
        Position myPos = await GeolocatorServices.getCurrentLocation();
        myPosition = LatLng(myPos.latitude, myPos.longitude);
        dev.log('${DateTime.now()} Updated positions');

        try {
          if (!focusOnRider) {
            LatLng riderPos = await UserService.fetchRiderPosition(riderId);
            riderPosition = riderPos;
            route = await MapService.fetchRoute(
                myPosition!, riderPosition!); // Update route to order position
          } else {
            route = await MapService.fetchRoute(
                myPosition!, orderPosition); // Update route to order position
          }
          dev.log('${DateTime.now()} Updated route');
        } catch (e) {
          dev.log('Error fetching route: $e');
          route = null;
        }

        // Move the map center to the rider's current position if focusOnRider is true
        // if (focusOnRider) {
        // mapController.move(riderPosition!, mapController.camera.zoom);
        // }
        onUpdate();
        await Future.delayed(const Duration(seconds: 5));
        allowUpdate = true;
      } catch (e) {
        dev.log('Error updating position: $e');
      }
    });
  }

  @override
  void stop() {
    dev.log('Stopping RouteModeHandler timer');
    _isDisposed = true;
    allowUpdate = false;
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
    allowUpdate = false;
  }

  Timer? _timer;
  LatLng? myPosition;
  Map<String, LatLng> riderPositions = {};
  Map<String, List<LatLng>> routes = {};
  bool _isMapReady = false;
  bool _isLoading = true;
  bool _isDisposed = false;
  bool allowUpdate = false; // {{ edit_6: Declare allowUpdate }}

  // {{ edit_5: Define a static list of colors }}
  static final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.amber,
    Colors.teal,
    Colors.indigo,
    Colors.lime,
  ];

  // {{ edit_6: Assign colors to each riderId }}
  final Map<String, Color> _riderColors = {};

  Color getColorForRider(String riderId) {
    if (_riderColors.containsKey(riderId)) {
      return _riderColors[riderId]!;
    } else {
      int hash = riderId.hashCode;
      int index = hash % _colorOptions.length;
      Color color = _colorOptions[index].withOpacity(0.7);
      _riderColors[riderId] = color;
      return color;
    }
  }

  @override
  Widget buildMap(BuildContext context, LatLng initialPosition,
      LatLng selectedPosition, MapController mapController) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: myPosition ?? const LatLng(0, 0),
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
        // {{ edit_7: Render routes for each rider with unique colors }}
        ...routes.entries.map((entry) => PolylineLayer(
              polylines: [
                Polyline(
                  points: entry.value,
                  strokeWidth: 3.0,
                  color: getColorForRider(entry.key),
                ),
              ],
            )),
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
              LatLng riderPosition =
                  riderPositions[riderId] ?? const LatLng(0, 0);
              Color riderColor =
                  _riderColors[riderId] ?? getColorForRider(riderId);
              return Marker(
                width: 80.0,
                height: 80.0,
                point: riderPosition,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_bike, color: riderColor, size: 30),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        riderId, // Display riderId below the icon
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  void _initializePositions() async {
    dev.log('Initializing TracksModeHandler positions');
    try {
      Position myPos = await GeolocatorServices.getCurrentLocation();
      allowUpdate = false;
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
    allowUpdate = true;
  }

  void _startTimer() {
    dev.log('Starting TracksModeHandler timer');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_isDisposed || !_isMapReady || !allowUpdate) {
        return;
      }
      allowUpdate = false;
      try {
        Position myPos = await GeolocatorServices.getCurrentLocation();
        myPosition = LatLng(myPos.latitude, myPos.longitude);
        Map<String, LatLng> riderPos = await UserService.fetchRiderPositions(
            riderIds); // {{ edit_9: Use UserService }}
        riderPositions = riderPos;
        dev.log('${DateTime.now()} Updated positions');

        // Fetch and update routes for each rider
        // for (String riderId in riderIds) {
        //   try {
        //     List<LatLng> route = await MapService.fetchRoute(riderPositions[riderId]!, myPosition!); // {{ edit_10: Use MapService }}
        //     routes[riderId] = route;
        //     dev.log('${DateTime.now()} Updated route for $riderId');
        //   } catch (e) {
        //     dev.log('Error fetching route for $riderId: $e');
        //     routes.remove(riderId); // Remove route if fetching fails
        //   }
        // }

        onUpdate();
        await Future.delayed(const Duration(seconds: 3));
        allowUpdate = true;
      } catch (e) {
        dev.log('Error updating position: $e');
      }
    });
  }

  @override
  void stop() {
    dev.log('Stopping TracksModeHandler timer');
    _isDisposed = true;
    allowUpdate = false; // {{ edit_8: Disable updates after stopping }}
    _timer?.cancel();
  }
}

class MapPage extends StatefulWidget {
  final MapMode mode;
  final String? riderId;
  final List<String>? riderIds;
  final bool focusOnRider;
  final LatLng? orderPosition;

  const MapPage(
      {super.key,
      this.mode = MapMode.select,
      this.riderId,
      this.riderIds,
      this.focusOnRider = false,
      this.orderPosition});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late LatLng _selectedPosition = const LatLng(0.0, 0.0);
  LatLng? _initialPosition;
  bool _isLoading = true;
  String? _error;
  MapController mapController = MapController();
  late MapModeHandler modeHandler;

  bool _isDisposed = false; // {{ edit_9: Add disposal flag }}

  @override
  void initState() {
    super.initState();
    _determinePosition();
    modeHandler =
        _getModeHandler(widget.mode, widget.focusOnRider, widget.orderPosition);
  }

  @override
  void dispose() {
    _isDisposed = true; // {{ edit_10: Set disposal flag }}
    if (modeHandler is RouteModeHandler) {
      (modeHandler as RouteModeHandler).stop();
    }
    if (modeHandler is TracksModeHandler) {
      (modeHandler as TracksModeHandler).stop();
    }
    super.dispose();
    dev.log('MapPage disposed');
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

  MapModeHandler _getModeHandler(
      MapMode mode, bool focusOnRider, LatLng? orderPosition) {
    switch (mode) {
      case MapMode.route:
        if (widget.riderId == null) {
          throw Exception('riderId must be provided for RouteMode');
        }

        return RouteModeHandler(widget.riderId!, () {
          if (mounted) {
            setState(() {});
          }
        }, orderPosition ?? const LatLng(0, 0),
            focusOnRider: focusOnRider); // Pass order position
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
