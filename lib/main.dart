import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'package:flutter_compass/flutter_compass.dart';

import 'coordinate_converter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: StargazingApp(),
    );
  }
}

class StargazingApp extends StatefulWidget {
  const StargazingApp({super.key});

  @override
  _StargazingAppState createState() => _StargazingAppState();
}

class _StargazingAppState extends State<StargazingApp> {
  double _roll = 0.0;    // Roll (rotation around z-axis)
  double _azimuth = 0.0; // Azimuth (angle between phone's direction and magnetic north)

  List<double> _accelerometerValues = [0.0, 0.0, 0.0];

  @override
  void initState() {
    super.initState();

    // Listen to accelerometer events for roll calculation
    accelerometerEvents.listen((AccelerometerEvent event) {
      _accelerometerValues = [event.x, event.y, event.z];
      _updateOrientation();
    });

    // Listen to compass events for azimuth calculation
    FlutterCompass.events?.listen((CompassEvent event) {
      setState(() {
        _azimuth = event.heading ?? 0; // Heading might be null
      });
    });
  }

  void _updateOrientation() {
    setState(() {
      _calculateOrientation();
    });
  }

  void _calculateOrientation() {
    List<double> acc = _accelerometerValues;

    // Normalize accelerometer values
    double normAcc = sqrt(acc[0] * acc[0] + acc[1] * acc[1] + acc[2] * acc[2]);
    acc[0] = acc[0] / normAcc;
    acc[1] = acc[1] / normAcc;
    acc[2] = acc[2] / normAcc;

    // Calculate roll (rotation around y-axis)
    _roll = atan2(acc[1], acc[2]) * (180 / pi) - 90;
  }

  @override
  Widget build(BuildContext context) {
    List<double> altAzM31 = convertRaDecToAltAz(
    10.684799, // RA in degrees (M31)
    41.269076,  // Dec in degrees (M31)
    46.008774,  // Latitude (Lugano)
    8.957026,   // Longitude (Lugano)
    DateTime.now().toUtc()
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Orientation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Az M31: ${degreesToString(altAzM31[1])}'),
            Text('Alt M31: ${degreesToString(altAzM31[0])}'),
            Text('Azimuth: ${_azimuth.toStringAsFixed(2)}°'),
            Text('Altitude: ${_roll.toStringAsFixed(2)}°'),
          ],
        ),
      ),
    );
  }
}
