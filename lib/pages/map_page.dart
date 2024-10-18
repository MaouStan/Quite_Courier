import 'dart:async';
import 'dart:developer' as dev;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:quite_courier/models/map_track_req.dart';
import 'package:quite_courier/services/geolocator_services.dart';
import 'package:quite_courier/services/map_service.dart';
import 'package:quite_courier/services/user_service.dart';

enum MapMode { select, route, tracks }

abstract class MapModeHandler {
  Widget buildMap(BuildContext context, LatLng initialPosition,
      LatLng selectedPosition, MapController mapController);
  void stop(); // Ensure all handlers implement stop
}

class SelectModeHandler extends MapModeHandler {
  final Function(LatLng) onSelectPosition;
  final StreamController<void> updateController;

  SelectModeHandler(this.onSelectPosition, this.updateController);

  @override
  Widget buildMap(BuildContext context, LatLng initialPosition,
      LatLng selectedPosition, MapController mapController) {
    return StreamBuilder<void>(
      stream: updateController.stream,
      builder: (context, snapshot) {
        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialPosition,
            initialZoom: 16.0,
            onTap: (_, point) {
              onSelectPosition(point);
              updateController.add(null); // Trigger update
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
                  point: initialPosition,
                  child: const Icon(
                    Icons.location_history,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: selectedPosition,
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
      },
    );
  }

  @override
  void stop() {
    // No resources to clean up in SelectModeHandler
  }
}

class RouteModeHandler extends MapModeHandler {
  final String riderTelephone;
  final StreamController<void> updateController;
  final LatLng orderPosition;

  RouteModeHandler(
      this.riderTelephone, this.updateController, this.orderPosition) {
    _initializePositions();
  }

  LatLng? myPosition;
  LatLng? riderPosition;
  List<LatLng>? route;
  bool _isDisposed = false;
  StreamSubscription? _positionSubscription;

  @override
  Widget buildMap(BuildContext context, LatLng initialPosition,
      LatLng selectedPosition, MapController mapController) {
    return StreamBuilder<void>(
      stream: updateController.stream,
      builder: (context, snapshot) {
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
                  color: Colors.blue,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: orderPosition,
                  child: const Icon(Icons.inventory_2_outlined,
                      color: Colors.green, size: 40),
                ),
                if (riderPosition != null)
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: riderPosition!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions_bike,
                            color: Colors.red, size: 40),
                        Text(
                          riderTelephone,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            backgroundColor: Colors.white70,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _initializePositions() async {
    try {
      myPosition = await GeolocatorServices.getCurrentLocation();
      _startPositionStream();
    } catch (e) {
      log('Error initializing positions: $e');
    }
  }

  void _startPositionStream() {
    _positionSubscription = UserService.getRiderPositionStream(riderTelephone)
        .listen((LatLng newPosition) {
      if (_isDisposed) return;
      log('newPosition: ${newPosition.toString()}');
      riderPosition = newPosition;
      _updateRoute();
    });
  }

  void _updateRoute() async {
    if (myPosition != null && riderPosition != null) {
      try {
        route = await MapService.fetchRoute(riderPosition!, orderPosition);
        updateController.add(null); // Trigger update
      } catch (e) {
        log('Error fetching route: $e');
      }
    }
  }

  @override
  void stop() {
    _isDisposed = true;
    _positionSubscription?.cancel();
  }
}

class TracksModeHandler extends MapModeHandler {
  List<MapTrackReqOrder> orders;
  final StreamController<void> updateController;

  TracksModeHandler(this.orders, this.updateController) {
    dev.log('TracksModeHandler created for orders: ${orders.length}');
    _initializePositions();
  }

  LatLng? myPosition;
  bool _isMapReady = false;
  bool _isLoading = true;
  bool _isDisposed = false;
  Timer? _updateTimer;
  Map<String, List<LatLng>> routes = {};

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

  final Map<String, Color> _riderColors = {};

  Color getColorForRider(String riderTelephone) {
    if (!_riderColors.containsKey(riderTelephone)) {
      int index = _riderColors.length % _colorOptions.length;
      _riderColors[riderTelephone] = _colorOptions[index].withOpacity(0.7);
    }
    return _riderColors[riderTelephone]!;
  }

  @override
  Widget buildMap(BuildContext context, LatLng initialPosition,
      LatLng selectedPosition, MapController mapController) {
    return StreamBuilder<void>(
      stream: updateController.stream,
      builder: (context, snapshot) {
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
            ),
            PolylineLayer(
              polylines: routes.entries.map((entry) {
                return Polyline(
                  points: entry.value,
                  strokeWidth: 3.0,
                  color: getColorForRider(entry.key),
                );
              }).toList(),
            ),
            MarkerLayer(
              markers: [
                ...orders.expand((order) => [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: order.orderPosition,
                        child: Icon(Icons.inventory_2_outlined,
                            color: getColorForRider(order.riderTelephone), size: 40),
                      ),
                      if (order.riderPosition != null)
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: order.riderPosition!,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions_bike,
                                  color: getColorForRider(order.riderTelephone), size: 30),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  order.riderTelephone,
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
                        ),
                    ]),
              ],
            ),
          ],
        );
      },
    );
  }

  void _initializePositions() async {
    dev.log('Initializing TracksModeHandler positions');
    try {
      myPosition = await GeolocatorServices.getCurrentLocation();
      _isLoading = false;
      updateController.add(null);
      _startUpdateTimer();
      dev.log('Initialized positions');
    } catch (e) {
      _isLoading = false;
      dev.log('Error fetching initial position: $e');
      updateController.add(null);
    }
  }

  void _startUpdateTimer() {
    dev.log('Starting TracksModeHandler timer');
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isDisposed || !_isMapReady) return;
      await _updateRiderPositionsAndRoutes();
    });
  }

  Future<void> _updateRiderPositionsAndRoutes() async {
    try {
      List<String> riderTelephones = orders.map((order) => order.riderTelephone).toList();
      Map<String, LatLng> newRiderPositions =
          await UserService.fetchRiderPositions(riderTelephones);

      for (var order in orders) {
        LatLng? newRiderPosition = newRiderPositions[order.riderTelephone];
        if (newRiderPosition != null && newRiderPosition != order.riderPosition) {
          order.riderPosition = newRiderPosition;
          routes[order.riderTelephone] = await MapService.fetchRoute(newRiderPosition, order.orderPosition);
        }
      }
      updateController.add(null);
    } catch (e) {
      dev.log('Error updating rider positions and routes: $e');
    }
  }

  @override
  void stop() {
    dev.log('Stopping TracksModeHandler timer');
    _isDisposed = true;
    _updateTimer?.cancel();
  }
}

