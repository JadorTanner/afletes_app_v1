import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:flutter/material.dart';

TextEditingController emailController = TextEditingController();
TextEditingController nombreController = TextEditingController();
TextEditingController apellidoController = TextEditingController();

class MyProfilePage extends StatelessWidget {
  MyProfilePage(this.user, {Key? key}) : super(key: key);
  User user;
  @override
  Widget build(BuildContext context) {
    emailController.text = user.email;
    nombreController.text = user.firstName;
    apellidoController.text = user.lastName;
    return BaseApp(
      ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            minRadius: 60,
            child: Text(
              user.fullName
                  .split(' ')
                  .map((e) => e.length > 2 ? e.substring(0, 1) : '')
                  .join(''),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            child: Text(user.fullName),
            alignment: Alignment.center,
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Flexible(
                  child: TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              )),
              Flexible(
                  child: TextField(
                controller: apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
              )),
            ],
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
        ],
      ),
    );
  }
}
