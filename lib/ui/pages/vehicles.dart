// ignore_for_file: must_be_immutable
import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/car_card.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/chat.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:afletes_app_v1/utils/load_image.dart';
import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

int page = 1;
List<Vehicle> vehicles = [];
late Position position;

class Vehicles extends StatefulWidget {
  Vehicles({this.id, Key? key}) : super(key: key);

  int? id;

  @override
  _VehiclesState createState() => _VehiclesState();
}

Future<List<Vehicle>> getVehicles(String url, [int? id]) async {
  try {
    vehicles.clear();
    print('obteniendo vehiculos');
    Response response = await Api().getData('user/find-vehicles');
    print(response);
    print(response.body);
    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        if (jsonResponse['data'].length > 0) {
          for (var vehicle in jsonResponse['data']) {
            vehicles.add(Vehicle(
                id: vehicle['id'],
                licensePlate: vehicle['license_plate'],
                senacsa: vehicle['senacsa_authorization_attachment_id'] != null,
                dinatran:
                    vehicle['dinatran_authorization_attachment_id'] != null,
                model: vehicle['model'],
                score: vehicle['score'],
                owner: vehicle['created_by'] != null
                    ? User(fullName: vehicle['created_by']['full_name'])
                    : null,
                seguro: vehicle['insurance_attachment_id'] != null,
                imgs: vehicle['vehicleattachments'] ?? ''));
          }
        }
      }
    }

    return vehicles;
  } catch (e) {
    print('ERROR AL OBTENER VEHICULOS');
    print(e);
    return [];
  }
}

class _VehiclesState extends State<Vehicles> {
  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder(
        future: getVehicles('user/find-vehicles'),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            return RefreshIndicator(
                backgroundColor: const Color(0xFFEBE3CD),
                color: Colors.white,
                child: const VehiclesList(),
                onRefresh: () async {
                  // await getVehicles();
                  setState(() {});
                });
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      isMap: true,
    );
  }
}

class VehiclesList extends StatefulWidget {
  const VehiclesList({Key? key}) : super(key: key);

  @override
  State<VehiclesList> createState() => _VehiclesListState();
}

