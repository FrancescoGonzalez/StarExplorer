import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import 'calculator.dart';
import 'location.dart';
import 'rest.dart';
import '/model/space_object_data.dart';

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
  double _roll = 0.0;
  double _azimuth = 0.0;
  double lat = 0.0;
  double lon = 0.0;
  double ra = 0.0;
  double dec = 0.0;

  Color nightSkyColor = Color.fromARGB(255, 5, 14, 57);

  List<double> _accelerometerValues = [0.0, 0.0, 0.0];
  final TextEditingController textController = TextEditingController();
  String objectName = "M 31";

  @override
  void initState() {
    super.initState();

    updatePosition();
    updateSpaceObjectCoordinates('M31'); //base value

    // Listen to accelerometer events for roll calculation
    accelerometerEvents.listen((AccelerometerEvent event) {
      _accelerometerValues = [event.x, event.y, event.z];
      _updateOrientation();
    });

    // Listen to compass events for azimuth calculation
    FlutterCompass.events?.listen((CompassEvent event) {
      setState(() {
        _azimuth = event.heading ?? 0;
      });
    });
  }

  void _updateOrientation() {
    setState(() {
      _roll = calculateOrientation(_accelerometerValues);
    });
  }

  void updatePosition() async {
    try {
      Position p = await getCurrentPosition();
      setState(() {
        lat = p.latitude;
        lon = p.longitude;
      });
    } catch (e) {
      print('Error getting position: $e');
    }
  }

  void updateSpaceObjectCoordinates(String name) async {
    try {
      SpaceObjectData dso = await fetchSpaceObjectCoordinates(name);
      setState(() {
        ra = dso.getRa;
        dec = dso.getDec;
      });
    } catch (e) {
      print('Error getting space object coordinates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<double> altAz =
        convertRaDecToAltAz(ra, dec, lat, lon, DateTime.now().toUtc());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Star Explorer'),
        titleTextStyle: TextStyle(
            color: const Color.fromARGB(225, 22, 106, 151),
            fontSize: 24,
            fontWeight: FontWeight.bold),
        backgroundColor: nightSkyColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Az $objectName: ${degreesToString(altAz[1])}'),
            Text('Alt $objectName: ${degreesToString(altAz[0])}'),
            Text('Az phone: ${degreesToString(_azimuth)}'),
            Text('Alt phone: ${degreesToString(_roll)}'),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: nightSkyColor,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SizedBox(
            width: 200,
            height: 130,
            child: Column(
              children: [
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                      labelText: "Insert DSO",
                      labelStyle: TextStyle(color: const Color.fromARGB(255, 223, 222, 255))),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                    onPressed: () {
                      updateSpaceObjectCoordinates(textController.text);
                      objectName = textController.text;
                    },
                    child: Text("Send",)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
