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

Future<List<Vehicle>> getMyVehicles() async {
  try {
    Response response = await Api().getData('user/my-vehicles');
    vehicles.clear();
    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        var data = jsonResponse['data'];
        if (data.isNotEmpty) {
          data.asMap().forEach((key, vehicle) {
            print(vehicle['model']);
            vehicles.add(
              Vehicle(
                id: vehicle['id'],
                licensePlate: vehicle['license_plate'],
                yearOfProd: vehicle['year_of_production'] ?? 0,
                model: vehicle['model'],
                brand: vehicle['vehicle_brand_id'],
                maxCapacity: double.parse(vehicle['max_capacity']),
                measurementUnitId: vehicle['measurement_unit_id'],
                vtoMunicipal:
                    vehicle['expiration_date_vehicle_authorization'] ?? '',
                vtoDinatran:
                    vehicle['expiration_date_dinatran_authorization'] ?? '',
                vtoSenacsa:
                    vehicle['expiration_date_senacsa_authorization'] ?? '',
                vtoSeguro: vehicle['expiration_date_insurance'] ?? '',
                imgs: vehicle['vehicleattachments'],
              ),
            );
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
  } catch (e) {
    return [];
  }
}

class MyVehiclesPage extends StatefulWidget {
  MyVehiclesPage({Key? key}) : super(key: key);

  @override
  State<MyVehiclesPage> createState() => _MyVehiclesPageState();
}

class _MyVehiclesPageState extends State<MyVehiclesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder<List<Vehicle>>(
        initialData: const [],
        future: getMyVehicles(),
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
          return RefreshIndicator(
            onRefresh: getMyVehicles,
            child: ListView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 40,
                bottom: 20,
              ),
              children: [
                TextButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushNamed('/create-vehicle', arguments: null),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar vehículo')),
                ...items
              ],
            ),
          );
        },
      ),
      title: 'Mis vehículos',
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
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      child: hasData
          ? CarCard2(
              vehicles[index],
              onTap: () {
                print('push a vehicles');
                Navigator.of(context).pushNamed('/create-vehicle', arguments: {
                  'id': vehicles[index].id,
                  'chapa': vehicles[index].licensePlate,
                  'fabricacion': vehicles[index].yearOfProd,
                  'model': vehicles[index].model,
                  'marca': vehicles[index].brand,
                  'peso': vehicles[index].maxCapacity,
                  'unidadMedida': vehicles[index].measurementUnit,
                  'vtoMunicipal': vehicles[index].vtoMunicipal,
                  'vtoDinatran': vehicles[index].vtoDinatran,
                  'vtoSenacsa': vehicles[index].vtoSenacsa,
                  'vtoSeguro': vehicles[index].vtoSeguro,
                  'imgs': vehicles[index].imgs
                });
              },
            )
          : null,
    );
  }
}
