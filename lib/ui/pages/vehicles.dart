import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/utils/negotiation.dart';
import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';

class Vehicles extends StatefulWidget {
  const Vehicles({Key? key}) : super(key: key);

  @override
  _VehiclesState createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ButtonBar(
            children: [
              TextButton(
                  onPressed: () => User()
                      .login(context, 'transportista@gmail.com', '123456789'),
                  child: const Text('login')),
              TextButton(
                  onPressed: () async => {
                        print(await Vehicle().createVehicle({
                          'license_plate': 'AGBC456',
                          'vehicle_brand_id': 1,
                          'year_of_production': '2020',
                          'model': 'HILUX ALGO',
                          'max_capacity': '200',
                          'measurement_unit_id': 1,
                        }))
                      },
                  child: const Text('Crear vehículo')),
              IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.all_inbox_rounded)),
              TextButton(
                  onPressed: () => User().logout(),
                  child: const Text('Logout')),
            ],
          ),
          TextButton(
              onPressed: () => Negotiation().startNegotiation(),
              child: const Text('Iniciar negociación'))
        ],
      ),
    );
  }
}
