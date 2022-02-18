import 'dart:convert';

import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> login(BuildContext context, String email, String password) async {
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  if (localStorage.getString('user') != null) {
    Navigator.pushNamed(context, '/home');
  } else {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    if (emailValid) {
      Api api = Api();

      Response response = await api.auth({
        'email': email,
        'password': password,
      }, 'login');

      print(response.body);
      if (response.statusCode == 200) {
        Map responseBody = jsonDecode(response.body);
        print(responseBody);
        if (responseBody['success']) {
          localStorage.setString('user', jsonEncode(responseBody['user']));
          localStorage.setString('token', responseBody['token']);
          return true;
        } else {
          return false;
        }
      }
      return false;
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //       content: Center(
      //           child: Text(
      //     'Ha ocurrido un error',
      //     style: TextStyle(color: Colors.white),
      //   ))),
      // );
    }
  }
  return false;
}

Future register(body) async {
  Api api = Api();

  // String type,
  // String name,
  // String lastName,
  // String email,
  // String password,
  // String passwordConfirmation,
  // int docNumber,
  // String razon,
  // String cellPhone,
  // String phone,
  // int stateId,
  // int cityId,
  // String address,
  // String secAddress,
  // String houseNumber,
  // String ciPicture,
  // String ciPictureBack
  if (body.type) {
    return false;
  }
  if (body.name) {
    return false;
  }
  if (body.lastName) {
    return false;
  }
  if (body.email) {
    return false;
  }
  if (body.password) {
    return false;
  }
  if (body.passwordConfirmation) {
    return false;
  }
  if (body.docNumber) {
    return false;
  }
  if (body.razon) {
    return false;
  }
  if (body.cellPhone) {
    return false;
  }
  if (body.phone) {
    return false;
  }
  if (body.stateId) {
    return false;
  }
  if (body.cityId) {
    return false;
  }
  if (body.address) {
    return false;
  }
  if (body.secAddress) {
    return false;
  }
  if (body.houseNumber) {
    return false;
  }
  if (body.ciPicture) {
    return false;
  }
  if (body.ciPictureBac) {
    return false;
  }
  Response response = await api.postData('register', body);

  if (response.statusCode == 200) {
    Map responseBody = jsonDecode(response.body);
    if (responseBody['success']) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString(
          'user', jsonEncode(responseBody['data']['user']));
      sharedPreferences.setString('token', responseBody['data']['token']);
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

Future logout() async {
  Response response = await Api().getData('logout');
  if (response.statusCode == 200) {
    if (jsonDecode(response.body)['success']) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.clear();
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}
