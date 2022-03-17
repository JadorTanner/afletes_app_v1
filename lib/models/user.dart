// ignore_for_file: avoid_init_to_null
import 'dart:convert';

import 'package:afletes_app_v1/ui/pages/validate_code.dart';
import 'package:afletes_app_v1/ui/pages/wait_habilitacion.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/pusher.dart';
import 'package:flutter/cupertino.dart';
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

  User userFromArray([Map? data]) {
    if (data != null) {
      userData = data;
    }

    return User(
      id: userData['id'],
      fullName: userData['full_name'],
      firstName: userData['first_name'],
      lastName: userData['last_name'],
      email: userData['email'],
      legalName: userData['legal_name'],
      documentNumber: userData['document_number'],
      street1: userData['street1'],
      street2: userData['street2'] ?? '',
      houseNumber: userData['house_number'] ?? '',
      isCarrier: userData['is_carrier'],
      isLoadGenerator: userData['is_load_generator'],
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
    this.phone = '',
    this.street1 = '',
    this.street2 = '',
    this.houseNumber = '',
  });

  setUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  Future<User> getUser() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    User user = User(userData: jsonDecode(sh.getString('user') ?? '{}'))
        .userFromArray();
    return user;
  }

  Future<bool> login(
      BuildContext context, String email, String password) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? userStored = localStorage.getString('user');
    print('usuario guardado');
    print(userStored);
    if (userStored != null) {
      Map userJson = jsonDecode(userStored);
      print(userJson);
      notifyListeners();
      if (userJson['confirmed']) {
        if (userJson['habilitado']) {
          Navigator.of(context).pushReplacementNamed(
              userJson['is_carrier'] ? 'loads' : '/vehicles');
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const WaitHabilitacion()));
        }
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ValidateCode()));
      }
    } else {
      bool emailValid = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(email);
      print(emailValid ? 'email valido' : 'email no valido');
      if (emailValid) {
        try {
          Api api = Api();

          Response response = await api.postData('login', {
            'email': email,
            'password': password,
          });
          print(response.body);
          if (response.statusCode == 200) {
            Map responseBody = jsonDecode(response.body);
            if (responseBody['success']) {
              Map userJson = responseBody['data']['user'];
              setUser(User(userData: userJson).userFromArray());
              localStorage.setString(
                  'user', jsonEncode(responseBody['data']['user']));
              localStorage.setString('token', responseBody['data']['token']);
              return true;
            } else {
              return false;
            }
          }
          return false;
        } catch (e) {
          print('error');
          print(e);
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
          setUser(User(userData: responseBody['data']['user']).userFromArray());
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
      Response response = await Api().getData('logout');

      sharedPreferences.clear();
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['success']) {
          sharedPreferences.remove('user');
          sharedPreferences.remove('token');
          context.read<PusherApi>().disconnect();
          Navigator.of(context).pushReplacementNamed('/login');
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
}
