import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:teste_voo/order_tracking_page.dart';

class MyLocation extends StatefulWidget {
  const MyLocation({super.key});

  @override
  State<MyLocation> createState() => _MyLocationState();
}

class _MyLocationState extends State<MyLocation> {
  Location location = Location();
  LocationData? _currentPosition;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      setState(() {
        getLoc();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [],
          backgroundColor: Colors.green,
          title: const Text('Teste da Vivi'),
        ),
        body: Container(
          width: 300,
          height: 300,
          color: Colors.indigo,
          child: Column(
            children: [
              if (_currentPosition != null)
                Text('${_currentPosition!.latitude}',
                    style: const TextStyle(color: Colors.white)),
              if (_currentPosition != null)
                Text('${_currentPosition!.longitude}',
                    style: const TextStyle(color: Colors.white)),
              if (_currentPosition != null)
                Text('${_currentPosition!.altitude}',
                    style: const TextStyle(color: Colors.white)),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OrderTrackingPage()));
                  _pressed = !_pressed;
                },
                child: const Text('Me aperte'),
              )
            ],
          ),
        ),
      ),
    );
  }

  getLoc() async {
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
    if (!_pressed) {
      _currentPosition = await location.getLocation();
    }
    //debugPrint(_currentPosition.toString());
  }
}
