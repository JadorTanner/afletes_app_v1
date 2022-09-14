import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissions extends StatelessWidget {
  LocationPermissions({this.route, Key? key}) : super(key: key);
  String? route;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (route != null) {
                        Navigator.of(context).pushReplacementNamed(route!);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.navigate_before),
                  ),
                  Text(
                    'Permisos de ubicación',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(
                    width: 32,
                  ),
                ],
              ),
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
                      await Geolocator.requestPermission();
                      if (await Constants.determinePosition() == 1) {
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
                        Navigator.of(context)
                            .pop(await Geolocator.getCurrentPosition());
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
                              children: const [
                                Text(
                                    'Para una mejor experiencia de uso, es necesario que nos brinde permisos a su ubicación.'),
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
                              child:
                                  const Text('Abrir configuracion de la app'),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Aceptar'),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Cancelar'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Cancelar'),
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
