// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/chat.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:timelines/timelines.dart';

List<Load> loads = [];
GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
GlobalKey<OverlayState> stackKey = GlobalKey<OverlayState>();
late PageController pageController;

Future<List<Load>> getLoads([callback = null]) async {
  try {
    Response response = await Api().getData('user/find-loads');

    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      loads.forEach((element) {
        animatedListKey.currentState != null
            ? animatedListKey.currentState!
                .removeItem(0, (context, animation) => const SizedBox.shrink())
            : null;
      });
      loads.clear();
      if (jsonResponse['success']) {
        if (jsonResponse['data']['data'].length > 0) {
          List data = jsonResponse['data']['data'];
          data.asMap().forEach((key, load) {
            loads.insert(
              0,
              Load(
                id: load['id'],
                addressFrom: load['address'],
                cityFromId: load['city_id'],
                stateFromId: load['state_id'],
                initialOffer: int.parse(
                    load['initial_offer'].toString().replaceAll('.00', '')),
                longitudeFrom: load['longitude'],
                latitudeFrom: load['latitude'],
                destinLongitude: load['destination_longitude'],
                destinLatitude: load['destination_latitude'],
                destinAddress: load['destination_address'],
                destinCityId: load['destination_city_id'],
                destinStateId: load['destination_state_id'],
                weight: double.parse(load['weight']),
                product: load['product'] ?? '',
                attachments: load['attachments'] ?? [],
              ),
            );
            animatedListKey.currentState != null
                ? animatedListKey.currentState!
                    .insertItem(0, duration: const Duration(milliseconds: 100))
                : null;
          });

          if (callback != null) {
            callback();
          }

          return loads;
        }
      }
    }

    return loads;
  } catch (_) {
    return [];
  }
}

onLoadTap(int id, BuildContext context, setLoadsMarkers) async {
  try {
    Api api = Api();

    TextEditingController intialOfferController = TextEditingController();

    Response response = await api.getData('load/load-info?id=' + id.toString());

    Map jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success']) {
      Map data = jsonResponse['data'];
      List images = data['attachments'] ?? [];
      List<Image> attachments = [];

      TextStyle textoInformacion = const TextStyle(fontSize: 12);

      intialOfferController.text = data['initial_offer'].toString();
      if (images.isNotEmpty) {
        for (var element in images) {
          attachments.add(Image.network(
            imgUrl + element['filename'],
            fit: BoxFit.cover,
          ));
        }
      }
      Size size = MediaQuery.of(context).size;
      await showBottomSheet(
        context: context,
        // barrierColor: Colors.transparent,
        // isScrollControlled: true,
        backgroundColor: Colors.transparent,
        // enableDrag: true,
        constraints: BoxConstraints(
            minHeight: size.height * 0.1, maxHeight: size.height * 0.7),
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
                    child: Text(data['description'] ?? ''),
                  ),
                  Container(
                    color: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.all(20),
                    child: LoadInformation(
                        data: data,
                        id: id,
                        textoInformacion: textoInformacion,
                        intialOfferController: intialOfferController),
                  ),
                  Container(
                    color: const Color(0xFFFFFFFF),
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: TextField(
                            controller: intialOfferController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFBDBDBD),
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              label: Text('Oferta Inicial'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        (data['load_state_id'] == 1
                            ? TextButton.icon(
                                onPressed: () async {
                                  try {
                                    Api api = Api();
                                    Response response = await api.postData(
                                        'negotiation/start-negotiation', {
                                      'load_id': id,
                                      'initial_offer':
                                          intialOfferController.text
                                    });
                                    if (response.statusCode == 200) {
                                      Map jsonResponse =
                                          jsonDecode(response.body);
                                      if (jsonResponse['success']) {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => NegotiationChat(
                                              jsonResponse['data']
                                                  ['negotiation_id']),
                                        ));
                                      }
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Compruebe su conexión a internet')));
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color(0xFF101010)),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color(0xFFFFFFFF)),
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          const EdgeInsets.symmetric(
                                              vertical: 18, horizontal: 10)),
                                ),
                                label: const Text('Negociar'),
                                icon: const Icon(Icons.check),
                              )
                            : const SizedBox.shrink())
                      ],
                    ),
                  ),
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
            data['is_urgent']
                ? Positioned(
                    left: 30,
                    top: 20,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(10),
                          left: Radius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'URGENTE',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  )
                : const SizedBox.shrink()
          ],
        ),
      ).closed.then((value) => setLoadsMarkers());
      // .whenComplete(() {
      //   setLoadsMarkers();
      // });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compruebe su conexión a internet')));
  }
}

