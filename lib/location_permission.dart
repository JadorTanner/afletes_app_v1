import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/pages/validate_code.dart';
import 'package:afletes_app_v1/ui/pages/wait_habilitacion.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationPermissions extends StatelessWidget {
  LocationPermissions({this.route = 'login', Key? key}) : super(key: key);
  String route;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Esta aplicación necesita acceder a su ubicación',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Afletes recopila datos de ubicación para habilitar la búsqueda de vehículos disponibles en tiempo real, ubicación de las cargas disponibles e información de ubicación de la carga incluso cuando la aplicación está cerrada o no está en uso".',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Esta aplicación necesita monitorizar su ubicación para proporcionar datos acertados a los demás usuarios. Utilizamos su ubicación para mejorar la búsqueda de transportistas y cargas disponibles en su cercanía.',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      int permission = await _determinePosition();
                      if (permission == 1) {
                        SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        var user = sharedPreferences.getString('user');

                        if (user != null && user != 'null') {
                          context
                              .read<User>()
                              .setOnline(jsonDecode(user)['online']);
                          if (jsonDecode(user)['confirmed']) {
                            if (jsonDecode(user)['habilitado']) {
                              //ENVIAR UBICACION CUANDO CAMBIE
                              LocationSettings locationSettings =
                                  const LocationSettings(
                                accuracy: LocationAccuracy.best,
                                distanceFilter: 20,
                              );
                              Geolocator.getPositionStream(
                                      locationSettings: locationSettings)
                                  .listen((Position? position) {
                                Api api = Api();
                                api.postData('update-location', {
                                  'latitude': position!.latitude,
                                  'longitude': position.longitude,
                                  'heading': position.heading,
                                });
                              });
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                jsonDecode(user)['is_carrier']
                                    ? '/loads'
                                    : '/vehicles',
                                ModalRoute.withName(
                                    jsonDecode(user)['is_carrier']
                                        ? '/loads'
                                        : '/vehicles'),
                              );
                            } else {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const WaitHabilitacion(),
                                ),
                                ModalRoute.withName('/wait-habilitacion'),
                              );
                            }
                          } else {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const ValidateCode(),
                              ),
                              ModalRoute.withName('/wait-habilitacion'),
                            );
                          }
                        } else {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login', ModalRoute.withName('/login'));
                        }
                      } else if (permission == 4) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text(
                                'Por favor habilite los servicios de ubicación'),
                            actions: [
                              TextButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.check),
                                label: const Text('Entendido'),
                              )
                            ],
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: const Text(
                                'Esta aplicación require permisos de ubicación'),
                            actions: [
                              TextButton.icon(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Entendido'),
                              )
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text('Continuar'),
                  ),
                  const VerticalDivider(
                    color: Colors.black,
                    thickness: 4,
                    width: 10,
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    'Para hacer uso de esta aplicación, es necesario que nos brinde permisos a su ubicación.'),
                                Text(
                                    'Si no puede ver la solicitud, vaya a configuración > aplicaciones > afletes y borre todos los datos de la aplicación o bien, desinstale la aplicación y vuelva a instalarla.'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                await Geolocator.openLocationSettings();
                                Navigator.of(context).pop();
                              },
                              child: Text('Abrir configuracion de la app'),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Continuar'),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Lo sentimos, pero este paso es necesario para utilizar nuestros servicios.',
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Aceptar'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                                Navigator.of(context)
                                    .pushReplacementNamed(route);
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('No acepto'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('No acepto'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

//PERMISOS DE LOCALIZACION
Future _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.value(4);
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.value(2);
    } else if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return Future.value(1);
    }
  }

  if (permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
    // Permissions are denied forever, handle appropriately.
    return Future.value(3);
  }
  return Future.value(1);
}
