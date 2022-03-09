import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Tests extends StatefulWidget {
  @override
  TestsState createState() => TestsState();
}

class TestsState extends State {
  late Geolocator _geolocator;
  Position? _position;

  @override
  void initState() {
    super.initState();

    _geolocator = Geolocator();

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 100,
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      String posicion = 'POSICION: ' +
          (position == null
              ? 'Unknown'
              : '${position.latitude.toString()}, ${position.longitude.toString()}');
      print(posicion);
      _position = position!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(posicion),
        duration: Duration(seconds: 1),
      ));
    });
  }

  void updateLocation() async {
    try {
      Position newPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .timeout(new Duration(seconds: 5));

      setState(() {
        _position = newPosition;
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
      ),
      body: Center(
          child: Text(
              'Latitude: ${_position != null ? _position!.latitude.toString() : '0'},'
              ' Longitude: ${_position != null ? _position!.longitude.toString() : '0'}')),
    );
  }
}
