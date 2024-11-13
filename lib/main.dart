import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:star_explorer/model/space_object_data_alt_az.dart';

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
  double alt = 0.0;
  double az = 0.0;
  double lat = 0.0;
  double lon = 0.0;
  double ra = 0.0;
  double dec = 0.0;
  double arrowAngle = 0.0;
  double azDSO = 0.0;
  double altDSO = 0.0;
  double arrowOpacity = 1;
  double pointX = 0.0;
  double pointY = 0.0;
  List<SpaceObjectDataAltAz> majorStars = [];
  List<SpaceObjectDataAltAz> majorDSO = [];

  Color nightSkyColor = Color.fromARGB(255, 5, 14, 57);

  List<double> _accelerometerValues = [0.0, 0.0, 0.0];
  final TextEditingController textController = TextEditingController();
  String objectName = "LOADING";

  @override
  void initState() {
    super.initState();

    updatePosition();
    updateSpaceObjectCoordinates('m31'); //base value

    accelerometerEvents.listen((AccelerometerEvent event) {
      int multiplier =
          60; // value for the distance for the arrow to "disappear"
      _accelerometerValues = [event.x, event.y, event.z];
      _updateOrientation();
      arrowAngle = calculateAngleFromSlope(193, 265, pointX, pointY);
      if (pointX > 193 - multiplier &&
          pointX < 193 + multiplier &&
          pointY > 265 - multiplier &&
          pointY < 265 + multiplier) {
        arrowOpacity = 0.1;
      } else {
        arrowOpacity = 1;
      }
    });

    // Listen to compass events for azimuth calculation
    FlutterCompass.events?.listen((CompassEvent event) {
      setState(() {
        az = event.heading ?? 0;
      });
    });

    Timer(Duration(seconds: 2), () {
      updateMajorStars();
    });

    Timer.periodic(Duration(seconds: 60), (Timer t) {
      updateMajorStars();
    });
  }

  void updateMajorStars() async {
    majorStars = await fetchMajorStarCoordinates(lat, lon);
    majorDSO = await fetchMajorDSOCoordinates(lat, lon);
  }

  void _updateOrientation() {
    setState(() {
      alt = calculateOrientation(_accelerometerValues);
      pointX = getPointX(az, azDSO, 365);
      pointY = getPointY(alt, altDSO, 530);
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
      updateMajorStars();
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

    setState(() {
      altDSO = altAz[0];
      azDSO = altAz[1];
    });

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
                height: 120,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textController,
                            decoration: InputDecoration(
                              labelText: "Insert DSO",
                              labelStyle: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 223, 222, 255)),
                            ),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$objectName \nAz: ${degreesToString(azDSO)} \nAlt: ${degreesToString(altDSO)}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Transform.rotate(
                    angle: arrowAngle + 3.141592 / 2,
                    child: Image.asset(
                      'assets/red_arrow.png',
                      width: 50,
                      height: 50,
                      color: Colors.red.withOpacity(arrowOpacity),
                    ),
                  ),
                ),
                Positioned(
                  left: pointX,
                  top: pointY,
                  child: Icon(
                    Icons.star,
                    size: 30,
                    color: Colors.blue,
                  ),
                ),
                Stack(
                    children: majorStars
                        .where((star) => star.name != objectName)
                        .map((star) => Positioned(
                              left: getPointXUnclamped(az, star.az, 365),
                              top: getPointYUnclamped(alt, star.alt, 530),
                              child: Icon(
                                Icons.circle,
                                size: 5,
                                color: Colors.black,
                              ),
                            ))
                        .toList()),
                Stack(
                    children: majorDSO
                        .where((dso) => dso.name != objectName)
                        .map((dso) => Positioned(
                            left: getPointXUnclamped(az, dso.az, 365),
                            top: getPointYUnclamped(alt, dso.alt, 530),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icon/galaxy.png',
                                  scale: 5,
                                  color: Colors.black,
                                ),
                                Text(dso.getName, style: TextStyle(fontSize: 8))
                              ],
                            )))
                        .toList()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: nightSkyColor,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Facing ${getCompassDirection(az)} (${degreesToString(az)})",
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
