import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/utils/constants.dart';
import 'package:afletes_app_v1/utils/load_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

class LocationService extends ChangeNotifier {
  final String key = Constants.googleMapKey;
  static late BitmapDescriptor loadMarkerIcon, carMarkerIcon;

  init() async {
    loadMarkerIcon = BitmapDescriptor.fromBytes(
      await getBytesFromAsset('assets/img/load-marker-icon.png', 70),
    );

    carMarkerIcon = BitmapDescriptor.fromBytes(
      await getBytesFromAsset('assets/img/camion3.png', 5),
    );
  }

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

      return results;
    } on SocketException {
      return {};
    } catch (e) {
      return {};
    }
  }

  //PARA EL PROVIDER
  bool hasLocationPermission = false;
  askLocationPermission() {
    hasLocationPermission = true;
    notifyListeners();
  }

  List<Marker> markers = [];
  addMarker(Marker newMaker) {
    markers.add(newMaker);
    notifyListeners();
  }

  removeMarker(MarkerId markerId) {
    markers.removeWhere((element) => element.markerId == markerId);
    notifyListeners();
  }

  updateMarker(MarkerId markerId, Marker newMaker) {
    removeMarker(markerId);
    addMarker(newMaker);
  }

  clearMarkers() {
    markers.clear();
    notifyListeners();
  }

  //POLYLINES
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  generatePolylines() {}
}