/* class LoadInformation extends StatelessWidget {
  const LoadInformation({
    Key? key,
    required this.data,
    required this.id,
    required this.textoInformacion,
    required this.intialOfferController,
  }) : super(key: key);

  final Map data;
  final TextStyle textoInformacion;
  final TextEditingController intialOfferController;
  final int id;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Carga nro: ' + id.toString(),
            ),
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
                  'Salida',
                ),
                Text(
                  'Departamento: ' +
                      (data['state'] != null ? data['state']['name'] : ''),
                  style: textoInformacion,
                ),
                Text(
                  'Ciudad: ' +
                      (data['city'] != null ? data['city']['name'] : ''),
                  style: textoInformacion,
                ),
                Text(
                  'Dirección: ' + (data['address'] ?? ''),
                  style: textoInformacion,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Entrega'),
                Text(
                  'Departamento: ' + (data['destination_state_name'] ?? ''),
                  style: textoInformacion,
                ),
                Text(
                  'Ciudad: ' + (data['destination_city_name'] ?? ''),
                  style: textoInformacion,
                ),
                Text(
                  'Dirección: ' + (data['destination_address'] ?? ''),
                  style: textoInformacion,
                ),
              ],
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const Text('Oferta inicial'),
        TextField(
          controller: intialOfferController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              helperText:
                  'Puedes cambiarlo para ofertar un precio diferente *'),
        ),
        (data['load_state_id'] == 1
            ? ButtonBar(
                children: [
                  TextButton.icon(
                      onPressed: () async {
                        try {
                          Api api = Api();
                          Response response = await api.postData(
                              'negotiation/start-negotiation', {
                            'load_id': id,
                            'initial_offer': intialOfferController.text
                          });

                          if (response.statusCode == 200) {
                            Map jsonResponse = jsonDecode(response.body);
                            if (jsonResponse['success']) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => NegotiationChat(
                                    jsonResponse['data']['negotiation_id']),
                              ));
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Compruebe su conexión a internet')));
                        }
                      },
                      label: const Text('Negociar'),
                      icon: const Icon(Icons.check))
                ],
              )
            : const SizedBox.shrink())
      ],
    );
  }
} */

class LoadInformation extends StatelessWidget {
  const LoadInformation({
    Key? key,
    required this.data,
    required this.id,
    required this.textoInformacion,
    required this.intialOfferController,
  }) : super(key: key);

  final Map data;
  final TextStyle textoInformacion;
  final TextEditingController intialOfferController;
  final int id;

  @override
  Widget build(BuildContext context) {
    return Timeline(
      theme: TimelineThemeData(
        color: Colors.grey[400],
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        TimelineTile(
          nodeAlign: TimelineNodeAlign.start,
          crossAxisExtent: double.infinity,
          mainAxisExtent: 60,
          contents: Container(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data['address'] ?? ''),
                Text((data['state']['name'] ?? '') +
                    ' - ' +
                    (data['city']['name'] ?? '')),
              ],
            ),
          ),
          node: const TimelineNode(
            indicator: OutlinedDotIndicator(),
            endConnector: DashedLineConnector(),
          ),
        ),
        TimelineTile(
          nodeAlign: TimelineNodeAlign.start,
          crossAxisExtent: double.infinity,
          mainAxisExtent: 60,
          contents: Container(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data['destination_address'] ?? ''),
                Text((data['destination_state_name'] ?? '') +
                    ' - ' +
                    (data['destination_city_name'] ?? '')),
              ],
            ),
          ),
          node: const TimelineNode(
            indicator: DotIndicator(),
            startConnector: DashedLineConnector(),
          ),
        ),
        // DotIndicator(
        //   color: Colors.red,
        //   size: 20,
        //   child: Text(data['address'] ?? ''),
        // ),
        // DotIndicator(
        //   color: Colors.red,
        //   size: 20,
        //   child: Text(data['destination_address'] ?? ''),
        // ),
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
          bottom: 70,
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

class Loads extends StatefulWidget {
  const Loads({Key? key}) : super(key: key);
  @override
  _LoadsState createState() => _LoadsState();
}

class _LoadsState extends State<Loads> {
  TextEditingController textEditingController = TextEditingController();

  // late User user;

  @override
  void initState() {
    super.initState();
    // constructUser();
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder<List<Load>>(
          future: getLoads(),
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.done
                  ? LoadsMap()
                  : const Center(child: CircularProgressIndicator())),
    );
  }
}

/* class LoadCard extends StatelessWidget {
  LoadCard(
    this.load, {
    Key? key,
  }) : super(key: key);
  Load load;
  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 10,
        child: GestureDetector(
          // onTap: () => Navigator.of(context)
          //     .push(MaterialPageRoute(builder: (context) => LoadInfo(load))),
          onTap: () => onLoadTap(load.id, context),
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            child: Row(
              children: [
                CircleAvatar(
                  maxRadius: 50,
                  minRadius: 50,
                  backgroundColor: Colors.white,
                  child: load.attachments.isNotEmpty
                      ? Image.network(
                          imgUrl + load.attachments[0]['filename'],
                          loadingBuilder: (context, child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                                child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ));
                          },
                        )
                      : Image.asset(
                          'assets/img/noimage.png',
                          fit: BoxFit.fitWidth,
                        ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(load.product != '' ? load.product : 'Producto'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(load.initialOffer.toString()),
                        Text(load.addressFrom),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
} */

