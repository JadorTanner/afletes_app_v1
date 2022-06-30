import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/pages/validate_code.dart';
import 'package:afletes_app_v1/ui/pages/wait_habilitacion.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Vehicle {
  int id, ownerId, yearOfProd, brand, measurementUnitId;
  double maxCapacity, score;
  String observation,
      cityName,
      licensePlate,
      model,
      measurementUnit,
      vtoMunicipal,
      vtoDinatran,
      vtoSenacsa,
      vtoSeguro,
      brandName,
      greencardFront,
      greencardBack,
      municipalFront,
      municipalBack,
      dinatranFront,
      dinatranBack,
      senacsaFront,
      senacsaBack,
      insuranceImg,
      insurance;
  bool situacion, esActivo, senacsa, dinatran, seguro;
  List imgs;
  User? owner;

  Vehicle({
    this.id = 0,
    this.score = 5,
    this.measurementUnitId = 0,
    this.brand = 0,
    this.ownerId = 0,
    this.yearOfProd = 0,
    this.maxCapacity = 0,
    this.observation = '0',
    this.licensePlate = '0',
    this.model = '0',
    this.measurementUnit = '',
    this.cityName = '',
    this.vtoMunicipal = '',
    this.vtoDinatran = '',
    this.vtoSenacsa = '',
    this.vtoSeguro = '',
    this.brandName = '',
    this.greencardFront = '',
    this.greencardBack = '',
    this.municipalFront = '',
    this.municipalBack = '',
    this.dinatranFront = '',
    this.dinatranBack = '',
    this.senacsaFront = '',
    this.senacsaBack = '',
    this.insuranceImg = '',
    this.insurance = '',
    this.situacion = false,
    this.esActivo = false,
    this.dinatran = false,
    this.senacsa = false,
    this.seguro = false,
    this.imgs = const [],
    this.owner,
  });

  Vehicle fromJSON(Map data) {
    return Vehicle(
      id: data['id'],
      licensePlate: data['license_plate'],
      maxCapacity: double.parse(data['max_capacity'].toString()),
      yearOfProd: data['year_of_production'],
      model: data['model'],
      brand: data['brand_id'],
      brandName: data['brand_name'],
      score: data['score'],
      // insuranceImg: data[''],
    );
  }

  Future createVehicle(
    body,
    List<XFile> imagenes, {
    context,
    update = false,
    vehicleId = 0,
    String greenCard = '',
    String greenCardBack = '',
    String municipal = '',
    String municipalBack = '',
    String dinatran = '',
    String dinatranBack = '',
    String senacsa = '',
    String senacsaBack = '',
    String insurance = '',
  }) async {
    try {
      SharedPreferences sha = await SharedPreferences.getInstance();
      Map user = jsonDecode(sha.getString('user')!);

      Api api = Api();
      if (update) {
        body.addEntries([MapEntry('id', vehicleId)]);
      }

      var fullUrl =
          Constants.apiUrl + "vehicles/${update ? 'edit' : 'create'}-vehicle";

      MultipartRequest request = MultipartRequest('POST', Uri.parse(fullUrl));

      String token = sha.getString('token')!;
      Map headers = api.setHeaders(token);
      headers.forEach((key, value) {
        request.headers[key] = value;
      });
      request.headers['Authorization'] = 'Bearer ' + token;
      body.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      //DOCUMENTOS
      if (greenCard != '') {
        try {
          request.files.add(await MultipartFile.fromPath(
              'vehicle_green_card_attachment', greenCard));
        } catch (e) {}
      }
      if (greenCardBack != '') {
        try {
          request.files.add(await MultipartFile.fromPath(
              'vehicle_green_card_back_attachment', greenCardBack));
        } catch (e) {}
      }
      if (municipal != '') {
        try {
          request.files.add(await MultipartFile.fromPath(
              'vehicle_authorization_attachment', municipal));
        } catch (e) {}
      }
      if (municipalBack != '') {
        try {
          request.files.add(await MultipartFile.fromPath(
              'vehicle_authorization_back_attachment', municipalBack));
        } catch (e) {}
      }
      if (dinatran != '') {
        try {
          request.files.add(await MultipartFile.fromPath(
              'dinatran_authorization_attachment', dinatran));
        } catch (e) {}
      }
      if (dinatranBack != '') {
        try {
          request.files.add(await MultipartFile.fromPath(
              'dinatran_authorization_back_attachment', dinatranBack));
        } catch (e) {}
      }
      if (senacsa != '') {
        try {
          request.files.add(await MultipartFile.fromPath(
              'senacsa_authorization_attachment', senacsa));
        } catch (e) {}
      }
      if (senacsaBack != '') {
        try {
          request.files.add(await MultipartFile.fromPath(
              'senacsa_authorization_back_attachment', senacsaBack));
        } catch (e) {}
      }
      if (insurance != '') {
        try {
          request.files.add(
              await MultipartFile.fromPath('insurance_attachment', insurance));
        } catch (e) {}
      }

      for (var file in imagenes) {
        request.files
            .add(await MultipartFile.fromPath('imagenes[]', file.path));
      }

      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (context) => const Dialog(
      //     backgroundColor: Colors.transparent,
      //     child: Center(
      //       child: CircularProgressIndicator(),
      //     ),
      //   ),
      // );
      StreamedResponse response = await request.send();
      String stringResponse = await response.stream.bytesToString();

      Map responseBody = jsonDecode(stringResponse);
      if (response.statusCode == 200) {
        // Navigator.pop(context);
        if (responseBody['success']) {
          sha.setInt('vehicles', ((sha.getInt('vehicles') ?? 0) + 1));
          if (context != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(responseBody['message'])));
            if (user['confirmed']) {
              if (user['habilitado']) {
                Future.delayed(
                    const Duration(seconds: 1),
                    () => {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/my-vehicles',
                            ModalRoute.withName('/my-vehicles'),
                          )
                        });
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const WaitHabilitacion(),
                  ),
                );
              }
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ValidateCode(),
                ),
              );
            }
          }
          return true;
        } else {
          if (context != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(responseBody['message'])));
          }
          return false;
        }
      } else {
        // Navigator.pop(context);
        if (context != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(responseBody['message'])));
          // Future.delayed(
          //     const Duration(seconds: 1), () => {Navigator.of(context).pop()});
          return false;
        }
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compruebe su conexión a internet')));
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ha ocurrido un error')));
      return false;
    }
  }
}
