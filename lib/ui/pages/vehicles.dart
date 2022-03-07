import 'dart:async';
import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/car_card.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/chat.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

int page = 1;
List<Vehicle> vehicles = [];

class Vehicles extends StatefulWidget {
  Vehicles({this.id = null, Key? key}) : super(key: key);

  int? id;

  @override
  _VehiclesState createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> {
  Future<List> getVehicles([int? id = null]) async {
    try {
      vehicles.clear();
      Response response =
          await Api().getData('user/find-vehicles?page=' + page.toString());
      print(response.body);
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
        future: getVehicles(widget.id),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            return RefreshIndicator(
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
    // TODO: implement initState
    super.initState();
    // listViewController.addListener(() {
    //   final position = listViewController.offset /
    //       listViewController.position.maxScrollExtent;
    //   if (position >= 0.8) {
    //     print('final');
    //     setState(() {
    //       page += 1;
    //     });
    //   }
    // });
  }

  onVehicleTap(int id, BuildContext context) async {
    try {
      Api api = Api();

      Response response = await api
          .getData('vehicles/vehicle-info?vehicle_id=' + id.toString());
      print(response.body);
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
          builder: (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 150,
                  child: ImageViewer(attachments),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Chapa/dominio: ' + data['vehicle']['license_plate']),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unidad de medida: ' +
                              data['vehicle']['unidad_medida'],
                          style: textoInformacion,
                        ),
                        Text(
                          'Capacidad Máxima: ' +
                              data['vehicle']['max_capacity'].toString(),
                          style: textoInformacion,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marca: ' + data['marca']['name'],
                          style: textoInformacion,
                        ),
                        Text(
                          'Modelo: ' + data['vehicle']['model'],
                          style: textoInformacion,
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ButtonBar(
                  children: [
                    TextButton.icon(
                        onPressed: () async {
                          loadsContext = context;
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: FutureBuilder<Map>(
                                initialData: {},
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
                                                  padding: const EdgeInsets
                                                          .symmetric(
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
                                                            textScaleFactor:
                                                                1.1,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text('Oferta inicial' +
                                                              data['data'][
                                                                          index]
                                                                      [
                                                                      'initial_offer']
                                                                  .toString()),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text('Carga: ' +
                                                              data['data'][
                                                                          index]
                                                                      [
                                                                      'pickup_at']
                                                                  .toString() +
                                                              ' ' +
                                                              data['data'][
                                                                          index]
                                                                      [
                                                                      'pickup_time']
                                                                  .toString()),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text('Desde: ' +
                                                              data['data']
                                                                      [index]
                                                                  ['address']),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text('Hasta: ' +
                                                              data['data'][
                                                                          index]
                                                                      [
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
                                                                          'data']
                                                                      [
                                                                      index]['id'],
                                                                  'vehicle_id':
                                                                      id
                                                                });
                                                            print(
                                                                response.body);
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
                                                                  loadingContext);

                                                              Navigator.pop(
                                                                  loadsContext);
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
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(SnackBar(
                                                                        content:
                                                                            Text(jsonResponse['message'])));
                                                              }
                                                            }
                                                          } catch (e) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    const SnackBar(
                                                                        content:
                                                                            Text('Compruebe su conexión a internet')));
                                                          }
                                                        },
                                                        icon: const Icon(Icons
                                                            .chevron_right),
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
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          ],
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        label: const Text('Negociar'),
                        icon: const Icon(Icons.check))
                  ],
                )
              ],
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compruebe su conexión a internet')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      children: vehicles.isNotEmpty
          ? List.generate(
              vehicles.length,
              (index) => CarCard2(
                    vehicles[index],
                    onTap: () => onVehicleTap(vehicles[index].id, context),
                  ))
          : [
              Center(
                child: Text('No hay vehículos disponibles'),
              )
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
