import 'package:afletes_app_v1/location_permission.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(20).copyWith(top: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icons/logo_web_afletes.png'),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Plataforma digital',
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'para servicios de FLETES',
                      style: Theme.of(context).textTheme.headline6,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 80, left: 20, right: 20),
                    child: Text(
                      "Somos una plataforma mediante la cual transportistas pueden ofrecer sus servicios de transporte, en tanto que los clientes tendrán la oportunidad buscar, ofertar y elegir libremente, al transportista que considere conveniente para transportar sus mercaderías o documentos.",
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      child: const Text(
                        'Quienes somos?',
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: const EdgeInsets.all(20).copyWith(left: 40),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(20),
                        ),
                        color: Constants.primaryOrange,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Stack(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 80, left: 20, right: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Si soy GENERADOR DE CARGA'),
                        GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          cacheExtent: 200,
                          children: [
                            StepCard(
                              svgName: 'ordenador-personal.png',
                              title: 'Publico mi carga',
                              description:
                                  'Publico mi carga con una oferta inicial. Desde un Ordenador o dispositivos móbiles.',
                            ),
                            StepCard(
                              svgName: 'notify.png',
                              title: 'Busco y/o recibo envíos',
                              description:
                                  'Uno o varios Transportistas interesados negocian el precio del transporte conmigo.',
                            ),
                            StepCard(
                              svgName: 'maximo-de-cinco.png',
                              title: 'Acuerdo de precio',
                              description:
                                  'Acuerdo el precio con el Transportista elegido.',
                            ),
                            StepCard(
                              svgName: 'favorito.png',
                              title: 'Calificación del servicio',
                              description:
                                  'Una vez entregada la carga, califico el desempeño del transportista.',
                            ),
                          ],
                        ),
                        Divider(
                          height: 40,
                          color: Colors.grey[400],
                        ),
                        const Text('Si soy TRANSPORTISTA'),
                        GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          cacheExtent: 200,
                          children: [
                            StepCard(
                              svgName: 'touch.png',
                              title: 'Registro mi vehículo',
                              description:
                                  'Descripción del vehículo y documentos al día.',
                            ),
                            StepCard(
                              svgName: 'notificacion.png',
                              title: 'Busco y/o recibo cargas',
                              description:
                                  'Puedes elegir servicios de flete para mudanza, entrega de documentos u otros artículos para envío.',
                            ),
                            StepCard(
                              svgName: 'hand.png',
                              title: 'Acuerdo el precio',
                              description:
                                  'Negocio el precio con el generador de carga/cliente elegido.',
                            ),
                            StepCard(
                              svgName: 'star.png',
                              title: 'Calificación del servicio',
                              description:
                                  'Una vez entregada la carga, confirmo la misma y califico el nivel de cumplimiento del cliente.',
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      child: const Text(
                        'Cómo funciona?',
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: const EdgeInsets.all(20).copyWith(right: 40),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20),
                        ),
                        color: Constants.primaryOrange,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Constants.kGrey,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Permisos necesarios',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text("Afletes recopila datos de ubicación para habilitar las siguientes caracteristicas."),
                      Text('- Búsqueda de vehículos disponibles en tiempo real'),
                      Text('- Ubicación de las cargas disponibles'),
                      Text('Esta información no es compartida y es utilizada con fines de seguridad y funcionamiento de la app'),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(
                              horizontal: 40,
                            ),
                          ),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Constants.primaryOrange,
                                style: BorderStyle.solid,
                                width: 1,
                              ),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Constants.primaryOrange,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return LocationPermissions(
                                  route: '/landing',
                                );
                              },
                            ),
                          );
                        },
                        child: const Text(
                          'Conceder permisos',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
            child: Text(
              'Iniciar sesión',
              style: TextStyle(
                color: Constants.primaryOrange,
              ),
            ),
          ),
          VerticalDivider(
            color: Colors.grey[200],
            thickness: 2,
            indent: 10,
            endIndent: 10,
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/register');
            },
            child: Text(
              'Registrarme',
              style: TextStyle(
                color: Constants.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StepCard extends StatelessWidget {
  StepCard(
      {required this.svgName,
      required this.title,
      required this.description,
      Key? key})
      : super(key: key);
  String svgName, title, description;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 50,
            child: Image.asset(
              'assets/img/$svgName',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
