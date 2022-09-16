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
                  "Afletes recopila datos de ubicación para habilitar las siguientes caracteristicas."),
              Text('- Búsqueda de vehículos disponibles en tiempo real'),
              Text('- Ubicación de las cargas disponibles cerca de tu ubicación'),
              Text(
                  'Esta información no es compartida y es utilizada con fines de seguridad y funcionamiento de la app'),
              const SizedBox(
                height: 20,
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
                    child: const Text('Conceder permisos'),
                  ),
                  const VerticalDivider(
                    color: Colors.black,
                    thickness: 4,
                    width: 10,
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
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
