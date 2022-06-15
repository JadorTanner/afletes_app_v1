// ignore_for_file: avoid_init_to_null
import 'dart:convert';

import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:afletes_app_v1/utils/pusher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class User extends ChangeNotifier {
  User? _user = null;
  User get user => _user!;

  Map userData = {};
  bool isCarrier = false, isLoadGenerator = false;
  int cityId = 0, id = 0;
  String latitude = '',
      longitude = '',
      cellphone = '',
      phone = '',
      street1 = '',
      street2 = '',
      houseNumber = '',
      firstName = '',
      lastName = '',
      fullName = '',
      email = '',
      documentNumber = '',
      legalName = '';

  static User userFromArray(Map data) {
    if (data.isEmpty) {
      return User();
    } else {
      return User(
        id: data['id'],
        fullName: data['full_name'],
        firstName: data['first_name'],
        lastName: data['last_name'],
        email: data['email'],
        legalName: data['legal_name'],
        documentNumber: data['document_number'],
        street1: data['street1'],
        street2: data['street2'] ?? '',
        houseNumber: data['house_number'] ?? '',
        isCarrier: data['is_carrier'],
        isLoadGenerator: data['is_load_generator'],
        cellphone: data['cellphone'] ?? '',
        phone: data['phone'] ?? '',
      );
    }
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
    this.phone = '',
    this.street1 = '',
    this.street2 = '',
    this.houseNumber = '',
  });

  setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  static Future<User> getUser() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    User user = User.userFromArray(jsonDecode(sh.getString('user') ?? '{}'));
    return user;
  }

  Future<bool> login(
      BuildContext context, String email, String password) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
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
            Map userJson = responseBody['data']['user'];
            context.read<User>().setUser(User.userFromArray(userJson));

            await localStorage.setString(
                'user', jsonEncode(responseBody['data']['user']));
            await localStorage.setString(
                'token', responseBody['data']['token']);
            await localStorage.setInt(
                'vehicles', responseBody['data']['vehicles']);
            NotificationsApi().getNotifications(context);

            return true;
          } else {
            return false;
          }
        }
        return false;
      } catch (e) {
        return false;
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
    try {
      Response response = await api.postData('register', body);

      if (response.statusCode == 200) {
        Map responseBody = jsonDecode(response.body);
        if (responseBody['success']) {
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString(
              'user', jsonEncode(responseBody['data']['user']));
          sharedPreferences.setString('token', responseBody['data']['token']);
          User().setUser(User.userFromArray(responseBody['data']['user']));
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

  Future logout(BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    try {
      await Api().getData('logout');

      sharedPreferences.clear();
      sharedPreferences.remove('user');
      sharedPreferences.remove('token');
      context.read<PusherApi>().disconnect();
      await sharedPreferences.setBool('pusher_connected', false);
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        ModalRoute.withName('/login'),
      );
    } catch (e) {
      return false;
    }
  }
}
