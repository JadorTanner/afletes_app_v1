// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/car_card.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
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
            vehicles.add(
              Vehicle(
                id: vehicle['id'],
                score: double.parse(vehicle['score'].toString()),
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
                dinatranFront:
                    vehicle['vehicle_dinatran_authorization_attachment'] != null
                        ? vehicle['vehicle_dinatran_authorization_attachment']
                            ['filename']
                        : '',
                dinatranBack: vehicle[
                            'vehicle_dinatran_authorization_back_attachment'] !=
                        null
                    ? vehicle['vehicle_dinatran_authorization_back_attachment']
                        ['filename']
                    : '',
                senacsaFront:
                    vehicle['vehicle_senacsa_authorization_attachment'] != null
                        ? vehicle['vehicle_senacsa_authorization_attachment']
                            ['filename']
                        : '',
                senacsaBack: vehicle[
                            'vehicle_senacsa_authorization_back_attachment'] !=
                        null
                    ? vehicle['vehicle_senacsa_authorization_back_attachment']
                        ['filename']
                    : '',
                municipalFront: vehicle['vehicle_authorization_attachment'] !=
                        null
                    ? vehicle['vehicle_authorization_attachment']['filename']
                    : '',
                municipalBack:
                    vehicle['vehicle_authorization_back_attachment'] != null
                        ? vehicle['vehicle_authorization_back_attachment']
                            ['filename']
                        : '',
                greencardFront: vehicle['vehicle_green_card_attachment'] != null
                    ? vehicle['vehicle_green_card_attachment']['filename']
                    : '',
                greencardBack: vehicle['vehicle_green_card_back_attachment'] !=
                        null
                    ? vehicle['vehicle_green_card_back_attachment']['filename']
                    : '',
                insuranceImg: vehicle['vehicle_insurance_attachment'] != null
                    ? vehicle['vehicle_insurance_attachment']['filename']
                    : '',
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
  const MyVehiclesPage({Key? key}) : super(key: key);

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
      Stack(
        children: [
          FutureBuilder<List<Vehicle>>(
            initialData: const [],
            future: getMyVehicles(),
            builder: (context, snapshot) {
              List items = [];
              if (snapshot.connectionState == ConnectionState.done) {
                items = vehicles.isNotEmpty
                    ? List.generate(
                        vehicles.length,
                        (index) => VehicleCard(
                              index,
                              hasData: true,
                            ))
                    : [
                        const Center(
                          child: Text('No hay vehículos aún'),
                        )
                      ];
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
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 80,
                  bottom: 20,
                ),
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushNamed('/create-vehicle', arguments: null),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(vertical: 20)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Constants.kBlack,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Agregar vehículo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ...items
                ],
              );
            },
          ),
          Positioned(
            bottom: 60,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(50),
                ),
                border: Border.all(
                  color: Colors.grey,
                  style: BorderStyle.solid,
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
              ),
            ),
          ),
        ],
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
                  'imgs': vehicles[index].imgs,
                  'dinatranFront': vehicles[index].dinatranFront,
                  'dinatranBack': vehicles[index].dinatranBack,
                  'greencardFront': vehicles[index].greencardFront,
                  'senacsaFront': vehicles[index].senacsaFront,
                  'senacsaBack': vehicles[index].senacsaBack,
                  'greencardBack': vehicles[index].greencardBack,
                  'municipalFront': vehicles[index].municipalFront,
                  'municipalBack': vehicles[index].municipalBack,
                  'insuranceImg': vehicles[index].insuranceImg,
                });
              },
            )
          : null,
    );
  }
}
