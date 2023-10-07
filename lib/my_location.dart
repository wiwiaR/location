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
  double latitudeAtual = 0;
  double longitudeAtual = 0;
  double altitudeAtual = 0;
  double solo = 0;
  String texto = '';
  int numero = 0;

  @override
  void initState() {
    getLoc();
    super.initState();
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
        body: Center(
          child: Column(
            children: [
              Text(
                '$latitudeAtual',
                style: const TextStyle(color: Colors.black),
              ),
              Text(
                '$longitudeAtual',
                style: const TextStyle(color: Colors.black),
              ),
              Text(
                '$altitudeAtual',
                style: const TextStyle(color: Colors.black),
              ),
              Text(
                texto,
                style: const TextStyle(color: Colors.black),
              ),
              ElevatedButton(
                onPressed: () {
                  getLoc();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderTrackingPage(),
                    ),
                  );
                },
                child: const Text('Me aperte'),
              ),
              ElevatedButton(
                onPressed: () {
                  addNumero();
                },
                child: const Text('Soma valor'),
              ),
              ElevatedButton(
                onPressed: () {
                  solo = altitudeAtual;
                  setState(() {});
                },
                child: const Text('Preparar para Voo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  addNumero() async {
    numero++;
    if (numero == 4) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Limite alcançado'),
          content: Text('Você alcançou o número $numero'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Ok'),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    }
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
    location.getLocation().then(
      (location) {
        _currentPosition = location;
      },
    );
    location.onLocationChanged.listen(
      (newLoc) {
        _currentPosition = newLoc;
        latitudeAtual = _currentPosition!.latitude!;
        longitudeAtual = _currentPosition!.longitude!;
        altitudeAtual = _currentPosition!.altitude!;
        setState(() {});
        if (altitudeAtual > solo + 15) {
          texto = 'Você está voando';
        } else {
          texto = 'Você está no chão';
        }
      },
    );
  }
}
