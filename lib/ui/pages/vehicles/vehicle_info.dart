import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';

class VehicleInfo extends StatelessWidget {
  VehicleInfo(this.vehicle, {Key? key}) : super(key: key);
  Vehicle vehicle;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Text('Vehiculo:' + vehicle.id.toString()),
    );
  }
}
