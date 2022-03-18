import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//casa
String baseUrl = 'http://181.120.66.16:8000/';
//oficina
// String baseUrl = 'http://192.168.1.163:8000/';
//producción
// String baseUrl = 'https://www.afletes.com/';

String apiUrl = baseUrl + 'api/';

String loadImgUrl = baseUrl + 'images/load_attachments_images/';
String vehicleImgUrl = baseUrl + 'images/vehicle_images/';

String pusherKey = 'db7228c00ec8ff09b106';
String googleMapKey = 'AIzaSyABWbV1Hy-mBKOhuhaIzzgBP32mloFhhBs';

Color kGrey = const Color(0xFFC5C5C5);
Color kInputBorder = const Color(0xFFBDBDBD);
Color kBlack = const Color(0xFF101010);
Color primaryOrange = const Color(0xFFED8232);

RegExp htmlTagRegExp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

currencyFormat(int amount,
    [String symbol = 'Gs.', String decimals = ',', String thousands = '.']) {
  NumberFormat format = NumberFormat("#,##0.00");

  return symbol +
      ' ' +
      format.format(amount).replaceAll('.00', '').replaceAll(',', '.');
}
