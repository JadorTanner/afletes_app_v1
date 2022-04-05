import 'dart:convert';

import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class VerTrayecto extends StatefulWidget {
  const VerTrayecto({Key? key}) : super(key: key);

  @override
  State<VerTrayecto> createState() => _VerTrayectoState();
}

class _VerTrayectoState extends State<VerTrayecto> {
  late Size size;
  late Load load;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.8,
      width: size.width * 0.9,
      child: FutureBuilder<String>(future: Future(() async {
        Api api = Api();
        Response response = await api.getData(
          'load/load-info?id=' + context.read<ChatProvider>().loadId.toString(),
        );
        return response.body;
      }), builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          load = Load.fromJSON(jsonDecode(snapshot.data!)['data']);

          return Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                'Trayecto a seguir',
                style: Theme.of(context).textTheme.headline5,
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: snapshot.connectionState == ConnectionState.done
                    ? TrayectoMap(load)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }
}

class TrayectoMap extends StatefulWidget {
  TrayectoMap(this.load, {Key? key}) : super(key: key);
  Load load;
  @override
  State<StatefulWidget> createState() => _StateTrayectoMap();
}

class _StateTrayectoMap extends State<TrayectoMap> {
  late Position position;
  late GoogleMapController mapController;
  String _darkMapStyle = '';
  late Future getPos;
  final Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  getPosition() async {
    position = await Geolocator.getCurrentPosition();
  }

  setMapStyles() async {
    _darkMapStyle =
        await rootBundle.loadString('assets/google_map_styles.json');
    mapController.setMapStyle(_darkMapStyle);
  }

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

      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(destin.latitude, destin.longitude),
            northeast: LatLng(origin.latitude, origin.longitude),
          ),
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
    getPosition();
    setPolylinesInMap(
      LatLng(double.parse(widget.load.latitudeFrom),
          double.parse(widget.load.longitudeFrom)),
      LatLng(
        double.parse(widget.load.destinLatitude),
        double.parse(widget.load.destinLongitude),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getPos = getPosition();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getPos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GoogleMap(
            onMapCreated: (controller) {
              _onMapCreated(controller);
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(position.latitude, position.longitude),
            ),
            polylines: _polylines,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
