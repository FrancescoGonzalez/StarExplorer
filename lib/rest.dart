import 'dart:convert';
import 'dart:io';
import 'package:star_explorer/model/space_object_data.dart';

Future<SpaceObjectData> fetchSpaceObjectCoordinates(String name) async {
  final url = 'https://ned.ipac.caltech.edu/srs/ObjectLookup';
  final body = jsonEncode({"name": {"v": name}});
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
          name: data["Interpreted"]["Name"],
        );
      } else {
          String message = '';

          switch (data["ResultCode"]) {
            case 0:
              message = 'Not a valid DSO name';
              break;
            case 1:
              message = 'Ambiguous DSO name';
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
      throw Exception('HTTP request failed with status: ${response.statusCode}');
    }
  } finally {
    client.close();
  }
}
