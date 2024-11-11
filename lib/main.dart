import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
      home: StarExplorerApp(),
    );
  }
}

class StarExplorerApp extends StatefulWidget {
  const StarExplorerApp({super.key});

  @override
  StarExplorerAppState createState() => StarExplorerAppState();
}

class StarExplorerAppState extends State<StarExplorerApp> {
  double _roll = 0.0;
  double _azimuth = 0.0;
  double lat = 0.0;
  double lon = 0.0;
  double ra = 0.0;
  double dec = 0.0;

  Color nightSkyColor = Color.fromARGB(255, 5, 14, 57);

  List<double> _accelerometerValues = [0.0, 0.0, 0.0];
  final TextEditingController textController = TextEditingController();
  String objectName = "LOADING";

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
      throw Exception(e);
    }
  }

  void updateSpaceObjectCoordinates(String name) async {
    try {
      SpaceObjectData dso = await fetchSpaceObjectCoordinates(name);
      setState(() {
        ra = dso.getRa;
        dec = dso.getDec;
        objectName = dso.getName;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Error'),
            content: Text('$e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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
      body: Column(
        children: [
          Container(
            color: nightSkyColor,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          labelText: "Insert DSO",
                          labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 223, 222, 255)),
                        ),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        updateSpaceObjectCoordinates(textController.text);
                      },
                      child: Text("Send"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Az $objectName: ${degreesToString(altAz[1])}',
              ),
              Text(
                'Alt $objectName: ${degreesToString(altAz[0])}',
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: nightSkyColor,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Facing ${getCompassDirection(_azimuth)} (${degreesToString(_azimuth)})",
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