class _VehiclesListState extends State<VehiclesList> {
  final listViewController = ScrollController();
  @override
  void initState() {
    super.initState();
  }

//OBTIENE LA POSICIÓN DEL USUARIO
  getPosition() async {
    position = await Geolocator.getCurrentPosition();
    setState(() {
      mapController.animateCamera(CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude)));
    });
  }

  onVehicleTap(int id, BuildContext context) async {
    try {
      List<Image> attachments = [];
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Stack(
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: FutureBuilder<Map>(
                future: Future(
                  () async {
                    Api api = Api();

                    Response response = await api.getData(
                        'vehicles/vehicle-info?vehicle_id=' + id.toString());
                    Map jsonResponse = jsonDecode(response.body);
                    Map data = jsonResponse['data'];
                    List images = data['imgs'] ?? [];
                    // Vehicle vehicle = Vehicle(
                    //   id: data['id']
                    // );

                    if (images.isNotEmpty) {
                      for (var element in images) {
                        attachments.add(Image.network(
                          Constants.vehicleImgUrl + element['path'],
                          fit: BoxFit.cover,
                        ));
                      }
                    }
                    return jsonResponse;
                  },
                ),
                builder: (context, AsyncSnapshot<Map> firstSnapshot) {
                  if (firstSnapshot.connectionState == ConnectionState.done) {
                    if (firstSnapshot.data!['success']) {
                      return ListView(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                height: 400,
                                child: ImageViewer(attachments),
                              ),
                              Positioned(
                                bottom: -2,
                                left: 0,
                                right: 0,
                                child: Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Color(0xFFFFFFFF)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Container(
                            color: const Color(0xFFFFFFFF),
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 40,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  firstSnapshot.data!['data']['vehicle']
                                      ['license_plate'],
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                Row(
                                  children: [
                                    ...List.generate(
                                      int.parse(firstSnapshot.data!['data']
                                              ['votes_score']
                                          .toString()),
                                      (index) => const Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                      ),
                                    ),
                                    ...List.generate(
                                      (5 -
                                          int.parse(firstSnapshot.data!['data']
                                                  ['votes_score']
                                              .toString())),
                                      (index) => const Icon(
                                        Icons.star_border,
                                        color: Colors.yellow,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color: const Color(0xFFFFFFFF),
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 40,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                (firstSnapshot.data!['data']['vehicle']
                                            ['insurance_attachment_id'] !=
                                        null
                                    ? const Icon(Icons.security)
                                    : const SizedBox.shrink())
                              ],
                            ),
                          ),

                          Container(
                            color: const Color(0xFFFFFFFF),
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 40,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Año de producción: ' +
                                    firstSnapshot.data!['data']['vehicle']
                                            ['year_of_production']
                                        .toString()),
                                Text('Capacidad máxima: ' +
                                    firstSnapshot.data!['data']['vehicle']
                                            ['max_capacity']
                                        .toString() +
                                    ' ' +
                                    firstSnapshot.data!['data']['vehicle']
                                        ['unidad_medida'] +
                                    's'),
                                Text('Marca: ' +
                                    firstSnapshot.data!['data']['marca']
                                        ['name']),
                                Text('Modelo: ' +
                                    (firstSnapshot.data!['data']['vehicle']
                                            ['model'] ??
                                        '')),
                              ],
                            ),
                          ),
                          // Container(
                          //   color: const Color(0xFFFFFFFF),
                          //   padding: const EdgeInsets.all(20),
                          //   child: LoadInformation(
                          //       data: data,
                          //       id: id,
                          //       textoInformacion: textoInformacion,
                          //       intialOfferController: intialOfferController),
                          // ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextButton.icon(
                            onPressed: () => {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: FutureBuilder<Map>(
                                    initialData: const {},
                                    future: Future(() async {
                                      try {
                                        Api api = Api();
                                        Response response = await api.getData(
                                            'user/my-loads?open=' +
                                                true.toString());
                                        if (response.statusCode == 200) {
                                          return jsonDecode(response.body);
                                        } else {
                                          return {};
                                        }
                                      } on SocketException {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Compruebe su conexión a internet'),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Ha ocurrido un error'),
                                          ),
                                        );
                                      }
                                      return Future(() => {});
                                    }),
                                    builder: (context, snapshot) {
                                      Map? data = snapshot.connectionState ==
                                              ConnectionState.done
                                          ? snapshot.data
                                          : {};
                                      return MyLoads(snapshot, data!, id);
                                    },
                                  ),
                                ),
                              )
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0xFF101010)),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0xFFFFFFFF)),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 10)),
                            ),
                            icon: const Icon(Icons.check),
                            label: const Text('Negociar'),
                          )
                        ],
                      );
                    } else {
                      return const Center(
                        child: Text('Ha ocurrido un error'),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            Positioned(
              left: 160,
              right: 160,
              top: 10,
              child: Container(
                height: 5,
                width: 2,
                constraints: const BoxConstraints(maxWidth: 2),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color(0xFFC5C5C5),
                ),
              ),
            ),
            Positioned(
              right: 30,
              top: 20,
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    size: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compruebe su conexión a internet'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ha ocurrido un error'),
        ),
      );
    }
  }

  late GoogleMapController mapController;
  //ESTILOS DEL MAPA
  String _darkMapStyle = '';
  late BitmapDescriptor bitmapIcon;

  setMapStyles() async {
    _darkMapStyle =
        await rootBundle.loadString('assets/google_map_styles.json');
    mapController.setMapStyle(_darkMapStyle);
  }

  //coordenada inicial
  //LISTA DE MARCADORES
  List<Marker> markers = [];