class MapPage extends StatefulWidget {
  final MapMode mode;
  final String? riderTelephone;
  final LatLng? orderPosition;
  final List<MapTrackReqOrder>? orders;
  final LatLng? selectedPosition;

  const MapPage({
    super.key,
    this.mode = MapMode.select,
    this.riderTelephone,
    this.orderPosition,
    this.orders,
    this.selectedPosition,
  });

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late LatLng _selectedPosition;
  LatLng? _initialPosition;
  bool _isLoading = true;
  String? _error;
  MapController mapController = MapController();
  late MapModeHandler modeHandler;
  bool _isDisposed = false;

  // Add a StreamController to manage updates
  final StreamController<void> _updateController =
      StreamController<void>.broadcast();

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _selectedPosition = widget.selectedPosition ?? const LatLng(0.0, 0.0);
    modeHandler = _getModeHandler(widget.mode);
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (modeHandler is RouteModeHandler) {
      (modeHandler as RouteModeHandler).stop();
    }
    if (modeHandler is TracksModeHandler) {
      (modeHandler as TracksModeHandler).stop();
    }
    _updateController.close(); // Close the StreamController
    super.dispose();
    dev.log('MapPage disposed');
  }

  void _determinePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      if (!_isDisposed) {
        setState(() {
          _initialPosition = LatLng(position.latitude, position.longitude);
          if (widget.selectedPosition == null) {
            _selectedPosition =
                _initialPosition!; // Ensure _selectedPosition is set
          }
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

  MapModeHandler _getModeHandler(MapMode mode) {
    switch (mode) {
      case MapMode.route:
        if (widget.riderTelephone == null || widget.orderPosition == null) {
          Get.snackbar('Error',
              'riderTelephone and orderPosition must be provided for RouteMode');
          return SelectModeHandler(_onSelectPosition, _updateController);
        }
        return RouteModeHandler(
          widget.riderTelephone!,
          _updateController,
          widget.orderPosition!,
        );
      case MapMode.tracks:
        if (widget.orders == null || widget.orders!.isEmpty) {
          Get.snackbar('Error', 'orders must be provided for TracksMode');
          return SelectModeHandler(_onSelectPosition, _updateController);
        }
        return TracksModeHandler(widget.orders!, _updateController);
      case MapMode.select:
      default:
        return SelectModeHandler(_onSelectPosition, _updateController);
    }
  }

  void _onSelectPosition(LatLng newPosition) {
    setState(() {
      _selectedPosition = newPosition;
    });
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
                  onPressed: () => Navigator.pop(context, _selectedPosition),
                ),
              ]
            : null,
      ),
      body: StreamBuilder<void>(
        stream: _updateController.stream,
        builder: (context, snapshot) {
          return Stack(
            children: [
              modeHandler.buildMap(
                context,
                _initialPosition ?? const LatLng(0, 0),
                _selectedPosition,
                mapController,
              ),
              if (widget.mode == MapMode.select) ...[
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
            ],
          );
        },
      ),
    );
  }
}