class LoadsMap extends StatefulWidget {
  LoadsMap({Key? key}) : super(key: key);
  @override
  State<LoadsMap> createState() => _LoadsMapState();
}

class _LoadsMapState extends State<LoadsMap>
    with AutomaticKeepAliveClientMixin {
  late GoogleMapController mapController;

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  //ESTILOS DEL MAPA
  String _darkMapStyle = '';

  setMapStyles() async {
    _darkMapStyle =
        await rootBundle.loadString('assets/google_map_styles.json');
    mapController.setMapStyle(_darkMapStyle);
  }

  //coordenada inicial
  late Position position;
  //LISTA DE MARCADORES
  List<Marker> markers = [];

//OBTIENE LA POSICIÓN DEL USUARIO
  getPosition() async {
    position = await Geolocator.getCurrentPosition();
    setState(() {
      // mapController.animateCamera(CameraUpdate.newLatLng(
      //     LatLng(position.latitude, position.longitude)));
    });
    setLoadsMarkers(position);
  } //AGREGA LOS MARCADORES EN CASO DE QUE SE LE PASE

  setLoadsMarkers(Position position,
      [bool fromTap = false, bool pop = false]) async {
    // Uint8List bytes = (await AssetBundle(Uri.parse(imgurl))
    //   .load(imgurl))
    //   .buffer
    //   .asUint8List();
    BitmapDescriptor bitmapIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/img/load-marker-icon.png');
    markers.clear();
    loads.asMap().forEach((key, load) {
      markers.add(
        Marker(
          markerId: MarkerId(load.id.toString()),
          position: LatLng(
            double.parse(load.latitudeFrom),
            double.parse(load.longitudeFrom),
          ),
          icon: bitmapIcon,
          infoWindow: InfoWindow(
              title: load.product != '' ? load.product : load.addressFrom,
              snippet: 'Oferta inicial: ' + currencyFormat(load.initialOffer)),
          onTap: () {
            onLoadTap(
                load.id, context, () => setLoadsMarkers(position, true, false));
            setLoadMarkerInfo(load, position, context);
          },
        ),
      );
    });
    if (fromTap) {
      setState(() {
        _polylines.clear();
        polylineCoordinates.clear();
        if (pop) {
          Navigator.pop(context);
        }
      });
    }
  }

//MUESTRA PINES DE ORIGEN Y DESTINO
  setLoadMarkerInfo(
      Load load, Position position, BuildContext bottomSheetContext) async {
    BitmapDescriptor bitmapIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'assets/img/load-marker-icon.png');
    LatLng originLatLng = LatLng(
      double.parse(load.latitudeFrom),
      double.parse(load.longitudeFrom),
    );
    LatLng destinLatLng = LatLng(
      double.parse(load.destinLatitude),
      double.parse(load.destinLongitude),
    );
    markers.clear();
    markers.add(
      Marker(
          markerId: const MarkerId('load_origin'),
          position: originLatLng,
          infoWindow: InfoWindow(
            title: 'Salida: ' + load.addressFrom,
          ),
          onTap: () {
            setLoadsMarkers(position, true, true);
          },
          icon: bitmapIcon),
    );
    markers.add(
      Marker(
          markerId: const MarkerId('load_destin'),
          position: destinLatLng,
          infoWindow: InfoWindow(
            title: 'Destino: ' + load.destinAddress,
          ),
          onTap: () {
            setLoadsMarkers(position, true, true);
          },
          icon: bitmapIcon),
    );
    setState(() {
      setPolylinesInMap(originLatLng, destinLatLng);
    });
  }

//TRAZA LA RUTA DE ORIGEN A DESTINO
  void setPolylinesInMap(LatLng origin, LatLng destin) async {
    var result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyABWbV1Hy-mBKOhuhaIzzgBP32mloFhhBs',
      PointLatLng(origin.latitude, origin.longitude),
      PointLatLng(destin.latitude, destin.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((pointLatLng) {
        polylineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setState(() {
      _polylines.add(Polyline(
        width: 5,
        polylineId: PolylineId('polyline'),
        color: Colors.blueAccent,
        points: polylineCoordinates,
      ));
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setMapStyles();
    // mapController.setMapStyle('');
    getPosition();
  }

  @override
  void initState() {
    super.initState();
    polylinePoints = PolylinePoints();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          myLocationButtonEnabled: false,
          polylines: _polylines,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          initialCameraPosition: const CameraPosition(
            target: LatLng(-25.27705190025039, -57.63737049639007),
            zoom: 6,
          ),
          markers: markers.map((e) => e).toSet(),
          buildingsEnabled: false,
          zoomControlsEnabled: false,
        ),
        Positioned(
          bottom: 60,
          right: 30,
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: IconButton(
              color: kBlack,
              onPressed: () async {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          right: 30,
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: IconButton(
              color: kBlack,
              onPressed: () async {
                mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(
                      LatLng(position.latitude, position.longitude), 11),
                );
              },
              icon: const Icon(Icons.location_searching_rounded),
            ),
          ),
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
