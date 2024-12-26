import 'dart:math';

String degreesToString(double degrees) {
  // converts degrees to a string in the format "degrees° minutes' seconds\""
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

List<double> convertRaDecToAltAz(double raDegrees, double dec, double latitude,
    double longitude, DateTime observationTime) {
  // returns a list containing [alt, az] of a celestial object from ra and dec, and the location and time
  double ra = raDegrees / 15.0;
  double gst = _calculateGST(observationTime);
  double lst = gst + longitude / 15.0;
  double hourAngle = (lst - ra) * 15.0;

  double haRad = hourAngle * pi / 180;
  double decRad = dec * pi / 180;
  double latRad = latitude * pi / 180;

  double altitude =
      asin(sin(decRad) * sin(latRad) + cos(decRad) * cos(latRad) * cos(haRad));
  double azimuth =
      atan2(-sin(haRad), tan(decRad) * cos(latRad) - sin(latRad) * cos(haRad));

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
  double normAcc = sqrt(accelerometerValues[0] * accelerometerValues[0] +
      accelerometerValues[1] * accelerometerValues[1] +
      accelerometerValues[2] * accelerometerValues[2]);
  accelerometerValues[0] = accelerometerValues[0] / normAcc;
  accelerometerValues[1] = accelerometerValues[1] / normAcc;
  accelerometerValues[2] = accelerometerValues[2] / normAcc;

  double res =
      atan2(accelerometerValues[1], accelerometerValues[2]) * (180 / pi) -
          90; // "- 90" to make 0° when phone is vertical

  // adjust if angle is below -90°
  if (res < -90) {
    res = -180 - res;
  }

  return res; // "- 90" to make 0° when phone is vertical
}

String getCompassDirection(double degrees) {
  if (degrees < 0 || degrees >= 360) {
    degrees = (degrees + 360) % 360;
  }

  if (degrees >= 337.5 || degrees < 22.5) {
    return "N";
  } else if (degrees >= 22.5 && degrees < 67.5) {
    return "NE";
  } else if (degrees >= 67.5 && degrees < 112.5) {
    return "E";
  } else if (degrees >= 112.5 && degrees < 157.5) {
    return "SE";
  } else if (degrees >= 157.5 && degrees < 202.5) {
    return "S";
  } else if (degrees >= 202.5 && degrees < 247.5) {
    return "SW";
  } else if (degrees >= 247.5 && degrees < 292.5) {
    return "W";
  } else {
    return "NW";
  }
}

double getSlope(double x1, double y1, double x2, double y2) {
  double dy = y2 - y1;
  double dx = x2 - x1;
  return dy / dx;
}

double getPointX(double degreesRotatingObject, double degreesDSO, double maxWidthScreen, double HFoV) {
  double degrees = degreesDSO - degreesRotatingObject;

  if (degrees > 180) {
    degrees -= 360;
} else if (degrees < -180) {
    degrees += 360;
}

  if (degrees >= HFoV) {
    return maxWidthScreen;
  } else if (degrees <= -HFoV) {
    return 0;
  } else if (degrees == 0) {
    return maxWidthScreen / 2;
  } else {
    return ((degrees + HFoV) / (2 * HFoV)) * maxWidthScreen;
  }
}

double getPointXUnclamped(double degreesRotatingObject, double degreesDSO, double maxWidthScreen, double HFov) {
  double res = getPointX(degreesRotatingObject, degreesDSO, maxWidthScreen, HFov);
  return res == 0 || res == maxWidthScreen ? maxWidthScreen + 100 : res;
}

double getPointY(double degreesRotatingObject, double degreesDSO, double maxHeightScreen, double VFov) {
  double degrees = degreesDSO - degreesRotatingObject;

  if (degrees >= VFov) {
    return 0;
  } else if (degrees <= -VFov) {
    return maxHeightScreen;
  } else if (degrees == 0) {
    return maxHeightScreen / 2;
  } else {
    return (1 -((degrees + VFov) / (2 * VFov))) * maxHeightScreen;
  }
}

double getPointYUnclamped(double degreesRotatingObject, double degreesDSO, double maxHeightScreen, double VFov) {
  double res = getPointY(degreesRotatingObject, degreesDSO, maxHeightScreen, VFov);
  return res == 0 || res == maxHeightScreen ? maxHeightScreen + 100 : res;
}


double calculateAngleFromSlope(double x1, double y1, double x2, double y2) {
  return atan2(y2 - y1, x2 - x1);
}

double magnitudeToSize(double m) {
  double absBrightestStarMag = 1.46; // sirius
  double shiftedMag = m + absBrightestStarMag;
  // if shiftedMag return maxSize, and higher that is, then lower the result. I created this function by myself using https://www.geogebra.org/calculator
  return (log(0.25 * shiftedMag + 0.0625) / log(0.5)) + 3;

}
