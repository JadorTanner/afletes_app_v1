// ignore_for_file: avoid_init_to_null
import 'dart:convert';

import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  Map userData = {};
  String firstName = '';
  String lastName = '';
  String fullName = '';
  String email = '';
  String documentNumber = '';
  String legalName = '';
  bool isCarrier = false;
  bool isLoadGenerator = false;
  int cityId = 0;
  int id = 0;
  String latitude = '';
  String longitude = '';
  String cellphone = '';

  userFromArray() {
    return User(
      id: userData['id'],
      fullName: userData['full_name'],
      firstName: userData['first_name'],
      lastName: userData['last_name'],
      email: userData['email'],
    );
  }

  User({
    this.id = 0,
    this.userData = const {},
    this.firstName = '',
    this.lastName = '',
    this.fullName = '',
    this.email = '',
    this.documentNumber = '',
    this.legalName = '',
    this.isCarrier = false,
    this.isLoadGenerator = false,
    this.cityId = 0,
    this.latitude = '',
    this.longitude = '',
    this.cellphone = '',
  });

  getUser() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    User user = User(userData: jsonDecode(sh.getString('user') ?? '{}'));
    return user.userFromArray();
  }

  Future<bool> login(
      BuildContext context, String email, String password) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? user = localStorage.getString('user');
    if (user != null) {
      Navigator.of(context).pushReplacementNamed(
          jsonDecode(user)['is_carrier'] ? 'loads' : '/vehicles');
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
          if (responseBody['success']) {
            localStorage.setString(
                'user', jsonEncode(responseBody['data']['user']));
            localStorage.setString('token', responseBody['data']['token']);
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

  Future logout(context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Response response = await Api().getData('logout');
    print(response.body);
    sharedPreferences.clear();
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success']) {
        sharedPreferences.remove('user');
        sharedPreferences.remove('token');
        print(sharedPreferences.get('user'));
        print(sharedPreferences.get('token'));
        Navigator.of(context).pushReplacementNamed('/login');
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
