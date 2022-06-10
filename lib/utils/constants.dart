import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Constants {
//casa
  // static String baseUrl = 'http://181.120.66.16/';
//oficina
  static String baseUrl = 'http://192.168.1.193:9000/';
//producción
  // static String baseUrl = 'https://www.afletes.com/';

  static String apiUrl = baseUrl + 'api/';

  static String loadImgUrl = baseUrl + 'images/load_attachments_images/';
  static String vehicleImgUrl = baseUrl + 'images/vehicle_images/';

//PRODUCCION
  // static String pusherKey = 'db7228c00ec8ff09b106';

//DEVELOPMENT
  static String pusherKey = '4a54c4ccefa7c6413910';

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
}
