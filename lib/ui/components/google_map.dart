import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AfletesGoogleMap extends StatefulWidget {
  AfletesGoogleMap(
      {this.center = const LatLng(45.521563, -122.677433),
      this.onTap,
      Key? key})
      : super(key: key);
  var onTap;
  LatLng? center;
  @override
  State<AfletesGoogleMap> createState() => Afletes_GoogleMapState();
}

class Afletes_GoogleMapState extends State<AfletesGoogleMap> {
  late GoogleMapController mapController;

  //coordenada inicial
  late Position position;

  getPosition() async {
    position = await Geolocator.getCurrentPosition();
    mounted
        ? setState(() {
            print(position);
            widget.center = LatLng(position.latitude, position.longitude);
            mapController.animateCamera(CameraUpdate.newLatLng(widget.center!));
            print(widget.center);
          })
        : () => {};
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    getPosition();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.center);
    return GoogleMap(
      onMapCreated: _onMapCreated,
      onTap: (argument) => {widget.onTap(argument)},
      initialCameraPosition: CameraPosition(
        target: widget.center!,
        zoom: 11.0,
      ),
    );
  }
}
