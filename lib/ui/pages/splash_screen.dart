import 'dart:convert';

import 'package:afletes_app_v1/ui/pages/register_vehicle.dart';
import 'package:afletes_app_v1/ui/pages/validate_code.dart';
import 'package:afletes_app_v1/ui/pages/wait_habilitacion.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

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
}
//PERMISOS DE LOCALIZACION

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  bool passwordVisibility = false;

  changeScreen() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            children: [
              Text(
                'Esta aplicación necesita acceder a su ubicación',
                style: Theme.of(context).textTheme.headline4,
              ),
              const Text(
                  'Afletes recopila datos de ubicación para habilitar la búsqueda de vehículos disponibles en tiempo real, ubicación de las cargas disponibles e información de ubicación de la carga incluso cuando la aplicación está cerrada o no está en uso".')
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                int permission = await _determinePosition();
                if (permission == 1) {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  var user = sharedPreferences.getString('user');

                  if (user != null && user != 'null') {
                    if (jsonDecode(user)['confirmed']) {
                      if (jsonDecode(user)['habilitado']) {
                        if (jsonDecode(user)['is_carrier']) {
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
                            });
                          });
                        }
                        Navigator.of(context).pushReplacementNamed(
                            jsonDecode(user)['is_carrier']
                                ? '/loads'
                                : '/vehicles');
                      } else {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const WaitHabilitacion(),
                        ));
                      }
                    } else {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const ValidateCode(),
                      ));
                    }
                  } else {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                } else if (permission == 4) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            content: const Text(
                                'Por favor habilite los servicios de ubicación'),
                            actions: [
                              IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.check))
                            ],
                          )).then((value) {
                    Navigator.of(context).pop();
                    changeScreen();
                  });
                } else {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            content: const Text(
                                'Esta aplicación require permisos de ubicación'),
                            actions: [
                              IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.check))
                            ],
                          )).then((value) {
                    Navigator.of(context).pop();
                    changeScreen();
                  });
                }
              },
              child: const Text('Acepto'),
            ),
            TextButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(children: const [
                                Text(
                                    'Para hacer uso de esta aplicación, es necesario que nos brinde permisos a su ubicación.'),
                                Text(
                                    'Si no puede ver la solicitud, vaya a configuración > aplicaciones > afletes y borre todos los datos de la aplicación o bien, desinstale la aplicación y vuelva a instalarla.'),
                              ]),
                            ),
                          ));
                },
                child: const Text('No acepto'))
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var user = sharedPreferences.getString('user');

      if (user != null && user != 'null') {
        if (jsonDecode(user)['confirmed']) {
          if (jsonDecode(user)['habilitado']) {
            if (jsonDecode(user)['is_carrier']) {
              await context.read<Load>().getPendingLoad(context);
              //ENVIAR UBICACION CUANDO CAMBIE
              LocationSettings locationSettings = const LocationSettings(
                accuracy: LocationAccuracy.best,
                distanceFilter: 20,
              );
              Geolocator.getPositionStream(locationSettings: locationSettings)
                  .listen((Position? position) {
                Api api = Api();
                api.postData('update-location', {
                  'latitude': position!.latitude,
                  'longitude': position.longitude,
                });
              });

              if (sharedPreferences.getInt('vehicles')! > 0) {
                Navigator.of(context).pushReplacementNamed('/loads');
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const CreateVehicleAfterReg(),
                  ),
                );
              }
            } else {
              Navigator.of(context).pushReplacementNamed('/vehicles');
            }
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const WaitHabilitacion(),
            ));
          }
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const ValidateCode(),
          ));
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => changeScreen());
    return Scaffold(
      backgroundColor: const Color(0xFFed8d23),
      appBar: AppBar(
        backgroundColor: const Color(0xFFed8d23),
        elevation: 0,
      ),
      body: Center(
        child: Hero(
            tag: 'splash-screen-loading',
            child: Lottie.asset('assets/lottie/camion.json')),
      ),
    );
  }
}
