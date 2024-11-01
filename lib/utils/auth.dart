import 'dart:convert';

import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> login(BuildContext context, String email, String password) async {
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  String? user = localStorage.getString('user');
  if (user != null) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      jsonDecode(user)['is_carrier'] ? '/loads' : '/vehicles',
      ModalRoute.withName(
          jsonDecode(user)['is_carrier'] ? '/loads' : '/vehicles'),
    );
  } else {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    if (emailValid) {
      try {
        Api api = Api();
        Response response = await api.postData('login', {
          'email': email,
          'password': password,
        });
        if (response.statusCode == 200) {
          Map responseBody = jsonDecode(response.body);
          if (responseBody['success']) {
            localStorage.setString(
                'user', jsonEncode(responseBody['data']['user']));
            localStorage.setString('token', responseBody['data']['token']);

            Navigator.pushNamedAndRemoveUntil(
              context,
              responseBody['data']['user']['is_carrier']
                  ? '/loads'
                  : '/vehicles',
              ModalRoute.withName(responseBody['data']['user']['is_carrier']
                  ? '/loads'
                  : '/vehicles'),
            );
            return true;
          } else {
            return false;
          }
        }
        return false;
      } catch (e) {
        return false;
      }
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
  try {
    Api api = Api();

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
  } catch (e) {
    return false;
  }
}

Future logout() async {
  try {
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
  } catch (e) {
    return false;
  }
}
