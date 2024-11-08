import 'dart:math';

String degreesToString(double degrees) { // converts degrees to a string in the format "degrees° minutes' seconds\""
  int wholeDegrees = degrees.toInt();
  double fractionalPart = (degrees - wholeDegrees).abs();

  int minutes = (fractionalPart * 60).toInt();
  double secondsFractional = (fractionalPart * 60) - minutes;
  int seconds = (secondsFractional * 60).round();

  if (seconds == 60) {
    minutes += 1;
    seconds = 0;
  }

  if (minutes == 60) {
    wholeDegrees += 1;
    minutes = 0;
  }

  return "$wholeDegrees° $minutes' $seconds\"";
}

List<double> convertRaDecToAltAz(double raDegrees, double dec, double latitude, double longitude, DateTime observationTime) { 
  // returns a list containing [alt, az] of a celestial object from ra and dec, and the location and time
  double ra = raDegrees / 15.0;
  double gst = _calculateGST(observationTime);
  double lst = gst + longitude / 15.0;
  double hourAngle = (lst - ra) * 15.0;

  double haRad = hourAngle * pi / 180;
  double decRad = dec * pi / 180;
  double latRad = latitude * pi / 180;

  double altitude = asin(sin(decRad) * sin(latRad) + cos(decRad) * cos(latRad) * cos(haRad));
  double azimuth = atan2(
    -sin(haRad),
    tan(decRad) * cos(latRad) - sin(latRad) * cos(haRad)
  );

  altitude = altitude * 180 / pi;
  azimuth = azimuth * 180 / pi;

  if (azimuth < 0) {
    azimuth += 360;
  }

  return [altitude, azimuth];
}

double _calculateGST(DateTime observationTime) {
  DateTime j2000 = DateTime.utc(2000, 1, 1, 12, 0, 0);

  double daysSinceJ2000 = observationTime.difference(j2000).inSeconds / 86400.0;
  double gst = 18.697374558 + 24.06570982441908 * daysSinceJ2000;
  gst %= 24;
  if (gst < 0) {
    gst += 24;
  }

  return gst;
}

double calculateOrientation(List<double> accelerometerValues) {

    // Normalize accelerometer values
    double normAcc = sqrt(accelerometerValues[0] * accelerometerValues[0] + accelerometerValues[1] * accelerometerValues[1] + accelerometerValues[2] * accelerometerValues[2]);
    accelerometerValues[0] = accelerometerValues[0] / normAcc;
    accelerometerValues[1] = accelerometerValues[1] / normAcc;
    accelerometerValues[2] = accelerometerValues[2] / normAcc;

    double res = atan2(accelerometerValues[1], accelerometerValues[2]) * (180 / pi) - 90; // "- 90" to make 0° when phone is vertical

    // adjust if angle is below -90°
    if (res < -90) {
      res = -180 - res;
    }

    return res; // "- 90" to make 0° when phone is vertical
  }
