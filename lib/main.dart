import 'package:flutter/material.dart';
import 'package:teste_voo/order_tracking_page.dart';

import 'my_location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyLocation(),
    );
  }
}
