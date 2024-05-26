import 'package:flutter/material.dart';
import 'package:vilnius100km/trail_map_screen.dart';

import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vilnius 100km',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Constants.primaryColor),
        useMaterial3: true,
      ),
      home: const TailMapScreen(),
    );
  }
}
