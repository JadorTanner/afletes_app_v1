// ignore_for_file: must_be_immutable, unused_local_variable, must_call_super

import 'dart:async';
import 'dart:convert';

import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/load_card.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:afletes_app_v1/utils/load_image.dart';
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
late GlobalKey<_LoadsMapState> loadsMapKey;
late PageController pageController;

Future<List<Load>> getLoads(BuildContext context, [callback]) async {
  try {
    Response response = await Api().getData('user/find-loads');
    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      for (var element in loads) {
        animatedListKey.currentState != null
            ? animatedListKey.currentState!
                .removeItem(0, (context, animation) => const SizedBox.shrink())
            : null;
      }
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
                pickUpDate: load['pickup_at'],
                pickUpTime: load['pickup_time'],
                attachments: load['attachments'] ?? [],
              ),
            );
            double parsedLatitude = double.parse(loads[key].latitudeFrom);
            double parsedLongitude = double.parse(loads[key].longitudeFrom);
            double parsedDestinLatitude =
                double.parse(loads[key].destinLatitude);
            double parsedDestinLongitude =
                double.parse(loads[key].destinLongitude);

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
    // return WillPopScope(
    //   child:
    loadsMapKey = GlobalKey<_LoadsMapState>();
    return BaseApp(
      FutureBuilder<List<Load>>(
        future: getLoads(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.done
                ? LoadsMap(key: loadsMapKey)
                : const Center(child: CircularProgressIndicator()),
      ),
      isMap: true,
      resizeToAvoidBottomInset: true,
      // ),
      // onWillPop: () => Future(
      //   () {
      //     Navigator.pop(context);
      //     return true;
      //   },
      // ),
    );
  }
}

class LoadsMap extends StatefulWidget {
  const LoadsMap({Key? key}) : super(key: key);
  @override
  State<LoadsMap> createState() => _LoadsMapState();
}

class _LoadsMapState extends State<LoadsMap> {
  late GoogleMapController mapController;

  final Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  //ESTILOS DEL MAPA
  String _darkMapStyle = '';

  DraggableScrollableController scrollableController =
      DraggableScrollableController();

  setMapStyles() async {
    _darkMapStyle =
        await rootBundle.loadString('assets/google_map_styles.json');
    mapController.setMapStyle(_darkMapStyle);
  }

  //coordenada inicial
  Position? position;
  //LISTA DE MARCADORES
  List<Marker> markers = [];

//OBTIENE LA POSICIÓN DEL USUARIO
  getPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    position = await Constants.getPosition(context);

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
    mapController.animateCamera(CameraUpdate.newLatLng(
        LatLng(position!.latitude, position!.longitude)));
    setState(() {});
    setLoadsMarkers(position!);
  }

  //AGREGA LOS MARCADORES EN CASO DE QUE SE LE PASE
  setLoadsMarkers(Position position,
      [bool fromTap = false, bool pop = false]) async {
    // Uint8List bytes = (await AssetBundle(Uri.parse(loadImgUrl))
    //   .load(loadImgUrl))
    //   .buffer
    //   .asUint8List();
    BitmapDescriptor bitmapIcon = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('assets/img/load-marker-icon.png', 70));
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
              snippet: 'Oferta inicial: ' +
                  Constants.currencyFormat(load.initialOffer)),
          onTap: () {
            onLoadTap(load.id, context, load, true,
                () => setLoadsMarkers(position, true, false));
            setLoadMarkerInfo(load, position, context);
          },
        ),
      );
    });
    if (fromTap) {
      _polylines.clear();
      polylineCoordinates.clear();
      if (pop) {
        Navigator.pop(context);
      }
    }
    setState(() {});
  }

//MUESTRA PINES DE ORIGEN Y DESTINO
  setLoadMarkerInfo(
      Load load, Position position, BuildContext bottomSheetContext) async {
    // BitmapDescriptor bitmapIcon = await BitmapDescriptor.fromAssetImage(
    //     const ImageConfiguration(), 'assets/img/load-marker-icon.png');

    BitmapDescriptor bitmapIcon = BitmapDescriptor.fromBytes(
        await getBytesFromAsset('assets/img/load-marker-icon.png', 70));
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
      for (var pointLatLng in result.points) {
        polylineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }

      double southwestLat = 0;
      double southwestLng = 0;
      double northeastLat = 0;
      double northeastLng = 0;

      if (origin.latitude <= destin.latitude) {
        southwestLat = origin.latitude;
        northeastLat = destin.latitude;
      } else {
        southwestLat = destin.latitude;
        northeastLat = origin.latitude;
      }
      if (origin.longitude <= destin.longitude) {
        southwestLng = origin.longitude;
        northeastLng = destin.longitude;
      } else {
        southwestLng = destin.longitude;
        northeastLng = origin.longitude;
      }

      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: LatLng(southwestLat, southwestLng),
              northeast: LatLng(northeastLat, northeastLng)),
          10,
        ),
      );
    }

    setState(() {
      _polylines.add(Polyline(
        width: 5,
        polylineId: const PolylineId('polyline'),
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
            zoom: 14,
          ),
          markers: markers.map((e) => e).toSet(),
          buildingsEnabled: false,
          zoomControlsEnabled: false,
        ),
        Positioned(
          bottom: 60 * 4,
          right: 30,
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: IconButton(
              color: Constants.kBlack,
              onPressed: () async {
                loads = await getLoads(context);
                setLoadsMarkers(position!);
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
            ),
          ),
        ),
        Positioned(
          bottom: 60 * 5,
          right: 30,
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: IconButton(
              color: Constants.kBlack,
              onPressed: () async {
                position = await Constants.getPosition(context);

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
                mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(
                      LatLng(position!.latitude, position!.longitude), 14),
                );
              },
              icon: const Icon(Icons.location_searching_rounded),
            ),
          ),
        ),
        Positioned(
            child: DraggableScrollableSheet(
          minChildSize: 0.2,
          maxChildSize: 0.5,
          initialChildSize: 0.2,
          snap: true,
          controller: scrollableController,
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
                    'Cargas disponibles',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ...List.generate(
                    loads.length,
                    (index) => LoadCard(
                      loads[index],
                      hasData: true,
                      isCarrier: true,
                      isFinalOffer: false,
                      onTap: () async {
                        // setLoadMarkerInfo(loads[index], position, context);
                      },
                      onClose: () {
                        setLoadsMarkers(position!, true);

                        _polylines.clear();
                        polylineCoordinates.clear();
                        setState(() {});
                      },
                    ),
                  ),
                  loads.isEmpty
                      ? const Text(
                          'No hay cargas disponibles',
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
