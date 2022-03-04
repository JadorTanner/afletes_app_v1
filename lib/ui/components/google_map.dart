import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AfletesGoogleMap extends StatefulWidget {
  AfletesGoogleMap(
      {this.center = const LatLng(-25.27705190025039, -57.63737049639007),
      this.onTap,
      this.loads = const [],
      this.onTapMarker,
      Key? key})
      : super(key: key);
  var onTap;
  LatLng? center;
  List<Load> loads;
  var onTapMarker;
  @override
  State<AfletesGoogleMap> createState() => Afletes_GoogleMapState();
}

class Afletes_GoogleMapState extends State<AfletesGoogleMap> {
  late GoogleMapController mapController;
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
    mounted
        ? setState(() {
            print(position);
            widget.center = LatLng(position.latitude, position.longitude);
            mapController.animateCamera(CameraUpdate.newLatLng(widget.center!));
            print(widget.center);
            setMarkers(position);
          })
        : () => {};
  }

  //AGREGA LOS MARCADORES EN CASO DE QUE SE LE PASE
  setMarkers(Position position) {
    widget.loads.asMap().forEach((key, load) {
      markers.add(
        Marker(
          markerId: MarkerId(load.id.toString()),
          position: LatLng(
            double.parse(load.latitudeFrom),
            double.parse(load.longitudeFrom),
          ),
          infoWindow: InfoWindow(
              title: load.product != '' ? load.product : load.addressFrom,
              snippet: 'Oferta inicial: ' + load.initialOffer.toString()),
          onTap: () => widget.onTapMarker(load.id, context),
        ),
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    print('created map');
    mapController = controller;
    setMapStyles();
    // mapController.setMapStyle('');
    getPosition();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      onTap: (argument) => {widget.onTap(mapController, argument)},
      myLocationEnabled: true,
      scrollGesturesEnabled: false,
      initialCameraPosition: CameraPosition(
        target: widget.center!,
        zoom: 11.0,
      ),
      markers: markers.map((e) => e).toSet(),
    );
  }
}