//OBTIENE LA POSICIÓN DEL USUARIO
  void _onMapCreated(GoogleMapController controller,
      List<TransportistLocation> transportists) async {
    mapController = controller;

    bitmapIcon = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('assets/img/camion3.png', 5));

    getPosition();

    setMapStyles();
    // mapController.setMapStyle('');
    setMarkers(transportists);
  }

  setMarkers(
    List<TransportistLocation> transportists,
  ) async {
    bitmapIcon = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('assets/img/camion3.png', 30));
    markers.clear();
    transportists.asMap().forEach((key, transportist) {
      markers.add(
        Marker(
          markerId: MarkerId(transportist.transportistId.toString() +
              transportist.vehicleId.toString()),
          position: LatLng(
            transportist.latitude,
            transportist.longitude,
          ),
          icon: bitmapIcon,
          flat: true,
          rotation: transportist.heading,
          onTap: () => onVehicleTap(transportist.vehicleId, context),
          infoWindow: InfoWindow(title: transportist.name),
        ),
      );
    });
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    List<TransportistLocation> transportists =
        context.watch<TransportistsLocProvider>().transportists;

    setMarkers(transportists);
    return Stack(
      children: [
        GoogleMap(
          key: widget.key,
          onMapCreated: (controller) =>
              _onMapCreated(controller, transportists),
          myLocationEnabled: true,
          initialCameraPosition: const CameraPosition(
            target: LatLng(-25.27705190025039, -57.63737049639007),
            zoom: 14,
          ),
          markers: markers.map((e) => e).toSet(),
          buildingsEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
        ),

        Positioned(
          bottom: 200,
          right: 30,
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: IconButton(
              color: Constants.kBlack,
              onPressed: () async {
                mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(
                      LatLng(position.latitude, position.longitude), 14),
                );
              },
              icon: const Icon(Icons.location_searching_rounded),
            ),
          ),
        ),
        // Positioned(
        //   bottom: 60,
        //   right: 30,
        //   child: Container(
        //     decoration: const BoxDecoration(
        //         color: Colors.white,
        //         borderRadius: BorderRadius.all(Radius.circular(50))),
        //     child: IconButton(
        //       color: kBlack,
        //       onPressed: () async {
        //         vehicles = await getVehicles('user/find-vehicles');
        //         setState(() {});
        //       },
        //       icon: const Icon(Icons.refresh),
        //     ),
        //   ),
        // ),

        Positioned(
            child: DraggableScrollableSheet(
          minChildSize: 0.2,
          maxChildSize: 0.5,
          initialChildSize: 0.2,
          snap: true,
          builder: (context, scrollController) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Constants.kBlack,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Transportistas disponibles',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ...List.generate(
                    vehicles.length,
                    (index) => CarCard2(
                      vehicles[index],
                      onTap: () async {
                        onVehicleTap(vehicles[index].id, context);
                        // setLoadMarkerInfo(loads[index], position, context);
                      },
                    ),
                  ),
                  vehicles.isEmpty
                      ? const Text(
                          'No hay vehiculos disponibles',
                          textAlign: TextAlign.center,
                        )
                      : const SizedBox.shrink()
                ],
              ),
            );
          },
        )),
      ],
    );
  }
}

