import 'dart:convert';

import 'package:afletes_app_v1/utils/api.dart';
import 'package:http/http.dart';

class Vehicle {
  int id, ownerId, yearOfProd;
  double maxCapacity;
  String observation, licensePlate, model;
  bool situacion, esActivo, senacsa, dinatran, seguro;

  Vehicle({
    this.id = 0,
    this.ownerId = 0,
    this.yearOfProd = 0,
    this.maxCapacity = 0,
    this.observation = '0',
    this.licensePlate = '0',
    this.model = '0',
    this.situacion = false,
    this.esActivo = false,
    this.dinatran = false,
    this.senacsa = false,
    this.seguro = false,
  });

  createVehicle(body) async {
    Api api = Api();
    Response response = await api.postData('vehicles/create-vehicle', body);
    print(response.body);
    if (response.statusCode == 200) {
      Map responseBody = jsonDecode(response.body);
      print(responseBody['message']);
      if (responseBody['success']) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
