import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/car_card.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Vehicles extends StatefulWidget {
  Vehicles({this.id = null, Key? key}) : super(key: key);

  int? id;

  @override
  _VehiclesState createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> {
  List<Vehicle> vehicles = [];

  Future<List> getVehicles([int? id = null]) async {
    vehicles.clear();
    Response response = await Api().getData('user/find-vehicles');
    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      print(jsonResponse['data']['data'][0]['vehicleattachments']);
      print(jsonResponse['data']['data'][0]['vehicleBrand']);
      if (jsonResponse['success']) {
        if (jsonResponse['data']['data'].length > 0) {
          for (var vehicle in jsonResponse['data']['data']) {
            vehicles.add(Vehicle(
                id: vehicle['id'],
                licensePlate: vehicle['license_plate'],
                senacsa: vehicle['senacsa_authorization_attachment_id'] != null
                    ? true
                    : false,
                dinatran:
                    vehicle['dinatran_authorization_attachment_id'] != null
                        ? true
                        : false,
                imgs: vehicle['vehicleattachments'] ?? ''));
          }
        }
      }
    }

    return vehicles;
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder(
        future: getVehicles(widget.id),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.connectionState == ConnectionState.done) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: List.generate(
                  vehicles.length, (index) => CarCard2(vehicles[index])),
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
