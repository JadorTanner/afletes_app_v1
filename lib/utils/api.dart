// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class Api {
  final String _url = Constants.apiUrl;
  // 192.168.1.2 is my IP, change with your IP address
  var token;

  getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token') ?? '';
    return token;
  }

  getData(targetURL) async {
    var fullUrl = _url + targetURL;

    await getToken();
    try {
      return await http.get(
        Uri.parse(fullUrl),
        headers: setHeaders(),
      );
    } on SocketException {
      NotificationsApi.showNotification(
          id: 1,
          title: 'Error',
          body: 'Revise su conexión a internet',
          payload: '{}');
    } catch (e) {
      print('HA OCURRIDO UN ERROR');
      print(e);
    }
  }

  postData(targetURL, body) async {
    var fullUrl = _url + targetURL;

    String token = await getToken();
    try {
      return await http.post(
        Uri.parse(fullUrl),
        body: jsonEncode(body),
        headers: setHeaders(token),
      );
    } on SocketException {
      NotificationsApi.showNotification(
          id: 1,
          title: 'Error',
          body: 'Revise su conexión a internet',
          payload: '{}');
    }
  }

  postWithFiles(targetURL, Map body, List<XFile> files) async {
    var fullUrl = _url + targetURL;
    String token = await getToken();
    http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(fullUrl));
    Map headers = setHeaders(token);
    headers.forEach((key, value) {
      request.headers[key] = value;
    });
    body.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    for (var file in files) {
      request.files
          .add(await http.MultipartFile.fromPath('imagenes[]', file.path));
    }

    return request.send();
  }

  setHeaders([tokenParam]) {
    return {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + (token ?? (tokenParam ?? '')),
    };
  }
}
