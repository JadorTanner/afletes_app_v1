import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;

class Api {
  final String _url = globals.apiUrl;
  // 192.168.1.2 is my IP, change with your IP address
  var token;

  getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token') ?? '';
    return token;
  }

  auth(data, apiURL) async {
    var fullUrl = _url + apiURL;
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: setHeaders());
  }

  getData(apiURL) async {
    var fullUrl = _url + apiURL;
    print(fullUrl);
    await getToken();
    return await http.get(
      Uri.parse(fullUrl),
      headers: setHeaders(),
    );
  }

  postData(apiURL, body) async {
    var fullUrl = _url + apiURL;
    print(fullUrl);
    await getToken();
    return await http.post(
      Uri.parse(fullUrl),
      body: jsonEncode(body),
      headers: setHeaders(),
    );
  }

  postWithFiles(apiURL, Map body, List<XFile> files) async {
    var fullUrl = _url + apiURL;
    await getToken();
    http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(fullUrl));
    Map headers = setHeaders();
    headers.forEach((key, value) {
      request.headers[key] = value;
    });
    body.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    files.forEach((file) async {
      request.files
          .add(await http.MultipartFile.fromPath('imagenes[]', file.path));
    });

    return request.send();
  }

  setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
