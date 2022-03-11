import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/car_card.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/chat.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/load_image.dart';
import 'package:afletes_app_v1/utils/pusher.dart';
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
  Vehicles({this.id = null, Key? key}) : super(key: key);

  int? id;

  @override
  _VehiclesState createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> {
  Future<List> getVehicles(String url, [int? id = null]) async {
    try {
      vehicles.clear();
      Response response = await Api().getData(url + 'page=' + page.toString());
      if (response.statusCode == 200) {
        Map jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success']) {
          if (jsonResponse['data']['data'].length > 0) {
            for (var vehicle in jsonResponse['data']['data']) {
              vehicles.add(Vehicle(
                  id: vehicle['id'],
                  licensePlate: vehicle['license_plate'],
                  senacsa:
                      vehicle['senacsa_authorization_attachment_id'] != null,
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
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder(
        future: getVehicles('user/find-vehicles?', widget.id),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            return RefreshIndicator(
                backgroundColor: const Color(0xFFEBE3CD),
                color: Colors.white,
                child: VehiclesList(),
                onRefresh: () async {
                  // await getVehicles();
                  setState(() {});
                });
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class VehiclesList extends StatefulWidget {
  VehiclesList({Key? key}) : super(key: key);

  @override
  State<VehiclesList> createState() => _VehiclesListState();
}

class _VehiclesListState extends State<VehiclesList> {
  final listViewController = ScrollController();
  @override
  void initState() {
    PusherApi().init(context, true);
    super.initState();
  }

  onVehicleTap(int id, BuildContext context) async {
    try {
      Api api = Api();

      Response response = await api
          .getData('vehicles/vehicle-info?vehicle_id=' + id.toString());
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        Map data = jsonResponse['data'];
        List images = data['imgs'] ?? [];
        List<Image> attachments = [];
        // Vehicle vehicle = Vehicle(
        //   id: data['id']
        // );

        TextStyle textoInformacion = const TextStyle(fontSize: 12);

        if (images.isNotEmpty) {
          for (var element in images) {
            attachments.add(Image.network(vehicleImgUrl + element['path']));
          }
        }
        late BuildContext bottomSheetContext;
        late BuildContext loadsContext;
        late BuildContext loadingContext;
        bottomSheetContext = context;
        showModalBottomSheet(
          context: bottomSheetContext,
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
                child: ListView(
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
                                colors: [Colors.transparent, Color(0xFFFFFFFF)],
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
                      child: Text(data['model'] ?? ''),
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
                    IconButton(
                      onPressed: () => {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: FutureBuilder<Map>(
                              initialData: {},
                              future: Future(() async {
                                try {
                                  Api api = Api();
                                  Response response = await api.getData(
                                      'user/my-loads?open=' + true.toString());
                                  if (response.statusCode == 200) {
                                    return jsonDecode(response.body);
                                  } else {
                                    return {};
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Compruebe su conexión a internet')));
                                  return Future(() => {});
                                }
                              }),
                              builder: (context, snapshot) {
                                Map? data = snapshot.connectionState ==
                                        ConnectionState.done
                                    ? snapshot.data
                                    : {};
                                return ListView(
                                  padding: const EdgeInsets.all(20),
                                  children: snapshot.connectionState ==
                                          ConnectionState.done
                                      ? [
                                          const Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Mis cargas',
                                              style: TextStyle(fontSize: 24),
                                            ),
                                          ),
                                          const Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              'Pulse sobre la flecha para negociar',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 30,
                                          ),
                                          (snapshot.data!['data'].length > 0
                                              ? const SizedBox.shrink()
                                              : TextButton.icon(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              '/create-load'),
                                                  icon: const Icon(Icons.add),
                                                  label: const Text(
                                                      'Agregar carga'),
                                                )),
                                          ...List.generate(
                                              snapshot.data!['data'].length,
                                              (index) {
                                            return Card(
                                              margin: const EdgeInsets.only(
                                                  bottom: 20),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          data!['data'][index]
                                                              ['product'],
                                                          textScaleFactor: 1.1,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text('Oferta inicial' +
                                                            data['data'][index][
                                                                    'initial_offer']
                                                                .toString()),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text('Carga: ' +
                                                            data['data'][index][
                                                                    'pickup_at']
                                                                .toString() +
                                                            ' ' +
                                                            data['data'][index][
                                                                    'pickup_time']
                                                                .toString()),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        SizedBox(
                                                          width: 200,
                                                          child: Text('Desde: ' +
                                                              data['data']
                                                                      [index]
                                                                  ['address']),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text('Hasta: ' +
                                                            data['data'][index][
                                                                    'destination_address']
                                                                .toString()),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        (data['data'][index]
                                                                ['is_urgent']
                                                            ? const Text(
                                                                'Urgente',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              )
                                                            : const SizedBox
                                                                .shrink()),
                                                      ],
                                                    ),
                                                    //COMENZAR LA NEGOCIACION
                                                    IconButton(
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
                                                          loadingContext =
                                                              context;
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
                                                                bottomSheetContext);
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
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'Compruebe su conexión a internet')));
                                                        }
                                                      },
                                                      icon: const Icon(
                                                          Icons.chevron_right),
                                                      // label: const Text(
                                                      //     'Negociar'),
                                                    )
                                                  ],
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
                              },
                            ),
                          ),
                        )
                      },
                      icon: Icon(Icons.check),
                    )
                  ],
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compruebe su conexión a internet')));
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
    return GoogleMap(
      key: widget.key,
      onMapCreated: (controller) => _onMapCreated(controller, transportists),
      myLocationEnabled: true,
      initialCameraPosition: const CameraPosition(
        target: LatLng(-25.27705190025039, -57.63737049639007),
        zoom: 14,
      ),
      markers: markers.map((e) => e).toSet(),
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
