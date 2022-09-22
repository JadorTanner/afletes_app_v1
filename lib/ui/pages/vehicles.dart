// ignore_for_file: must_be_immutable
import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/location_permission.dart';
import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/car_card.dart';
import 'package:afletes_app_v1/ui/pages/loads/create_load.dart';
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

List states = [
  {
    'id': 0,
    'name': 'Cualquiera',
  },
];
List cities = [
  {
    'id': 0,
    'name': 'Cualquiera',
    'state_id': 0,
  },
];

Position? position;
TextEditingController stateIdController = TextEditingController();
TextEditingController cityId = TextEditingController();
TextEditingController unidadMedidaPickerController = TextEditingController();
double start = 1970;
double end = DateTime.now().year.toDouble();
int stars = 5;
bool habMunicipal = false,
    habDinatran = false,
    habSenacsa = false,
    seguro = false;

class Vehicles extends StatefulWidget {
  Vehicles({this.id, Key? key}) : super(key: key);

  int? id;

  @override
  _VehiclesState createState() => _VehiclesState();
}

Future<List<Vehicle>> getVehicles(String url, [int? id]) async {
  try {
    Response response = await Api().getData(url);
    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        vehicles.clear();
        for (var vehicle in jsonResponse['data']) {
          vehicles.add(
            Vehicle(
              id: vehicle['id'],
              licensePlate: vehicle['license_plate'],
              senacsa: vehicle['senacsa_authorization_attachment_id'] != null,
              dinatran: vehicle['dinatran_authorization_attachment_id'] != null,
              model: vehicle['model'],
              score: double.parse(vehicle['score'].toString()),
              owner: vehicle['created_by'] != null
                  ? User(fullName: vehicle['created_by']['full_name'])
                  : null,
              seguro: vehicle['insurance_attachment_id'] != null,
              imgs: vehicle['vehicleattachments'] ?? [],
              cityName: vehicle['created_by'] != null
                  ? (vehicle['created_by']['city_name'] ?? '')
                  : '',
              brandName: vehicle['vehicle_brand'] != null
                  ? vehicle['vehicle_brand']['name']
                  : '',
            ),
          );
        }
      }
    }

    return vehicles;
  } catch (e) {
    return [];
  }
}

class _VehiclesState extends State<Vehicles> {
  initVehicles() async {
    await getStates();
    await getCities();
  }

  Future<List> getStates() async {
    try {
      Api api = Api();

      Response response = await api.getData('get-states');
      if (response.statusCode == 200) {
        Map jsonResponse = jsonDecode(response.body);
        states.addAll(jsonResponse['data']);
        return states;
      }
      return states;
    } catch (e) {
      return [];
    }
  }

  Future<List> getCities([String stateId = '']) async {
    try {
      Api api = Api();

      Response response = await api.getData(
          'get-cities' + (stateId != '' ? '?state_id=' + stateId : ''));
      if (response.statusCode == 200) {
        Map jsonResponse = jsonDecode(response.body);
        cities.addAll(jsonResponse['data']);
        return cities;
      }
      return cities;
    } catch (e) {
      return [];
    }
  }

  @override
  void initState() {
    initVehicles();
    super.initState();
  }

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
            return const VehiclesList();
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
    position = await Constants.getPosition(context);

