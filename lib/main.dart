import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:star_explorer/model/space_object_data_alt_az.dart';

import 'calculator.dart';
import 'location.dart';
import 'rest.dart';
import 'constants.dart';
import '/model/space_object_data.dart';

import 'components/custom_app_bar.dart';
import 'components/loading_widget.dart';
import 'components/error.dart';

import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
  bool search = false;

  double HorizontalFoV = 20.0; //default
  double VerticalFoV = 3.9; // default: Iphone 15

  List<double> _accelerometerValues = [0.0, 0.0, 0.0];
  TextEditingController textController = TextEditingController();
  String currentObjectName = "Andromeda galaxy";
  String currentObjectInput = "MESSIER 031";

  @override
  void initState() {
    super.initState();
    updatePosition();
    updateSpaceObjectCoordinates(currentObjectName); //base value

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

          if (delta > 160 &&
              delta < 200 &&
              !(pointingAz > -20 && pointingAz < 20)) {
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
    majorStars = fetchMajorStarCoordinates(deviceLatitude, deviceLongitude);
    majorDSO = fetchMajorDSOCoordinates(deviceLatitude, deviceLongitude);
  }

  void _updateOrientation() {
    setState(() {
      pointingAlt = isScreenCentered
          ? calculateOrientation(_accelerometerValues)
          : pointingAlt;
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
      textController.text = "";
      SpaceObjectData dso = await fetchSpaceObjectCoordinates(name);
      setState(() {
        spaceObjectRa = dso.getRa;
        spaceObjectDec = dso.getDec;
        currentObjectName = dso.getName;
        currentObjectInput = name.toUpperCase();
      });
      updateMajorStars();
    } catch (e) {
      Error('$e').showErrorDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    VerticalFoV = getVFov(HorizontalFoV);
    List<double> altAz = convertRaDecToAltAz(spaceObjectRa, spaceObjectDec,
        deviceLatitude, deviceLongitude, DateTime.now().toUtc());

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
              double dy = details.focalPointDelta.dy *
                  (sensibility / 2); // dy is more sensible
              isScreenCentered = false;
              double newAz = pointingAz - dx; // dx is reversed I think
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
            Container(
              color: nightSkyColor,
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 16),
                        Text(
                          "target:",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        SizedBox(width: 16),
                        Text(
                          currentObjectInput,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Color(0xFF0B3D91), Color(0xFF009AEE)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
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
                                      pointingAz, star.az, 365, HorizontalFoV
                                  ),
                                  top: getPointYUnclamped(
                                      pointingAlt, star.alt, 530, VerticalFoV
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      updateSpaceObjectCoordinates(star.name);
                                    },
                                    child: Image.asset(
                                      'assets/icon/star.png',
                                      scale: magnitudeToSize(
                                          star.magnitude as double
                                      ),
                                      color: Colors.white,
                                    ),
                                  ),
                                ))
                            .toList()),
                    Stack(
                        children: majorDSO
                            .where((dso) => dso.name != currentObjectName)
                            .map((dso) {
                      double scale = dso.type == "galaxy-cluster" ? 30.0 : 25.0;

                      double imageWidth = 512 / scale; // the image is 512x512
                      double imageHeight = 512 / scale;

                      double totalWidth = imageWidth + dso.getName.length * 4.0;

                      return Positioned(
                          // Offset position to center the combined image and text
                          left: getPointXUnclamped(
                                  pointingAz, dso.az, 365, HorizontalFoV) -
                              (totalWidth / 2),
                          top: getPointYUnclamped(
                                  pointingAlt, dso.alt, 530, VerticalFoV) -
                              (imageHeight / 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  updateSpaceObjectCoordinates(dso.name);
                                },
                                child: Image.asset(
                                  dso.type == "galaxy-cluster"
                                      ? 'assets/icon/galaxy-cluster.png'
                                      : 'assets/icon/galaxy.png',
                                  scale:
                                  dso.type == "galaxy-cluster" ? 30.0 : 25.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ));
                    }).toList()),
                    if (search)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: ImageIcon(
                                  AssetImage("assets/icon/search.png"), // Replace with your image path
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  updateSpaceObjectCoordinates(textController.text);
                                },
                              ),
                              Expanded(
                                child: TextField(
                                  controller: textController,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: "Search dso...",
                                    hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    updateSpaceObjectCoordinates(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: nightSkyColor,
        height: 120,
        child: Padding(
          padding: EdgeInsets.all(25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                         search = !search;
                      });
                    },
                    child: Image.asset(
                      'assets/icon/search.png',
                      scale: 20,
                      color: Colors.black,),
                  ),
                  Text(
                    "Search",
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isScreenCentered = !isScreenCentered;
                        if (!isScreenCentered) {
                          pointingAz = spaceObjectAz;
                          pointingAlt = spaceObjectAlt;
                        }
                      });
                    },
                    child: Image.asset(
                      'assets/icon/focus.png',
                      scale: 20,
                      color: Colors.black,),
                  ),
                  Text(
                    "Center ${isScreenCentered ? "view" : "phone"}",
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                ],
              ),
            ],
          )
        ),
      ),
    );
  }
}
