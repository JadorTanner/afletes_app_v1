import 'dart:math';

import 'package:afletes_app_v1/location_permission.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class Constants {
//casa
  // static String baseUrl = 'http://181.120.66.16:8000/';
//oficina
  // static String baseUrl = 'http://192.168.1.109:8000/';
//producción
  static String baseUrl = 'https://www.afletes.com/';

  static String apiUrl = baseUrl + 'api/';

  static String loadImgUrl = baseUrl + 'images/load_attachments_images/';
  static String vehicleImgUrl = baseUrl + 'images/vehicle_images/';

//PRODUCCION
  static String pusherKey = 'db7228c00ec8ff09b106';

//DEVELOPMENT
  // static String pusherKey = '4a54c4ccefa7c6413910';

  static String googleMapKey = 'AIzaSyABWbV1Hy-mBKOhuhaIzzgBP32mloFhhBs';

  static Color kGrey = const Color(0xFFC5C5C5);
  static Color kInputBorder = const Color(0xFFBDBDBD);
  static Color kBlack = const Color(0xFF101010);
  static Color primaryOrange = const Color(0xFFED8232);

  static RegExp htmlTagRegExp =
      RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

  static currencyFormat(int amount,
      [String symbol = 'Gs.', String decimals = ',', String thousands = '.']) {
    NumberFormat format = NumberFormat("#,##0.00");

    return symbol +
        ' ' +
        format.format(amount).replaceAll('.00', '').replaceAll(',', '.');
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  static Future<Position?> getPosition(BuildContext context) async {
    try {
      int permission = await determinePosition();
      print('LOCATION PERMISSION $permission');
      Position? position;
      if (permission == 1) {
        return await Geolocator.getCurrentPosition();
      } else if (permission == 4) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content:
                const Text('Por favor habilite los servicios de ubicación'),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check),
                label: const Text('Cerrar'),
              )
            ],
          ),
        );
        return null;
      } else if (permission == 2) {
        position = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return LocationPermissions();
            },
          ),
        );
        return position;
      }
    } catch (e) {
      return Position(
        longitude: -57.63258238789227,
        latitude: -25.281357063581734,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
    return null;
  }

//PERMISOS DE LOCALIZACION
  static Future determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.value(4);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return Future.value(2);
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.value(3);
    }
    return Future.value(1);
  }
}
