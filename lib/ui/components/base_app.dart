// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/pages/my_profile.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseApp extends StatefulWidget {
  BaseApp(this.body, {this.title = '', this.floatingButton = null, Key? key})
      : super(key: key);
  Widget body;
  String title;
  FloatingActionButton? floatingButton;
  @override
  State<BaseApp> createState() => _BaseAppState();
}

class _BaseAppState extends State<BaseApp> {
  late User user;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _key = GlobalKey();
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: kBlack),
        actionsIconTheme: IconThemeData(color: kBlack),
        leading: Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(top: 20, left: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
          ),
          child: IconButton(
            onPressed: () => {_key.currentState!.openDrawer()},
            icon: const Icon(Icons.menu, size: 20),
          ),
        ),
        actions: [
          Navigator.canPop(context)
              ? Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(top: 20, right: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white,
                  ),
                  child: IconButton(
                      onPressed: () => {Navigator.of(context).pop()},
                      icon: const Icon(Icons.chevron_left, size: 20)),
                )
              : const SizedBox.shrink()
        ],
      ),
      extendBodyBehindAppBar: true,
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
                  minimum: const EdgeInsets.all(15),
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
                      TextButton.icon(
                        onPressed: () => {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyProfilePage(user),
                          ))
                        },
                        icon: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        label: Container(
                          padding: const EdgeInsets.all(15),
                          width: double.infinity,
                          child: const Text('Mi perfil'),
                        ),
                      ),
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
                      DrawerItem(
                          user.isCarrier ? '/loads' : '/vehicles',
                          user.isCarrier ? 'Buscar cargas' : 'Buscar vehículos',
                          Icons.search),
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
      body: Stack(
        children: [
          widget.body,
          Positioned(
              top: 40,
              left: 20,
              child: widget.floatingButton ?? const SizedBox.shrink())
        ],
      ),
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
