import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

class Vehicle {
  int id, ownerId, yearOfProd, brand, measurementUnitId;
  double maxCapacity;
  String observation,
      licensePlate,
      model,
      measurementUnit,
      vtoMunicipal,
      vtoDinatran,
      vtoSenacsa,
      vtoSeguro;
  bool situacion, esActivo, senacsa, dinatran, seguro;
  List imgs;
  User? owner;

  Vehicle({
    this.id = 0,
    this.measurementUnitId = 0,
    this.brand = 0,
    this.ownerId = 0,
    this.yearOfProd = 0,
    this.maxCapacity = 0,
    this.observation = '0',
    this.licensePlate = '0',
    this.model = '0',
    this.measurementUnit = '',
    this.vtoMunicipal = '',
    this.vtoDinatran = '',
    this.vtoSenacsa = '',
    this.vtoSeguro = '',
    this.situacion = false,
    this.esActivo = false,
    this.dinatran = false,
    this.senacsa = false,
    this.seguro = false,
    this.imgs = const [],
    this.owner,
  });

  createVehicle(
    body,
    List<XFile> imagenes, {
    context = null,
    update = false,
    vehicleId = 0,
    XFile? greenCard,
    XFile? greenCardBack,
    XFile? municipal,
    XFile? municipalBack,
    XFile? dinatran,
    XFile? dinatranBack,
    XFile? senacsa,
    XFile? senacsaBack,
    XFile? insurance,
  }) async {
    Api api = Api();
    if (update) {
      body.addEntries([MapEntry('id', vehicleId)]);
    }

    var fullUrl =
        apiUrl + (update ? 'vehicles/edit-vehicle' : 'vehicles/create-vehicle');

    String token = await api.getToken();
    MultipartRequest request = MultipartRequest('POST', Uri.parse(fullUrl));
    Map headers = api.setHeaders();
    headers.forEach((key, value) {
      request.headers[key] = value;
    });
    body.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    //DOCUMENTOS
    if (greenCard != null) {
      request.files.add(await MultipartFile.fromPath(
          'vehicle_green_card_attachment', greenCard.path));
    }
    if (greenCardBack != null) {
      request.files.add(await MultipartFile.fromPath(
          'vehicle_green_card_back_attachment', greenCardBack.path));
    }
    if (municipal != null) {
      request.files.add(await MultipartFile.fromPath(
          'vehicle_authorization_attachment', municipal.path));
    }
    if (municipalBack != null) {
      request.files.add(await MultipartFile.fromPath(
          'vehicle_authorization_back_attachment', municipalBack.path));
    }
    if (dinatran != null) {
      request.files.add(await MultipartFile.fromPath(
          'dinatran_authorization_attachment', dinatran.path));
    }
    if (dinatranBack != null) {
      request.files.add(await MultipartFile.fromPath(
          'dinatran_authorization_back_attachment', dinatranBack.path));
    }
    if (senacsa != null) {
      request.files.add(await MultipartFile.fromPath(
          'senacsa_authorization_attachment', senacsa.path));
    }
    if (senacsaBack != null) {
      request.files.add(await MultipartFile.fromPath(
          'senacsa_authorization_back_attachment', senacsaBack.path));
    }
    if (insurance != null) {
      request.files.add(
          await MultipartFile.fromPath('insurance_attachment', insurance.path));
    }

    imagenes.forEach((file) async {
      request.files.add(await MultipartFile.fromPath('imagenes[]', file.path));
    });

    StreamedResponse response = await request.send();
    Map responseBody = jsonDecode(await response.stream.bytesToString());
    print(responseBody);
    if (response.statusCode == 200) {
      if (responseBody['success']) {
        if (context != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(responseBody['message'])));
          Future.delayed(
              const Duration(seconds: 1), () => {Navigator.of(context).pop()});
        }
        return true;
      } else {
        if (context != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(responseBody['message'])));
          Future.delayed(
              const Duration(seconds: 1), () => {Navigator.of(context).pop()});
        }
        return false;
      }
    } else {
      if (context != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(responseBody['message'])));
        // Future.delayed(
        //     const Duration(seconds: 1), () => {Navigator.of(context).pop()});
      }
    }
  }
}
