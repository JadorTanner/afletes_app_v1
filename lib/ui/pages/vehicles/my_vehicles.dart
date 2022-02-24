import 'dart:convert';

import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/car_card.dart';
import 'package:afletes_app_v1/ui/components/custom_paint.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

List<Vehicle> vehicles = [];

Future<List<Vehicle>> getMyVechicles() async {
  Response response = await Api().getData('user/my-vehicles');
  vehicles.clear();
  if (response.statusCode == 200) {
    Map jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success']) {
      var data = jsonResponse['data'];
      if (data.isNotEmpty) {
        data.asMap().forEach((key, vehicle) {
          vehicles.add(Vehicle(
            id: vehicle['id'],
            licensePlate: vehicle['license_plate'],
            yearOfProd: vehicle['year_of_production'],
            model: vehicle['model'],
            maxCapacity: vehicle['max_capacity'],
            measurementUnit: vehicle['measurement_unit_id'],
            vtoMunicipal: vehicle['expiration_date_vehicle_authorization'],
            vtoDinatran: vehicle['expiration_date_dinatran_authorization'],
            vtoSenacsa: vehicle['expiration_date_senacsa_authorization'],
            vtoSeguro: vehicle['expiration_date_insurance'],
          ));
        });
        return vehicles;
      } else {
        vehicles = [];
      }
    } else {
      vehicles = [];
    }
  }

  return vehicles;
}

class MyVechiclesPage extends StatefulWidget {
  MyVechiclesPage({Key? key}) : super(key: key);

  @override
  State<MyVechiclesPage> createState() => _MyVechiclesPageState();
}

class _MyVechiclesPageState extends State<MyVechiclesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder<List<Vehicle>>(
        initialData: const [],
        future: getMyVechicles(),
        builder: (context, snapshot) {
          List items = [];
          if (snapshot.connectionState == ConnectionState.done) {
            items = List.generate(
                vehicles.length,
                (index) => VehicleCard(
                      index,
                      hasData: true,
                    ));
          } else {
            items = List.generate(
              5,
              (index) => VehicleCard(
                index,
                hasData: false,
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/create-vehicle'),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar carga')),
              ...items
            ],
          );
        },
      ),
      title: 'Mis cargas',
    );
  }
}

class VehicleCard extends StatelessWidget {
  VehicleCard(
    this.index, {
    this.hasData = false,
    Key? key,
  }) : super(key: key);
  int index;
  bool hasData;
  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 10,
        child: GestureDetector(
          onTap: hasData
              ? () => Navigator.of(context)
                      .pushNamed('/create-vehicle', arguments: {
                    'id': vehicles[index].id,
                    'licensePlate': vehicles[index].licensePlate,
                    'yearOfProd': vehicles[index].yearOfProd,
                    'model': vehicles[index].model,
                    'maxCapacity': vehicles[index].maxCapacity,
                    'measurementUnit': vehicles[index].measurementUnit,
                    'vtoMunicipal': vehicles[index].vtoMunicipal,
                    'vtoDinatran': vehicles[index].vtoDinatran,
                    'vtoSenacsa': vehicles[index].vtoSenacsa,
                    'vtoSeguro': vehicles[index].vtoSeguro,
                  })
              : null,
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            child: CarCard2(vehicles[index]),
          ),
        ));
  }
}
