import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LiveShareLocationPage extends StatefulWidget {
  const LiveShareLocationPage({Key? key}) : super(key: key);

  @override
  State<LiveShareLocationPage> createState() => _LiveShareLocationPageState();
}

class _LiveShareLocationPageState extends State<LiveShareLocationPage> {
  Position? position;

  getCurrentPosition() async {
    position = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        TextButton(onPressed: () {}, child: const Text('Add location')),
        TextButton(onPressed: () {}, child: const Text('Enable live location')),
        TextButton(onPressed: () {}, child: const Text('Stop live location')),
      ],
    ));
  }
}
