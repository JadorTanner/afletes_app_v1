import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseApp extends StatefulWidget {
  BaseApp(this.body, {Key? key}) : super(key: key);
  Widget body;
  @override
  State<BaseApp> createState() => _BaseAppState();
}

class _BaseAppState extends State<BaseApp> {
  late User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: FutureBuilder(
          future: Future(() async {
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();

            String? userString = sharedPreferences.getString('user');
            if (userString != null) {
              user = User(userData: jsonDecode(userString)).userFromArray();
              return user;
            }
          }),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SafeArea(
                  child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  CircleAvatar(
                    minRadius: 60,
                    child: Text(
                      user.fullName
                          .split(' ')
                          .map((e) => e.length > 2 ? e.substring(0, 1) : '')
                          .join(''),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(user.fullName),
                  const SizedBox(
                    height: 40,
                  ),
                  TextButton(
                      onPressed: () => {
                            Navigator.of(context).pushNamed(
                                user.isCarrier ? '/my-vehicles' : '/my-loads')
                          },
                      child: Text(
                          user.isCarrier ? 'Mis vehículos' : 'Mis cargas')),
                  const SizedBox(
                    height: 40,
                  ),
                  const Spacer(),
                  TextButton(
                      onPressed: () => {user.logout(context)},
                      child: const Text('Cerrar sesión')),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ));
            }
            return const Text('usuario');
          },
        ),
      ),
      body: widget.body,
    );
  }
}
