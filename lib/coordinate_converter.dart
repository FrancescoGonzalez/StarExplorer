import 'dart:math';

String degreesToString(double degrees) {
  int wholeDegrees = degrees.toInt();
  double fractionalPart = (degrees - wholeDegrees).abs();

  int minutes = (fractionalPart * 60).toInt();
  double secondsFractional = (fractionalPart * 60) - minutes;
  int seconds = (secondsFractional * 60).round();

  // Handle rounding of seconds
  if (seconds == 60) {
    minutes += 1;
    seconds = 0;
  }

  // Handle overflow of minutes to degrees
  if (minutes == 60) {
    wholeDegrees += 1;
    minutes = 0;
  }

  // Construct the string result
  return "$wholeDegrees° $minutes' $seconds\"";
}

List<double> convertRaDecToAltAz(double raDegrees, double dec, double latitude, double longitude, DateTime observationTime) {
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

// temporaneo
void main() {
  List<double> altAzM31 = convertRaDecToAltAz(
    10.684799, // RA in degrees (M31)
    41.269076,  // Dec in degrees (M31)
    46.008774,  // Latitude (Lugano)
    8.957026,   // Longitude (Lugano)
    DateTime.now().toUtc()
  );

  print("Alt = ${degreesToString(altAzM31[0])}");
  print("Az = ${degreesToString(altAzM31[1])}");
}
