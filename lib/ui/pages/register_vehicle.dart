// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable

import 'package:afletes_app_v1/models/user.dart';
import 'package:flutter/material.dart';
import 'package:afletes_app_v1/ui/pages/vehicles/create_vehicle.dart';
import 'package:provider/provider.dart';

class CreateVehicleAfterReg extends StatefulWidget {
  const CreateVehicleAfterReg({Key? key}) : super(key: key);

  @override
  State<CreateVehicleAfterReg> createState() => _CreateVehicleAfterRegState();
}

class _CreateVehicleAfterRegState extends State<CreateVehicleAfterReg> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFed8d23),
          elevation: 0,
          actions: [
            TextButton(
              onPressed: () {
                context.read<User>().logout(context);
              },
              child: const Text(
                'Volver a inicio',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: const RegisterVehicleForm());
  }
}
