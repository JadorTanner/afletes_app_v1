import 'dart:convert';

import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

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
  double weight, volumen;
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
      loadWait,
      deliveryWait,
      product;
  bool isUrgent;
  List attachments;
  Load({
    this.id = 0,
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
    this.volumen = 0,
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
    this.loadWait = '',
    this.deliveryWait = '',
    this.isUrgent = false,
    this.attachments = const [],
  });

  Future createLoad(Map body, List<XFile> imagenes,
      {context = null, update = false, loadId = 0}) async {
    try {
      Api api = Api();
      if (update) {
        body.addEntries([MapEntry('id', loadId)]);
      }

      var fullUrl = apiUrl + (update ? 'load/edit-load' : 'load/create-load');

      String token = await api.getToken();
      MultipartRequest request = MultipartRequest('POST', Uri.parse(fullUrl));
      Map headers = api.setHeaders();
      headers.forEach((key, value) {
        request.headers[key] = value;
      });
      body.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      imagenes.forEach((file) async {
        request.files
            .add(await MultipartFile.fromPath('imagenes[]', file.path));
      });
      BuildContext loadingContext = context;
      StreamedResponse response = await request.send();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
      String stringResponse = await response.stream.bytesToString();
      print(stringResponse);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).clearSnackBars();
        Map responseBody = jsonDecode(stringResponse);
        Navigator.pop(loadingContext);
        if (responseBody['success']) {
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseBody['message']),
              ),
            );
            Future.delayed(const Duration(seconds: 1),
                () => {Navigator.of(context).pop()});
          }
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseBody['message']),
            ),
          );
          return false;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compruebe su conexión a internet')));
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
