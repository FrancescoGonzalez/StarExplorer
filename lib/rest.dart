import 'dart:convert';
import 'dart:io';
import 'package:star_explorer/calculator.dart';
import 'package:star_explorer/model/space_object_data.dart';
import 'dart:async';
import 'data/star_data.dart';
import 'data/DSO_data.dart';
import 'model/space_object_data_alt_az.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final _client = HttpClient()
  ..connectionTimeout = const Duration(seconds: 30)
  ..idleTimeout = const Duration(seconds: 60);

Future<SpaceObjectData> fetchSpaceObjectCoordinates(String name) async {
  if (!(await checkConnection())) {
    throw Exception('No internet connection, connect and try again');
  }

  final url = 'https://ned.ipac.caltech.edu/srs/ObjectLookup';
  final body = jsonEncode({
    "name": {"v": name}
  });

  try {
    final request = await _client.postUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.write(body);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as Map<String, dynamic>;

      if (data["ResultCode"] == 3) {
        return SpaceObjectData(
          ra: ((data["Preferred"])["Position"])["RA"],
          dec: ((data["Preferred"])["Position"])["Dec"],
          name: data["Preferred"]["Name"],
        );
      } else {
        String message = '';

        switch (data["ResultCode"]) {
          case 0:
            message = '"$name" is not a valid DSO name';
            break;
          case 1:
            message = '"$name" is an ambiguous DSO name';
            break;
          case 2:
            message = 'Valid DSO name, but not in database';
            break;
          default:
            message = 'Unknown error';
        }

        throw Exception('Failed to load NED data: $message');
      }
    } else {
      throw Exception(
          'HTTP request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  }
}

Future<bool> checkConnection() async{
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.contains(ConnectivityResult.none)) {
    return false;
  }
  return true;
}

List<SpaceObjectDataAltAz> fetchMajorStarCoordinates(double lat, double lon) {
  List<SpaceObjectDataAltAz> res = [];
  for (Map<String, Object> star in starNames) {
    final altAz = convertRaDecToAltAz(star["ra"] as double, star["dec"] as double,
        lat, lon, DateTime.now().toUtc());
    res.add(new SpaceObjectDataAltAz(
        alt: altAz[0],
        az: altAz[1],
        name: star["name"] as String,
        magnitude: star["mag"] as double));
  }
  return res;
}

List<SpaceObjectDataAltAz> fetchMajorDSOCoordinates(double lat, double lon) {
  List<SpaceObjectDataAltAz> res = [];
  for (Map<String, Object> dso in dsoData) {
    final altAz = convertRaDecToAltAz(dso["ra"] as double, dso["dec"] as double,
        lat, lon, DateTime.now().toUtc());
    res.add(new SpaceObjectDataAltAz(
        alt: altAz[0],
        az: altAz[1],
        name: dso["name"] as String,
        magnitude: dso["mag"] as double,
        type: dso["type"] as String));
  }
  return res;
}
