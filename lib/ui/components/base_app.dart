import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseApp extends StatefulWidget {
  BaseApp(this.body, {this.title = '', Key? key}) : super(key: key);
  Widget body;
  String title;
  @override
  State<BaseApp> createState() => _BaseAppState();
}

class _BaseAppState extends State<BaseApp> {
  late User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
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
                  minimum: EdgeInsets.all(15),
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
                      Text(user.email),
                      const SizedBox(
                        height: 25,
                      ),
                      DrawerItem('/my-profile', 'Mi perfil', Icons.person),
                      const SizedBox(
                        height: 15,
                      ),
                      DrawerItem(
                          user.isCarrier ? '/my-vehicles' : '/my-loads',
                          user.isCarrier ? 'Mis vehículos' : 'Mis cargas',
                          Icons.local_activity),
                      const SizedBox(
                        height: 15,
                      ),
                      DrawerItem('/my-negotiations', 'Mis negociaciones',
                          Icons.ac_unit),
                      const SizedBox(
                        height: 15,
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

class DrawerItem extends StatelessWidget {
  DrawerItem(this.routeName, this.title, this.icon, {Key? key})
      : super(key: key);
  String routeName;
  String title;
  IconData icon;
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => {Navigator.of(context).pushNamed(routeName)},
      icon: CircleAvatar(
        child: Icon(icon),
      ),
      label: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        child: Text(title),
      ),
    );
  }
}
