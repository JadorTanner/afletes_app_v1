import 'dart:convert';

import 'package:afletes_app_v1/utils/api.dart';
import 'package:http/http.dart';

class Load {
  int id,
      categoryId,
      vehicleQuantity,
      helpersQuantity,
      initialOffer,
      stateFromId,
      cityFromId,
      destinStateId,
      destinCityId,
      stateId,
      finalOffer;
  double weight;
  String description,
      measurement,
      stateFrom,
      cityFrom,
      addressFrom,
      longitudeFrom,
      latitudeFrom,
      destinState,
      destinCity,
      destinAddress,
      destinLongitude,
      destinLatitude,
      pickUpDate,
      pickUpTime,
      observations,
      state,
      product;
  bool isUrgent;

  Load(
      {this.id = 0,
      this.categoryId = 0,
      this.vehicleQuantity = 0,
      this.helpersQuantity = 0,
      this.initialOffer = 0,
      this.stateFromId = 0,
      this.cityFromId = 0,
      this.destinStateId = 0,
      this.destinCityId = 0,
      this.stateId = 0,
      this.finalOffer = 0,
      this.weight = 0,
      this.description = '',
      this.measurement = '',
      this.stateFrom = '',
      this.cityFrom = '',
      this.addressFrom = '',
      this.longitudeFrom = '',
      this.latitudeFrom = '',
      this.destinState = '',
      this.destinCity = '',
      this.destinAddress = '',
      this.destinLongitude = '',
      this.destinLatitude = '',
      this.pickUpDate = '',
      this.pickUpTime = '',
      this.observations = '',
      this.state = '',
      this.product = '',
      this.isUrgent = false});

  Future createLoad(body) async {
    Api api = Api();
    Response response = await api.postData('load/create-load', body);

    if (response.statusCode == 200) {
      Map responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        print(responseBody);
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future edit() async {
    return false;
  }

  Future deleteImage() async {
    return false;
  }

  Future showInfo() async {
    return false;
  }
}
