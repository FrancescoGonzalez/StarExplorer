import 'dart:convert';
import 'dart:io';
import 'package:star_explorer/calculator.dart';
import 'package:star_explorer/model/space_object_data.dart';

import 'model/space_object_data_alt_az.dart';

Future<SpaceObjectData> fetchSpaceObjectCoordinates(String name) async {
  final url = 'https://ned.ipac.caltech.edu/srs/ObjectLookup';
  final body = jsonEncode({
    "name": {"v": name}
  });
  final client = HttpClient();

  try {
    final request = await client.postUrl(Uri.parse(url));
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
  } finally {
    client.close();
  }
}

Future<List<SpaceObjectDataAltAz>> fetchMajorStarCoordinates(double lat, double lon) async {
  List<String> starNames = [
    'HR 2491', // Sirius
    'HR 2326', // Canopus
    'HR 5340', // Arcturus
    'HR 7001', // Vega
    'HR 1707', // Capella
    'HR 1713', // Rigel
    'HR 2943', // Procyon
    'HR 472', // Achernar
    'HR 2061', // Betelgeuse
    'HR 7557', // Altair
    'HR 1457', // Aldebaran
    'HR 6134', // Antares
    'HR 1852', // Mintaka
    'HR 5056', // Spica
    'HR 2990', // Pollux
    'HR 8728', // Fomalhaut
    'HR 7924', // Deneb
    'HR 3982', // Regulus
    'HR 1790', // Bellatrix
    'HR 936', // Algol
    'HR 3634', // Suhail
    'HR 4301', // Dubhe
    'HR 4763', // Gacrux
    'HR 6527', // Shaula
    'HR 681', // Mira
    'HR 4785', // Chara
    'HR 1903', // Alnilam
    'zeta orionis', // alnitak
    'HR 2282', // Furud
    'HR 7417', // Albireo
    'HD 47105', // Alhena
    'HR 6879', // Kaus Australis
    'HR 4860', // Mizar
    'HR 432', // Algol
    'HR 7001', // Vega
    'HR 434' // Polaris
  ];

  List<Future<SpaceObjectDataAltAz>> futures = starNames.map((name) async {
    SpaceObjectData star = await fetchSpaceObjectCoordinates(name);
    List<double> altAz = convertRaDecToAltAz(star.ra, star.dec, lat, lon, DateTime.now().toUtc());
    return SpaceObjectDataAltAz(alt: altAz[0], az: altAz[1], name: star.getName);
  }).toList();

  return Future.wait(futures);
}

Future<List<SpaceObjectDataAltAz>> fetchMajorDSOCoordinates(double lat, double lon) async {
  List<String> dsoNames = [
    "M31", // Andromeda Galaxy
    "M42", // Orion Nebula
    "M57", // Ring Nebula
    "M51", // Whirlpool Galaxy
    "M13", // Hercules Cluster
    "M104", // Sombrero Galaxy
    "M16", // Eagle Nebula
    "Abell 426", // Perseus Cluster
    "M81", // Bode's Galaxy
    "M33", // Triangulum Galaxy
    "Leo Triplet", // Leo Triplet (M65, M66, NGC 3628)
    "M8", // Lagoon Nebula
    "NGC 6210", // Great Hercules Cluster
    "M104", // Sombrero Galaxy (repeated entry)
    "LMC", // Large Magellanic Cloud
    "SMC" // Small Magellanic Cloud
  ];

  List<Future<SpaceObjectDataAltAz>> futures = dsoNames.map((name) async {
    SpaceObjectData dso = await fetchSpaceObjectCoordinates(name);
    List<double> altAz = convertRaDecToAltAz(dso.ra, dso.dec, lat, lon, DateTime.now().toUtc());
    return SpaceObjectDataAltAz(alt: altAz[0], az: altAz[1], name: dso.getName);
  }).toList();

  return Future.wait(futures);
}