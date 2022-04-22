import 'dart:convert';

import 'package:afletes_app_v1/utils/globals.dart';
import 'package:http/http.dart';

class LocationService {
  final String key = googleMapKey;

  Future<String> getPlaceId(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';
    Response response = await get(Uri.parse(url));

    Map json = jsonDecode(response.body);

    var placeId = json['candidates'][0]['place_id'] as String;
    return placeId;
  }

  Future<Map<String, dynamic>> getPlace(String input) async {
    final placeId = await getPlaceId(input);
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
    Response response = await get(Uri.parse(url));
    Map json = jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;
    return results;
  }
}
