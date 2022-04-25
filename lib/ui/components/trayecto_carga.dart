import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/utils/load_image.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class VerTrayecto extends StatefulWidget {
  VerTrayecto(this.load,
      {this.id = 0,
      this.trackTransportistLocation = false,
      this.transportistId = 0,
      Key? key})
      : super(key: key);
  int id;
  Load load;
  bool trackTransportistLocation;
  int transportistId;
  @override
  State<VerTrayecto> createState() => _VerTrayectoState();
}

class _VerTrayectoState extends State<VerTrayecto> {
  late Size size;
  late Load load;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    load = widget.load;
  }

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
      child: Column(
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
              child: TrayectoMap(
            load,
            widget.trackTransportistLocation,
            transportistId: widget.transportistId,
          )),
        ],
      ),
    );
  }
}

class TrayectoMap extends StatefulWidget {
  TrayectoMap(this.load, this.trackTransportistLocation,
      {this.transportistId = 0, Key? key})
      : super(key: key);
  Load load;
  bool trackTransportistLocation;
  int transportistId;
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
  final List<Marker> _markers = [];

  getPosition() async {
    position = await Geolocator.getCurrentPosition();
  }

  setMapStyles() async {
    _darkMapStyle =
        await rootBundle.loadString('assets/google_map_styles.json');
    mapController.setMapStyle(_darkMapStyle);
  }

  Future<MarkerId> setPolylinesInMap(LatLng origin, LatLng destin) async {
    var result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyABWbV1Hy-mBKOhuhaIzzgBP32mloFhhBs',
      PointLatLng(origin.latitude, origin.longitude),
      PointLatLng(destin.latitude, destin.longitude),
    );
    if (result.points.isNotEmpty) {
      MarkerId marcadorOrigen = const MarkerId('marcador_origen');
      MarkerId marcadorDestino = const MarkerId('marcador_destino');

      _markers.clear();
      _markers.add(
        Marker(
          markerId: marcadorOrigen,
          position: origin,
          infoWindow: InfoWindow(
            title: 'Origen',
            snippet: widget.load.addressFrom,
          ),
          icon: BitmapDescriptor.fromBytes(
            await getBytesFromAsset('assets/img/start.png', 50),
          ),
        ),
      );
      _markers.add(
        Marker(
          markerId: marcadorDestino,
          position: destin,
          infoWindow: InfoWindow(
            title: 'Destino',
            snippet: widget.load.destinAddress,
          ),
          icon: BitmapDescriptor.fromBytes(
            await getBytesFromAsset('assets/img/finish.png', 50),
          ),
        ),
      );
      for (var pointLatLng in result.points) {
        polylineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
      setState(() {
        _polylines.add(Polyline(
          width: 5,
          polylineId: const PolylineId('polyline'),
          color: Colors.blueAccent,
          points: polylineCoordinates,
        ));
      });

      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          origin,
          10,
        ),
      );
      return _markers[0].markerId;
    }
    return const MarkerId('');
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    polylinePoints = PolylinePoints();
    setMapStyles();
    getPosition();
    MarkerId mkinfo = await setPolylinesInMap(
      LatLng(
        double.parse(widget.load.latitudeFrom),
        double.parse(widget.load.longitudeFrom),
      ),
      LatLng(
        double.parse(widget.load.destinLatitude),
        double.parse(widget.load.destinLongitude),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      mapController.showMarkerInfoWindow(mkinfo);
    });
  }

  setMarkers(
    List<TransportistLocation> transportists,
  ) async {
    if (widget.transportistId != 0) {
      BitmapDescriptor carIcon = BitmapDescriptor.fromBytes(
          await getBytesFromAsset('assets/img/camion3.png', 30));
      MarkerId markerId = const MarkerId('carPosition');
      int index =
          _markers.indexWhere((element) => element.markerId == markerId);
      widget.transportistId = context.read<ChatProvider>().transportistId;
      transportists.asMap().forEach((key, transportist) {
        if (transportist.transportistId == widget.transportistId) {
          Marker marker = Marker(
            markerId: MarkerId(transportist.transportistId.toString() +
                transportist.vehicleId.toString()),
            position: LatLng(
              transportist.latitude,
              transportist.longitude,
            ),
            icon: carIcon,
            flat: true,
            rotation: transportist.heading,
            infoWindow: InfoWindow(title: transportist.name),
          );
          if (index != -1) {
            _markers[index] = marker;
          } else {
            _markers.add(marker);
          }
        }
      });
    }
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
          if (widget.trackTransportistLocation) {
            List<TransportistLocation> transportists =
                context.watch<TransportistsLocProvider>().transportists;
            setMarkers(transportists);
          }
          return GoogleMap(
            onMapCreated: (controller) {
              _onMapCreated(controller);
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 16,
            ),
            myLocationEnabled: true,
            polylines: _polylines,
            markers: _markers.map((e) => e).toSet(),
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
