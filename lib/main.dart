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

  bool centered = true;

  double HorizontalFoV = 20.0; //default
  double VerticalFoV = 3.9; // default: Iphone 15

  Color nightSkyColor = Color.fromARGB(255, 5, 14, 57);

  List<double> _accelerometerValues = [0.0, 0.0, 0.0];
  TextEditingController textController = TextEditingController();
  String objectName = "LOADING";

  @override
  void initState() {
    super.initState();
    updatePosition();
    updateSpaceObjectCoordinates('m31'); //base value

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
        if (centered) {
          double newAz = event.heading ?? 0;
          double diff = (newAz - az).abs();

          if (diff > 160 && diff < 200 && !(az > -20 && az < 20)) {
            az = (newAz + 180) % 360;
          } else {
            az = newAz;
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
    majorStars = await fetchMajorStarCoordinates(lat, lon);
    majorDSO = await fetchMajorDSOCoordinates(lat, lon);
  }

  void _updateOrientation() {
    setState(() {
      alt = centered ? calculateOrientation(_accelerometerValues) : alt;
      pointX = getPointX(az, azDSO, 365, HorizontalFoV);
      pointY = getPointY(alt, altDSO, 490, VerticalFoV);
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
      Error('$e').showErrorDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    VerticalFoV = getVFov(HorizontalFoV);
    List<double> altAz =
    convertRaDecToAltAz(ra, dec, lat, lon, DateTime.now().toUtc());

    setState(() {
      altDSO = altAz[0];
      azDSO = altAz[1];
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
              double dy = details.focalPointDelta.dy * (sensibility / 2);
              centered = false;
              double newAz = az - dx; // dx is reversed i think
              az = (newAz + 360) % 360;

              double newAlt = alt + dy;
              if (newAlt < 90 || newAlt > -90) {
                alt = newAlt;
              }

            }
          });
        },
        child: Column(
          children: [
            CustomNav(
                objectName,
                degreesToString(altDSO),
                degreesToString(azDSO),
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
                            .where((star) => star.name != objectName)
                            .map((star) => Positioned(
                          left: getPointXUnclamped(
                              az, star.az, 365, HorizontalFoV),
                          top: getPointYUnclamped(
                              alt, star.alt, 530, VerticalFoV),
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
                            .where((dso) => dso.name != objectName)
                            .map((dso) => Positioned(
                            left: getPointXUnclamped(
                                az, dso.az, 365, HorizontalFoV),
                            top: getPointYUnclamped(
                                alt, dso.alt, 530, VerticalFoV),
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
                    if (!centered)
                      Positioned(
                        left: 139,
                        top: 469,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              centered = true; // Hide the button when pressed
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
      CustomFooter(getCompassDirection(az), degreesToString(az)),
    );
  }
}