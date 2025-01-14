import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:star_explorer/model/space_object_data_alt_az.dart';

import 'calculator.dart';
import 'location.dart';
import 'rest.dart';
import '/model/space_object_data.dart';

import 'components/custom_app_bar.dart';
import 'components/custom_footer.dart';
import 'components/custom_nav.dart';
import 'components/loading_widget.dart';
import 'components/error.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  double pointingAlt = 0.0;
  double pointingAz = 0.0;
  double deviceLatitude = 0.0;
  double deviceLongitude = 0.0;
  double spaceObjectRa = 0.0;
  double spaceObjectDec = 0.0;
  double arrowAngle = 0.0;
  double spaceObjectAz = 0.0;
  double spaceObjectAlt = 0.0;
  double arrowOpacity = 1;
  double pointX = 0.0;
  double pointY = 0.0;
  List<SpaceObjectDataAltAz> majorStars = [];
  List<SpaceObjectDataAltAz> majorDSO = [];

  bool isScreenCentered = true;

  double HorizontalFoV = 20.0; //default
  double VerticalFoV = 3.9; // default: Iphone 15

  Color nightSkyColor = Color.fromARGB(255, 5, 14, 57);

  List<double> _accelerometerValues = [0.0, 0.0, 0.0];
  TextEditingController textController = TextEditingController();
  String currentObjectName = "";

  @override
  void initState() {
    super.initState();
    updatePosition();
    updateSpaceObjectCoordinates('M31'); //base value

    accelerometerEventStream().listen((AccelerometerEvent event) {
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
        if (isScreenCentered) {
          double newAz = event.heading ?? 0;
          double delta = (newAz - pointingAz).abs();

          if (delta > 160 && delta < 200 && !(pointingAz > -20 && pointingAz < 20)) {
            pointingAz = (newAz + 180) % 360;
          } else {
            pointingAz = newAz;
          }
        }
      });
    });

    Timer(Duration(seconds: 2), () {
      updateMajorStars();
    });

    Timer.periodic(Duration(seconds: 60), (Timer t) {
      updateMajorStars();
    });
  }

  double getVFov(double HFov) {
    double aspectRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;
    return HFov / aspectRatio;
  }

  void updateMajorStars() async {
    majorStars = await fetchMajorStarCoordinates(deviceLatitude, deviceLongitude);
    majorDSO = await fetchMajorDSOCoordinates(deviceLatitude, deviceLongitude);
  }

  void _updateOrientation() {
    setState(() {
      pointingAlt = isScreenCentered ? calculateOrientation(_accelerometerValues) : pointingAlt;
      pointX = getPointX(pointingAz, spaceObjectAz, 365, HorizontalFoV);
      pointY = getPointY(pointingAlt, spaceObjectAlt, 490, VerticalFoV);
    });
  }

  void updatePosition() async {
    try {
      Position p = await getCurrentPosition();
      setState(() {
        deviceLatitude = p.latitude;
        deviceLongitude = p.longitude;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  void updateSpaceObjectCoordinates(String name) async {
    try {
      SpaceObjectData dso = await fetchSpaceObjectCoordinates(name);
      setState(() {
        spaceObjectRa = dso.getRa;
        spaceObjectDec = dso.getDec;
        currentObjectName = dso.getName;
      });
      updateMajorStars();
    } catch (e) {
      Error('$e').showErrorDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    VerticalFoV = getVFov(HorizontalFoV);
    List<double> altAz =
    convertRaDecToAltAz(spaceObjectRa, spaceObjectDec, deviceLatitude, deviceLongitude, DateTime.now().toUtc());

    setState(() {
      spaceObjectAlt = altAz[0];
      spaceObjectAz = altAz[1];
    });

    if (majorDSO.isEmpty) {
      return LoadingPage();
    }
    return Scaffold(
      appBar: CustomAppBar(),
      body: GestureDetector(
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            if (details.scale != 1) {
              if (details.scale < 1 && HorizontalFoV <= 49) {
                HorizontalFoV += 0.5;
              } else if (details.scale > 1 && HorizontalFoV >= 11) {
                HorizontalFoV -= 0.5;
              }
              VerticalFoV = getVFov(HorizontalFoV);
            } else {
              double sensibility = 0.2;
              double dx = details.focalPointDelta.dx * sensibility;
              double dy = details.focalPointDelta.dy * (sensibility / 2); // dy is more sensib
              isScreenCentered = false;
              double newAz = pointingAz - dx; // dx is reversed i think
              pointingAz = (newAz + 360) % 360;

              double newAlt = pointingAlt + dy;
              if (newAlt < 90 || newAlt > -90) {
                pointingAlt = newAlt;
              }
            }
          });
        },
        child: Column(
          children: [
            CustomNav(
                currentObjectName,
                degreesToString(spaceObjectAlt),
                degreesToString(spaceObjectAz),
                textController,
                ElevatedButton(
                  onPressed: () {
                    updateSpaceObjectCoordinates(textController.text);
                  },
                  child: Text("Send"),
                )),
            Expanded(
              child: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    Center(
                      child: Transform.rotate(
                        angle: arrowAngle + 3.141592 / 2,
                        child: Image.asset(
                          'assets/red_arrow.png',
                          width: 50,
                          height: 50,
                          color: Color.fromRGBO(255, 255, 0, arrowOpacity),
                        ),
                      ),
                    ),
                    Positioned(
                      left: pointX,
                      top: pointY,
                      child: Image.asset(
                        'assets/icon/target.png',
                        scale: 15,
                        color: Colors.red,
                      ),
                    ),
                    Stack(
                        children: majorStars
                            .where((star) => star.name != currentObjectName)
                            .map((star) => Positioned(
                          left: getPointXUnclamped(
                              pointingAz, star.az, 365, HorizontalFoV),
                          top: getPointYUnclamped(
                              pointingAlt, star.alt, 530, VerticalFoV),
                          child: Icon(
                            Icons.circle,
                            size: magnitudeToSize(
                                star.magnitude as double),
                            color: Colors.white,
                          ),
                        ))
                            .toList()),
                    Stack(
                        children: majorDSO
                            .where((dso) => dso.name != currentObjectName)
                            .map((dso) => Positioned(
                            left: getPointXUnclamped(
                                pointingAz, dso.az, 365, HorizontalFoV),
                            top: getPointYUnclamped(
                                pointingAlt, dso.alt, 530, VerticalFoV),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icon/galaxy.png',
                                  scale: 5,
                                  color: Colors.white,
                                ),
                                Text(dso.getName,
                                    style: TextStyle(
                                        fontSize: 8, color: Colors.white))
                              ],
                            )))
                            .toList()),
                    if (!isScreenCentered)
                      Positioned(
                        left: 139,
                        top: 469,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isScreenCentered = true; // Hide the button when pressed
                            });
                          },
                          child: Text('Center view'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
      CustomFooter(getCompassDirection(pointingAz), degreesToString(pointingAz)),
    );
  }
}