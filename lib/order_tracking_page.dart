import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(-3.8161324, -38.6228556);
  static const LatLng destination = LatLng(-3.7457883, -38.5428437);

  List<LatLng> rota = <LatLng>[];
  Set<Polyline> coordinates = {};
  bool pressed = false;

  @override
  void initState() {
    // getPolyPoints();
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
      ),
      body: currentLocation == null
          ? Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                child: const Text('Abrir mapa'),
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      currentLocation!.latitude!,
                      currentLocation!.longitude!,
                    ),
                    zoom: 13.5,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('currentLocation'),
                      position: LatLng(
                        currentLocation!.latitude!,
                        currentLocation!.longitude!,
                      ),
                    ),
                  },
                  onMapCreated: (mapController) {
                    _controller.complete(mapController);
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("route"),
                      points: polylineCoordinates,
                      color: const Color(0xFF7B61FF),
                      width: 6,
                    ),
                  },
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        pressed = !pressed;
                        getCurrentLocation();
                        debugPrint(pressed.toString());
                      },
                      child: const Text('Começar viagem'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Título'),
                            content: const Text('Corpo'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Ok'),
                                child: const Text('Ok'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Alerta'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  List<LatLng> polylineCoordinates = [];

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyB-lwcRd8iANVoEDwxkpCpht8d3B_Ay-Ms',
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) {
          polylineCoordinates.add(
            LatLng(
              point.latitude,
              point.longitude,
            ),
          );
        },
      );
      setState(() {});
    }
  }

  LocationData? currentLocation;

  void getCurrentLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.getLocation().then(
      (location) {
        currentLocation = location;
        if (rota.isEmpty) {
          rota.add(
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!));
        }
        setState(() {});
      },
    );

    GoogleMapController googleMapController = await _controller.future;
    double zoom = 0;
    googleMapController.getZoomLevel().then((value) => zoom = value);

    if (pressed) {
      location.onLocationChanged.listen(
        (newLoc) {
          currentLocation = newLoc;
          rota.add(LatLng(newLoc.latitude!, newLoc.longitude!));
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                zoom: zoom,
                target: LatLng(
                  newLoc.latitude!,
                  newLoc.longitude!,
                ),
              ),
            ),
          );

          setState(() {});
          // addPolyLines();
        },
      );
    }
  }

  void addPolyLines() async {
    Timer.periodic(
      const Duration(milliseconds: 1000),
      (timer) async {
        PolylinePoints polylinePoints = PolylinePoints();
        List<LatLng> polylineCoordinates = [];

        for (int i = 0; i < rota.length - 2; i++) {
          PolylineResult result =
              await polylinePoints.getRouteBetweenCoordinates(
            'AIzaSyB-lwcRd8iANVoEDwxkpCpht8d3B_Ay-Ms',
            PointLatLng(rota[i].latitude, rota[i].longitude),
            PointLatLng(rota[++i].latitude, rota[++i].longitude),
          );
          if (result.points.isNotEmpty) {
            result.points.forEach(
              (PointLatLng point) {
                polylineCoordinates
                    .add(LatLng(point.latitude, point.longitude));
              },
            );
          }
        }

        setState(
          () {
            coordinates.add(
              Polyline(
                polylineId: const PolylineId('rota'),
                color: Colors.green,
                width: 5,
                points: polylineCoordinates,
              ),
            );
          },
        );
      },
    );
  }
}