    if (position == null) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Para una mejor experiencia, desea brindarnos información de su ubicación?',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  position = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return LocationPermissions();
                      },
                    ),
                  );
                  if (position != null) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Continuar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );
    }
    position ??= Position(
      longitude: -57.63258238789227,
      latitude: -25.281357063581734,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    setState(() {
      mapController.animateCamera(CameraUpdate.newLatLng(
          LatLng(position!.latitude, position!.longitude)));
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
                          errorBuilder: (context, ob, stack) {
                            return const Center(
                              child:
                                  Text('No hemos podido encontrar la imagen'),
                            );
                          },
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
                                      double.parse(firstSnapshot.data!['data']
                                                  ['votes_score']
                                              .toString())
                                          .toInt(),
                                      (index) => const Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                      ),
                                    ),
                                    ...List.generate(
                                      (5 -
                                          double.parse(firstSnapshot
                                                  .data!['data']['votes_score']
                                                  .toString())
                                              .toInt()),
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
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: MyLoads(id),
                                ),
                              );
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
          padding: const EdgeInsets.all(20).copyWith(
            bottom: MediaQuery.of(context).size.height * 0.2,
          ),
          onMapCreated: (controller) =>
              _onMapCreated(controller, transportists),
          myLocationEnabled: context.watch<User>().locationEnabled,
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
          bottom: MediaQuery.of(context).size.height * 0.22,
          right: 30,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: IconButton(
                  color: Constants.kBlack,
                  onPressed: () async {
                    await getVehicles('user/find-vehicles');
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: IconButton(
                  color: Constants.kBlack,
                  onPressed: () async {
                    mapController.animateCamera(
                      CameraUpdate.newLatLngZoom(
                          LatLng(position!.latitude, position!.longitude), 14),
                    );
                  },
                  icon: const Icon(Icons.location_searching_rounded),
                ),
              ),
            ],
          ),
        ),
        Positioned(
            child: DraggableScrollableSheet(
          minChildSize: 0.2,
          maxChildSize: 0.8,
          initialChildSize: 0.2,
          snap: true,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.1,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transportistas disponibles',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          IconButton(
                            onPressed: () async {
                              await showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return BottomSheet(
                                    onClosing: () {},
                                    enableDrag: false,
                                    builder: (context) {
                                      return const Filters();
                                    },
                                  );
                                },
                              );
                              setState(() {});
                            },
                            icon: const Icon(Icons.filter_alt),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20)
                            .copyWith(bottom: 20),
                        shrinkWrap: true,
                        children: [
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
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )),
        context.watch<User>().online
            ? const SizedBox.shrink()
            : Positioned(
                child: GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.red[400],
                    ),
                    child: const Center(
                      child: Text(
                        'Estás desconectado!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                top: 20,
                left: MediaQuery.of(context).size.width * 0.25,
                right: MediaQuery.of(context).size.width * 0.25,
              ),
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
  MyLoads(this.id, {Key? key}) : super(key: key);
  int id;

  @override
  State<MyLoads> createState() => MyLoadsState();
}

class MyLoadsState extends State<MyLoads> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
      initialData: const {},
      future: Future(() async {
        try {
          Api api = Api();
          Response response =
              await api.getData('user/my-loads?open=' + true.toString());
          if (response.statusCode == 200) {
            return jsonDecode(response.body);
          } else {
            return {};
          }
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
        return Future(() => {});
      }),
      builder: (context, snapshot) {
        Map? data = snapshot.connectionState == ConnectionState.done
            ? snapshot.data
            : {};
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
                children: snapshot.connectionState == ConnectionState.done
                    ? [
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Mis cargas',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        snapshot.data!['data'].length > 0
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
                        (snapshot.data!['data'].length > 0
                            ? const SizedBox.shrink()
                            : TextButton.icon(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateLoadPage(
                                        fromHome: true,
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar carga'),
                              )),
                        ...List.generate(snapshot.data!['data'].length,
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
                                        'load_id': data!['data'][index]['id'],
                                        'vehicle_id': widget.id
                                      });

                                      setState(() {
                                        isLoading = false;
                                      });
                                      if (response.statusCode == 200) {
                                        Navigator.pop(context);
                                        Map jsonResponse =
                                            jsonDecode(response.body);

                                        if (jsonResponse['success']) {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                NegotiationChat(
                                                    jsonResponse['data']
                                                        ['negotiation_id']),
                                          ));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(jsonResponse[
                                                      'message'])));
                                        }
                                      }
                                    } on SocketException {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Compruebe su conexión a internet'),
                                        ),
                                      );
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data!['data'][index]['product'],
                                          textScaleFactor: 1.1,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text('Oferta inicial: ' +
                                            data['data'][index]['initial_offer']
                                                .toString()),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text('Carga: ' +
                                            data['data'][index]['pickup_at']
                                                .toString() +
                                            ' ' +
                                            data['data'][index]['pickup_time']
                                                .toString()),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 200,
                                          child: Text('Desde: ' +
                                              data['data'][index]['address']),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            'Hasta: ' +
                                                data['data'][index]
                                                        ['destination_address']
                                                    .toString(),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        (data['data'][index]['is_urgent']
                                            ? const Text(
                                                'Urgente',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              )
                                            : const SizedBox.shrink()),
                                      ],
                                    ),
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
      },
    );
  }
}

