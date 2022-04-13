import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/utils/constants.dart';
import 'package:http/http.dart';

class LocationService {
  final String key = Constants.googleMapKey;

  Future<String> getPlaceId(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';
    Response response = await get(Uri.parse(url));

    Map json = jsonDecode(response.body);

    var placeId = json['candidates'][0]['place_id'] as String;
    return placeId;
  }

  Future<Map<String, dynamic>> getPlace(String input) async {
    try {
      final placeId = await getPlaceId(input);
      final String url =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
      Response response = await get(Uri.parse(url));
      Map json = jsonDecode(response.body);
      var results = json['result'] as Map<String, dynamic>;
      print(results);
      return results;
    } on SocketException {
      print('Compruebe su conexión a internet');
      return {};
    } catch (e) {
      print('NO HAY RESULTADOS');
      return {};
    }
  }
}
