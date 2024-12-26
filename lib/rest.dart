import 'dart:convert';
import 'dart:io';
import 'package:star_explorer/calculator.dart';
import 'package:star_explorer/model/space_object_data.dart';
import 'dart:async';
import 'data/star_data.dart';
import 'data/DSO_data.dart';
import 'model/space_object_data_alt_az.dart';

final _client = HttpClient()
  ..connectionTimeout = const Duration(seconds: 30)
  ..idleTimeout = const Duration(seconds: 60);

Future<SpaceObjectData> fetchSpaceObjectCoordinates(String name) async {
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

Future<List<SpaceObjectDataAltAz>> fetchMajorStarCoordinates(double lat, double lon) async {
  const batchSize = 10;
  final results = <SpaceObjectDataAltAz>[];

  for (var i = 0; i < starNames.length; i += batchSize) {
    // proposto da Claude AI e poi adattato.
    // prende 10 elementi alla volta.
    // per ogniuno ricava altaz
    // lo ri fa con i prox 10 elementi

    final end = (i + batchSize < starNames.length) ? i + batchSize : starNames.length;
    final batch = starNames.sublist(i, end);

    final batchFutures = batch.map((starData) async {
      final star = await fetchSpaceObjectCoordinates(starData[0] as String);
      final altAz = convertRaDecToAltAz(star.ra, star.dec, lat, lon, DateTime.now().toUtc());
      return SpaceObjectDataAltAz(
          alt: altAz[0],
          az: altAz[1],
          name: star.getName,
          magnitude: starData[1] as double
      );
    }).toList();

    results.addAll(await Future.wait(batchFutures));

    if (end < starNames.length) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  return results;
}

Future<List<SpaceObjectDataAltAz>> fetchMajorDSOCoordinates(double lat, double lon) async {
  const batchSize = 5;
  final results = <SpaceObjectDataAltAz>[];
  for (var i = 0; i < dsoNames.length; i += batchSize) {
    // Funzionamento: simile al metodo sopra
    final end = (i + batchSize < dsoNames.length) ? i + batchSize : dsoNames.length;
    final batch = dsoNames.sublist(i, end);

    final batchFutures = batch.map((name) async {
      final dso = await fetchSpaceObjectCoordinates(name);
      final time = DateTime.now().toUtc();
      final altAz = convertRaDecToAltAz(dso.ra, dso.dec, lat, lon, time);
      return SpaceObjectDataAltAz(alt: altAz[0], az: altAz[1], name: dso.getName);
    }).toList();

    results.addAll(await Future.wait(batchFutures));

    if (end < dsoNames.length) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  return results;
}