class ImageViewer extends StatefulWidget {
  ImageViewer(this.attachments, {Key? key}) : super(key: key);
  List attachments;
  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  int currentImage = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView(
          onPageChanged: (value) => setState(() {
            currentImage = value;
          }),
          children: List.generate(
              widget.attachments.length,
              (index) => GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4,
                          clipBehavior: Clip.none,
                          child: widget.attachments[index],
                        ),
                      ),
                    ),
                    child: widget.attachments[index],
                  )),
        ),
        Positioned(
          bottom: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.attachments.length,
              (index) => Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: index == currentImage
                      ? const Color(0xFF686868)
                      : const Color(0xFFEEEEEE),
                  border: Border.all(
                    color: index == currentImage
                        ? const Color(0xFF686868)
                        : const Color(0xFFEEEEEE),
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MyLoads extends StatefulWidget {
  MyLoads(this.snapshot, this.data, this.id, {Key? key}) : super(key: key);

  AsyncSnapshot<Map> snapshot;
  Map data;
  int id;

  @override
  State<MyLoads> createState() => MyLoadsState();
}

class MyLoadsState extends State<MyLoads> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(),
            ),
          )
        : ListView(
            padding: const EdgeInsets.all(20),
            children: widget.snapshot.connectionState == ConnectionState.done
                ? [
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Mis cargas',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    widget.snapshot.data!['data'].length > 0
                        ? const Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Pulse sobre la carga para negociar',
                              style: TextStyle(fontSize: 12),
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(
                      height: 30,
                    ),
                    (widget.snapshot.data!['data'].length > 0
                        ? const SizedBox.shrink()
                        : TextButton.icon(
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/create-load'),
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar carga'),
                          )),
                    ...List.generate(widget.snapshot.data!['data'].length,
                        (index) {
                      return GestureDetector(
                        onTap: isLoading
                            ? () {}
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  Api api = Api();

                                  Response response = await api.postData(
                                      'negotiation/start-negotiation', {
                                    'load_id': widget.data['data'][index]['id'],
                                    'vehicle_id': widget.id
                                  });

                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (response.statusCode == 200) {
                                    Navigator.pop(context);

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Map jsonResponse =
                                        jsonDecode(response.body);

                                    if (jsonResponse['success']) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => NegotiationChat(
                                            jsonResponse['data']
                                                ['negotiation_id']),
                                      ));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  jsonResponse['message'])));
                                    }
                                  }
                                } on SocketException {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Compruebe su conexión a internet'),
                                    ),
                                  );
                                } catch (e) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Ha ocurrido un error'),
                                    ),
                                  );
                                }
                              },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.data['data'][index]['product'],
                                      textScaleFactor: 1.1,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text('Oferta inicial: ' +
                                        widget.data['data'][index]
                                                ['initial_offer']
                                            .toString()),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text('Carga: ' +
                                        widget.data['data'][index]['pickup_at']
                                            .toString() +
                                        ' ' +
                                        widget.data['data'][index]
                                                ['pickup_time']
                                            .toString()),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: Text('Desde: ' +
                                          widget.data['data'][index]
                                              ['address']),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Hasta: ' +
                                            widget.data['data'][index]
                                                    ['destination_address']
                                                .toString(),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    (widget.data['data'][index]['is_urgent']
                                        ? const Text(
                                            'Urgente',
                                            style: TextStyle(color: Colors.red),
                                          )
                                        : const SizedBox.shrink()),
                                  ],
                                ),
                                //COMENZAR LA NEGOCIACION
                                /*  IconButton(
                                                            onPressed: () async {
                                                              try {
                                                                Api api = Api();
                                                
                                                                Response response =
                                                                    await api.postData(
                                                                        'negotiation/start-negotiation',
                                                                        {
                                                                      'load_id': data[
                                                                              'data'][
                                                                          index]['id'],
                                                                      'vehicle_id': id
                                                                    });
                                                                // showDialog(
                                                                //     context:
                                                                //         context,
                                                                //     barrierColor: Colors
                                                                //         .transparent,
                                                                //     builder:
                                                                //         (context) =>
                                                                //             const Dialog(
                                                                //               backgroundColor:
                                                                //                   Colors.transparent,
                                                                //               child:
                                                                //                   Center(
                                                                //                 child:
                                                                //                     CircularProgressIndicator(),
                                                                //               ),
                                                                //             ));
                                                
                                                                if (response
                                                                        .statusCode ==
                                                                    200) {
                                                                  Navigator.pop(
                                                                      context);
                                                
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pop(
                                                                      context);
                                                                  Map jsonResponse =
                                                                      jsonDecode(
                                                                          response
                                                                              .body);
                                                                  if (jsonResponse[
                                                                      'success']) {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                            MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          NegotiationChat(
                                                                              jsonResponse['data']
                                                                                  [
                                                                                  'negotiation_id']),
                                                                    ));
                                                                  } else {
                                                                    ScaffoldMessenger
                                                                            .of(
                                                                                context)
                                                                        .showSnackBar(
                                                                            SnackBar(
                                                                                content:
                                                                                    Text(jsonResponse['message'])));
                                                                  }
                                                                }
                                                              } on SocketException {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        'Compruebe su conexión a internet'),
                                                                  ),
                                                                );
                                                              } catch (e) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        'Ha ocurrido un error'),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                            icon: const Icon(
                                                                Icons.chevron_right),
                                                            // label: const Text(
                                                            //     'Negociar'),
                                                          ) */
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                  ]
                : [
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  ],
          );
  }
}