class Filters extends StatefulWidget {
  const Filters({Key? key}) : super(key: key);

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  String stateId = '';
  int currentYear = DateTime.now().year;
  @override
  void initState() {
    super.initState();
    stateId = states[0]['id'].toString();
    List firstCity = cities
        .where((element) => element['state_id'].toString() == stateId)
        .toList();
    stateIdController.text = stateId;
    cityId.text = firstCity[0]['id'].toString();
    unidadMedidaPickerController.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(20),
          // mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Departamento'),
                          StatePicker(
                            (newVal) => setState(
                              () {
                                stateId = newVal;
                                List firstCity = cities
                                    .where((element) =>
                                        element['state_id'].toString() ==
                                        stateId)
                                    .toList();
                                cityId.text = firstCity[0]['id'].toString();
                                stateIdController.text = newVal;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Ciudad'),
                          CitiesPicker(stateId),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Text('Año: ' +
                    start.toInt().toString() +
                    '-' +
                    end.toInt().toString()),
                RangeSlider(
                  values: RangeValues(
                    start,
                    end,
                  ),
                  // labels: RangeLabels(
                  //   start.toInt().toString(),
                  //   end.toInt().toString(),
                  // ),
                  min: 1970,
                  max: DateTime.now().year.toDouble(),
                  // divisions: currentYear - 1970,
                  onChanged: (RangeValues values) {
                    setState(() {
                      start = values.start;
                      end = values.end;
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const Text('Calificación: '),
                    const SizedBox(
                      width: 20,
                    ),
                    ...List.generate(
                      5,
                      (index) => IconButton(
                        icon: Icon(index + 1 <= stars
                            ? Icons.star
                            : Icons.star_border),
                        onPressed: () {
                          setState(() {
                            stars = index + 1;
                          });
                        },
                        color: Constants.primaryOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text('Habilitación'),
                CheckboxListTile(
                  value: habMunicipal,
                  onChanged: (newVal) {
                    habMunicipal = newVal!;
                    setState(() {});
                  },
                  title: const Text('Municipal'),
                ),
                CheckboxListTile(
                  value: habDinatran,
                  onChanged: (newVal) {
                    habDinatran = newVal!;
                    setState(() {});
                  },
                  title: const Text('DINATRAN'),
                ),
                CheckboxListTile(
                  value: habSenacsa,
                  onChanged: (newVal) {
                    habSenacsa = newVal!;
                    setState(() {});
                  },
                  title: const Text('SENACSA'),
                ),
                Row(
                  children: [
                    const Text('Seguro'),
                    Switch(
                      value: seguro,
                      onChanged: (newVal) {
                        seguro = newVal;
                        setState(() {});
                      },
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    const Flexible(
                      child: MeasurementUnit(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 60,
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(
                Constants.primaryOrange,
              ),
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
            ),
            onPressed: () async {
              String url = 'user/find-vehicles?';
              url += stateIdController.text == '0'
                  ? ''
                  : 'state_id=' + stateIdController.text + '&';
              url += cityId.text == '0' ? '' : 'city=' + cityId.text + '&';
              url += "year_range=${start.toInt()} - ${end.toInt()}&";
              url += "stars=$stars&";
              url += habMunicipal ? "municipal=$habMunicipal&" : '';
              url += habDinatran ? "dinatran=$habDinatran&" : '';
              url += habSenacsa ? "senacsa=$habSenacsa&" : '';
              url += seguro ? "insurance=$seguro&" : '';
              url += unidadMedidaPickerController.text == '0'
                  ? ''
                  : "measurement_unit_id=${unidadMedidaPickerController.text}";
              await getVehicles(url);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

//Selector de estado y ciudad
class StatePicker extends StatefulWidget {
  const StatePicker(this.callBack, {Key? key}) : super(key: key);
  final callBack;
  @override
  State<StatePicker> createState() => _StatePickerState();
}

class _StatePickerState extends State<StatePicker> {
  String value = '1';

  @override
  void initState() {
    super.initState();
    if (states.isNotEmpty) {
      value = states[0]['id'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: value,
      icon: const Icon(Icons.arrow_circle_down_outlined),
      elevation: 16,
      style: Theme.of(context).textTheme.bodyText2,
      isExpanded: true,
      underline: Container(
        height: 2,
        color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
      ),
      onChanged: (String? newValue) {
        setState(() {
          value = newValue!;
        });
        widget.callBack(newValue!);
      },
      items: List.generate(
        states.length,
        (index) => DropdownMenuItem(
          value: states[index]['id'].toString(),
          child: Text(states[index]['name']),
        ),
      ),
    );
  }
}

//Selector de estado y ciudad
class CitiesPicker extends StatefulWidget {
  CitiesPicker(this.stateId, {Key? key}) : super(key: key);
  String stateId;
  @override
  State<CitiesPicker> createState() => _CitiesPickerState();
}

class _CitiesPickerState extends State<CitiesPicker> {
  String value = '0';

  List newCities = cities;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      newCities = cities.where((city) {
        return city['state_id'].toString() == widget.stateId;
      }).toList();
      // value = newCities[0]['id'].toString();
    });
    return DropdownButton(
        value: cityId.text,
        icon: const Icon(Icons.arrow_circle_down_outlined),
        elevation: 16,
        style: Theme.of(context).textTheme.bodyText2,
        isExpanded: true,
        underline: Container(
          height: 2,
          color:
              Theme.of(context).inputDecorationTheme.border!.borderSide.color,
        ),
        onChanged: (String? newValue) {
          setState(() {
            value = newValue!;
          });
          cityId.text = newValue!;
        },
        items: List.generate(
          newCities.length,
          (index) => DropdownMenuItem(
            value: newCities[index]['id'].toString(),
            child: Text(newCities[index]['name']),
          ),
        ));
  }
}

class MeasurementUnit extends StatefulWidget {
  const MeasurementUnit({Key? key}) : super(key: key);

  @override
  State<MeasurementUnit> createState() => _MeasurementUnitState();
}

class _MeasurementUnitState extends State<MeasurementUnit> {
  String value = '0';

  @override
  void initState() {
    unidadMedidaPickerController.text = value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    unidadMedidaPickerController.text = unidadMedidaPickerController.text == ''
        ? unidadMedidaPickerController.text = value
        : unidadMedidaPickerController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Unidad de medida'),
        FutureBuilder<List>(future: Future<List>(() async {
          try {
            Response response = await Api().getData('get-measurement-units');
            if (response.statusCode == 200) {
              Map jsonResponse = jsonDecode(response.body);
              if (jsonResponse['success']) {
                return [
                  {
                    'id': 0,
                    'name': 'Todos',
                  },
                  ...jsonResponse['data'],
                ];
              }
            } else {
              return [
                {'id': value, 'name': 'No hay resultados'}
              ];
            }
          } catch (e) {
            return [
              {'id': value, 'name': 'No hay resultados'}
            ];
          }
          return [
            {'id': value, 'name': 'No hay resultados'}
          ];
        }), builder: (context, AsyncSnapshot<List> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return DropdownButton(
              value: value,
              icon: const Icon(Icons.arrow_circle_down_outlined),
              elevation: 16,
              style: Theme.of(context).textTheme.bodyText2,
              isExpanded: true,
              underline: Container(
                height: 2,
                color: Theme.of(context)
                    .inputDecorationTheme
                    .border!
                    .borderSide
                    .color,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  value = newValue!;
                  unidadMedidaPickerController.text = newValue;
                });
              },
              items: snapshot.data!
                  .map((e) => DropdownMenuItem(
                        child: Text(e['name']),
                        value: e['id'].toString(),
                      ))
                  .toList(),
            );
          } else {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
            );
          }
        })
      ],
    );
  }
}
